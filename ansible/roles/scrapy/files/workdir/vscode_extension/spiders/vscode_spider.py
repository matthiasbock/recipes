#!/usr/bin/env python3

import os
import scrapy
import json

from typing import Generator, Dict, Any, Optional


class VSCodeExtensionSpider(scrapy.Spider):
    """
    Spider for Microsoft"s Visual Studio Code extension repository
    """
    name = "vscode_extension"
    custom_settings = {
        "protocol":     "https",
        "host":         "marketplace.visualstudio.com",
        "user_agent":   "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36"
    }
    allowed_domains = ["marketplace.visualstudio.com"]
    start_urls = [f"https://marketplace.visualstudio.com/VSCode"]


    def __init__(
            self,
            extension_name: str,
            output_filename: str,
            download_version: str = "latest",
            *args, **kwargs
        ):
        super(VSCodeExtensionSpider, self).__init__(*args, **kwargs)
        self.parse_displayname(extension_name)
        self.download_version = download_version
        self.output_filename = os.path.realpath(output_filename)
        self.item_url = VSCodeExtensionSpider.url_extension_page(publisher=self.publisher, extension=self.extension)


    def parse_displayname(self, displayname: str) -> None:
        self.display_name = displayname
        s = displayname.split(".")
        self.publisher = s[0]
        self.extension = s[1]


    @classmethod
    @property
    def url_prefix(cls) -> str:
        return "https://marketplace.visualstudio.com"


    @classmethod
    def url_extension_page(cls, publisher: str, extension: str) -> str:
        return f"{cls.url_prefix}/items?itemName={publisher}.{extension}"


    @classmethod
    @property
    def url_prefix_api_gallery(cls) -> str:
        return f"{cls.url_prefix}/_apis/public/gallery"


    @classmethod
    def url_extension_query(cls) -> str:
        return f"{cls.url_prefix_api_gallery}/extensionquery"


    @classmethod
    def url_overview_md(cls, id: str, version: str) -> str:
        return f"{cls.url_prefix_api_gallery}/extensions/{id}/{version}/assets/Microsoft.VisualStudio.Services.Content.Details"


    @classmethod
    def url_download_version(cls, publisher: str, extension: str, version: str) -> str:
        return f"{cls.url_prefix_api_gallery}/publishers/{publisher}/vsextensions/{extension}/{version}/vspackage"


    def parse(self, response: scrapy.http.Response) -> Generator[scrapy.Request, None, None]:
        """
        GET https://marketplace.visualstudio.com/items?itemName=GitHub.copilot
        Referer: https://marketplace.visualstudio.com/VSCode
        Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7
        """
        def parse_extension_page(response: scrapy.http.Response) -> Generator[scrapy.Request, None, None]:
            self.log(f"Parsing extension page...")

            json_data = response.css('script.jiContent::text').get()
            extension_info = json.loads(json_data)
            resources = extension_info["Resources"]

            self.extension_publisher = resources["PublisherName"]
            self.extension_name = resources["ExtensionName"]

            yield from self.query_extension()

        self.log(f"Requesting extension page: {self.item_url}")
        yield scrapy.Request(url=self.item_url, callback=parse_extension_page)


    def query_extension(self) -> Generator[scrapy.Request, None, None]:
        """
        Extension query

        POST https://marketplace.visualstudio.com/_apis/public/gallery/extensionquery
        Referer: https://marketplace.visualstudio.com/items?itemName=GitHub.copilot
        Accept: application/json;api-version=7.2-preview.1;excludeUrls=true
        Content-Type: application/json
        Payload: {"assetTypes":null,"filters":[{"criteria":[{"filterType":7,"value":"GitHub.copilot"}],"direction":2,"pageSize":100,"pageNumber":1,"sortBy":0,"sortOrder":0,"pagingToken":null}],"flags":2151}
        """
        payload = {
            "filters": [{
                "criteria": [
                    {"filterType": 7, "value": f"{self.extension_publisher}.{self.extension_name}"}
                ],
                "pageNumber": 1,
                "pageSize": 1,
                "sortBy": 0,
                "sortOrder": 0
            }],
            "assetTypes": [],
            "flags": 2151
        }
        with open(os.path.realpath("extension_query.json"), "w") as f:
            f.write(json.dumps(payload, indent=2))
        self.log(f"Posting extension query...")

        def parse_response(response: scrapy.http.Response) -> None:
            self.log(f"Parsing POST response...")
            response_data = json.loads(response.text)
            with open(os.path.realpath("extension_query.response.json"), "w") as f:
                f.write(json.dumps(response_data, indent=2))
            results = response_data["results"]
            self.extension_id = results[0]["extensions"][0]["extensionId"]

            yield from self.get_overview_md()
            yield from self.download()

        def error_handler(failure: scrapy.http.Response) -> None:
            self.log(f"Request failed with status {failure.value.response.status} and body: {failure.value.response.text}")

        yield scrapy.Request(
            url=VSCodeExtensionSpider.url_extension_query(),
            method='POST',
            body=json.dumps(payload),
            headers={
                'Content-Type': 'application/json',
                "Accept": "application/json;api-version=7.2-preview.1;excludeUrls=true"
            },
            callback=parse_response,
            errback=error_handler
        )


    def get_overview_md(self, filename: str = os.path.realpath("overview.md")) -> Generator[scrapy.Request, None, None]:
        """
        Fetch extension description (Markdown)

        GET https://marketplace.visualstudio.com/_apis/public/gallery/extensions/23c4aeee-f844-43cd-b53e-1113e483f1a6/1.213.986/assets/Microsoft.VisualStudio.Services.Content.Details
        Referer: https://marketplace.visualstudio.com/items?itemName=GitHub.copilot
        Accept: application/octet-stream;api-version=7.2-preview.1;excludeUrls=true
        """
        url = \
            VSCodeExtensionSpider.url_overview_md(
                id=self.extension_id,
                version=self.download_version
            )
        self.log(f"Downloading extension description from: {url}")

        def parse_description(response: scrapy.http.Response) -> None:
            self.log(f"Saving description to file: {filename}")
            with open(filename, "w") as f:
                f.write(response.text)

        yield scrapy.Request(url=url, callback=parse_description)


    def download(self) -> Generator[scrapy.Request, None, None]:
        """
        Download an extension package

        GET https://marketplace.visualstudio.com/_apis/public/gallery/publishers/GitHub/vsextensions/copilot/1.213.986/vspackage
        Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7
        """
        self.log(f"Downloading extension version...")
        # versions = extension_info.get('versions', [])
        # if versions:
        #     latest_version = versions[0]  # Assuming the first one is the latest
        #     version_number = latest_version.get('version')
        #     if version_number:

        download_url = \
            VSCodeExtensionSpider.url_download_version(
                publisher=self.extension_publisher,
                extension=self.extension_name,
                version=self.download_version
            )

        def save_to_file(response: scrapy.http.Response) -> None:
            self.log(f"Saving download to file: {self.output_filename}")
            with open(os.path.realpath(self.output_filename), 'wb') as f:
                f.write(response.body)

        yield scrapy.Request(url=download_url, callback=save_to_file)


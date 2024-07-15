#!/usr/bin/env python3

import scrapy
import json


class VSCodeExtensionSpider(scrapy.Spider):
    """
    Spider for Microsoft"s Visual Studio Code extension repository
    """
    name = "vscode_extension"
    allowed_domains = ["marketplace.visualstudio.com"]
    start_urls = ["https://marketplace.visualstudio.com/VSCode"]

    # Configure the user agent
    custom_settings = {
        "USER_AGENT": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36"
    }

    def __init__(self, extension_name="", *args, **kwargs):
        super(VSCodeExtensionSpider, self).__init__(*args, **kwargs)
        self.extension_name = extension_name.replace(" ", "")
        self.item_url = f"https://marketplace.visualstudio.com/items?itemName={self.extension_name}"


    def parse(self, response):
        # Navigate to the specific extension page
        yield scrapy.Request(url=self.item_url, callback=self.parse_extension_page)


    def parse_extension_page(self, response):
        # Extract JSON from the <script> tag with class "jiContent"
        json_data = response.css("script.jiContent::text").get()
        if json_data:
            extension_info = json.loads(json_data)
            # Use the extension info to construct the POST request payload
            payload = {
                "filters": [{
                    "criteria": [{"filterType": 7, "value": self.extension_name}],
                    "pageNumber": 1,
                    "pageSize": 1,
                    "sortBy": 0,
                    "sortOrder": 0
                }],
                "assetTypes": [],
                "flags": 0
            }
            self.log(payload)
            yield payload

        # Send a POST request to get additional JSON data
        # yield scrapy.Request(
        #     url="https://marketplace.visualstudio.com/_apis/public/gallery/extensionquery",
        #     method="POST",
        #     body=json.dumps(payload),
        #     headers={"Content-Type": "application/json"},
        #     callback=self.parse_post_response
        # )


    def parse_post_response(self, response):
        # Process the JSON response from the POST request
        post_response_data = json.loads(response.text)
        self.log(post_response_data)
        # Save or process the response data as needed

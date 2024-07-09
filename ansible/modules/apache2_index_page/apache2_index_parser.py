
import requests
from urllib.parse import urlparse, urljoin
import email.utils
from bs4 import BeautifulSoup
import re
from typing import Optional

from ansible.module_utils.basic import AnsibleModule


def query_file_info(url: str) -> dict[str, str | int]:
    """
    Retrieves additional information about the specified file from the server
    """
    result = {}

    # Send a HEAD request to get headers without downloading the file
    try:
        response = requests.head(url, allow_redirects=True)
        response.raise_for_status()
    except:
        return {}

    # Get file size
    file_size = response.headers.get("Content-Length")
    if file_size:
        result["size"] = int(file_size)

    # Get file name
    content_disposition = response.headers.get("Content-Disposition")
    if content_disposition:
        result["name"] = content_disposition.split("filename=")[-1].strip('"')

    # Get Last-Modified and convert to Unix timestamp
    last_modified = response.headers.get('Last-Modified')
    last_modified_unix = None
    if last_modified:
        # Parse the date string
        last_modified_datetime = email.utils.parsedate_to_datetime(last_modified)
        result["last_modified"] = last_modified_datetime
        # Convert to Unix timestamp (seconds since epoch)
        last_modified_unix = int(last_modified_datetime.timestamp())
        result["last_modified_unix"] = last_modified_unix

    # Get checksums
    checksums = {
        "etag": "ETag",
        "md4": "Content-MD4",
        "md5": "Content-MD5",
        "sha1": "Content-SHA1",
        "sha256": "Content-SHA256",
        "sha512": "Content-SHA512",
    }
    for name, header in checksums.items():
        checksum = response.headers.get(header)
        if checksum:
            result[name] = checksum.strip('"')

    return result


def fetch_and_parse(
    page_url: str, name_regex: Optional[str] = None
) -> tuple[str, list[str], list[str]]:
    """
    Fetches the page at the given URL and
    parses an Apache2 index table from it
    """
    if not isinstance(page_url, str):
        raise TypeError(f"URL argument must be string, got {type(url).__name__}")

    if name_regex is None:
        name_regex = r".*"
    if not isinstance(name_regex, str):
        raise TypeError(
            f"Pattern argument must be string, got {type(name_regex).__name__}"
        )

    # Compile regular expression pattern
    regex = re.compile(name_regex)
    print(f"Regular expression for name matching: {regex.pattern}")

    print(f"Fetching URL: {page_url}")

    response = requests.get(page_url, allow_redirects=True)

    # Make sure we notice bad responses
    response.raise_for_status()

    content_type = response.headers["Content-Type"]
    if "html" not in content_type:
        raise ValueError(f"Expected content type HTML, got {content_type}")

    html = response.content
    # print(f"HTML: {html}")

    soup = BeautifulSoup(html, "html.parser")

    # Find index table
    index_table = soup.find("table", id="indexlist")
    if not index_table:
        raise ValueError("Index table not found")

    # Find relevant columns in header
    header = index_table.find("tr", attrs={"class": "indexhead"})
    if not header:
        raise ValueError("Table header not found")

    header_columns = header.find_all("th")

    column_icon = header.find("th", attrs={"class": "indexcolicon"})
    if not column_icon:
        raise ValueError("Icon column not found")
    column_icon = header_columns.index(column_icon)

    column_name = header.find("th", attrs={"class": "indexcolname"})
    if not column_name:
        raise ValueError("Name column not found")
    column_name = header_columns.index(column_name)

    column_lastmod = header.find("th", attrs={"class": "indexcollastmod"})
    if not column_lastmod:
        raise ValueError("Modification time column not found")
    column_lastmod = header_columns.index(column_lastmod)

    column_size = header.find("th", attrs={"class": "indexcolsize"})
    if not column_size:
        raise ValueError("File size column not found")
    column_size = header_columns.index(column_size)

    # Evaluate rows
    rows = index_table.find_all("tr")
    skip_rows = set(["indexhead", "indexbreakrow"])
    files = []
    directories = []
    for row_idx, row in enumerate(rows):
        if len(set(row["class"] or []) & skip_rows) > 0:
            continue

        cols = row.find_all("td")
        if len(cols) < 4:
            # print(f"Skipping row {row_idx} with insufficient number of column: {len(cols)}")
            continue

        # print(f"Row {row_idx} has {len(cols)} columns: {row}")

        # Extract relevant columns
        icon_alt = cols[column_icon].find("img")["alt"].strip().upper()
        name = cols[column_name].find("a").get_text().strip()
        url = cols[column_name].find("a")["href"].strip()
        last_modified = cols[column_lastmod].get_text().strip()
        size = cols[column_size].get_text().strip()

        # Discard irrelevant entries
        if name in [".", "..", "Parent Directory"]:
            continue

        # Apply name pattern
        m = regex.match(name)
        if (not m) or (len(m.group()) != len(name)):
            print(f"Pattern mismatch, skipping: {name}")
            continue

        # Identify directories
        is_dir = icon_alt == "[DIR]"

        # Ensure fully qualified URL
        if url.lower().find("http") != 0:
            url = urljoin(page_url, url)

        entry = {
            "name": name,
            "url": url,
            "last_modified": last_modified,
            "size": size,
        }

        if is_dir:
            dirs.append(entry)
        else:
            additional_file_info = query_file_info(entry["url"])
            entry.update(additional_file_info)
            files.append(entry)

    return html, files, directories


def main():
    module = AnsibleModule(
        argument_spec=dict(
            url=dict(type="str", required=True),
            name_regex=dict(type="str", required=False),
        )
    )

    try:
        html, files, directories = fetch_and_parse(
            page_url=module.params["url"], name_regex=module.params["name_regex"]
        )

        file_names = [f["name"] for f in files]
        file_urls = [f["url"] for f in files]
        directory_names = [d["name"] for d in directories]
        directory_urls = [d["url"] for d in directories]

        module.exit_json(
            changed=False,
            html=html,
            entries=files + directories,
            num_entries=len(files) + len(directories),
            urls=directory_urls + file_urls,
            files=files,
            num_files=len(files),
            file_names=file_names,
            file_urls=file_urls,
            directories=directories,
            num_directories=len(directories),
            directory_names=directory_names,
            directory_urls=directory_urls,
        )
    except Exception as e:
        module.fail_json(msg=str(e))


if __name__ == "__main__":
    main()

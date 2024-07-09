
from ansible.module_utils.basic import AnsibleModule
import requests
from bs4 import BeautifulSoup


DOCUMENTATION = """
---
module: charite_gb_finanzen
short_description: Fetch and parse financial documents from Charité intranet
description:
    - This module fetches the URL https://intranet.charite.de/fi/download_und_service/
    - and parses the HTML to extract a list of documents with their URLs and names.
options: {}
author:
    - Your Name
"""


EXAMPLES = """
- name: Fetch Charité financial documents
  charite_gb_finanzen:
  register: result

- debug:
    var: result.documents
"""


RETURN = """
documents:
    description: List of documents with their URLs and names
    type: list
    elements: dict
    contains:
        url:
            description: URL of the document
            type: str
        name:
            description: Name of the document
            type: str
    returned: always
"""


def run_module():
    module = AnsibleModule(argument_spec={}, supports_check_mode=True)

    url = "https://intranet.charite.de/fi/download_und_service/"

    try:
        response = requests.get(url)
        response.raise_for_status()
    except requests.exceptions.RequestException as e:
        module.fail_json(msg=f"Error fetching URL: {str(e)}")

    soup = BeautifulSoup(response.content, "html.parser")
    center_column = soup.find("div", id="centerColumn")

    if not center_column:
        module.fail_json(msg="Could not find div with id 'centerColumn'")

    csc_frames = center_column.find_all("div", class_="csc-frame")
    documents = []

    for frame in csc_frames:
        links = frame.find_all("a")
        for link in links:
            documents.append({"url": link.get("href"), "name": link.text.strip()})

    result = {"changed": False, "documents": documents}

    module.exit_json(**result)


if __name__ == "__main__":
    run_module()

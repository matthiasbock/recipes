
import re
from ansible.errors import AnsibleFilterError


__all__ = [
    "extract_url",
    "FilterModule"
]


# Compile regex globally
JIGDO_REGEX = re.compile(r'href="([^"]*DVD-1.jigdo)"')


def extract_url(content: str) -> str:
    """
    Extracts the DVD1 Jigdo URL from the Apache2 index page content.
    :param content: HTML content of the Apache2 index page.
    :return: URL of the DVD1 Jigdo file.
    :raises AnsibleFilterError: If no DVD1 Jigdo URL is found.
    """
    match = JIGDO_REGEX.search(content)
    if match:
        return match.group(1)
    else:
        raise AnsibleFilterError("DVD1 Jigdo URL not found in the provided content.")


class FilterModule(object):
    """
    Ansible filter module to extract the DVD1 Jigdo URL.
    """
    def filters(self):
        return {
            'extract_url': extract_url
        }

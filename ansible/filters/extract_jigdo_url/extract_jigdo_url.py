
import re
from ansible.errors import AnsibleFilterError


__all__ = [
    "extract_jigdo_url",
    "FilterModule"
]


# Compile regex globally
JIGDO_REGEX = re.compile(r'href="([^"]*DVD-1.jigdo)"')


def extract_jigdo_url(content: str) -> str:
    """
    Extracts the first DVD Jigdo URL from a given Apache2 index page given as string

    :param content: HTML content of the Apache2 index page as string
    :return: Parsed URL
    :raises AnsibleFilterError: If URL parsing fails
    """
    match = JIGDO_REGEX.search(content)
    if match:
        return match.group(1)
    else:
        raise AnsibleFilterError("Jigdo URL not found in the provided content")


class FilterModule(object):
    """
    Ansible filter module to extract the DVD1 Jigdo URL.
    """
    def filters(self):
        return {
            "extract_jigdo_url": extract_jigdo_url
        }

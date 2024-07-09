
import pytest

from ansible.errors import AnsibleFilterError


valid_html_content = """
<html>
<body>
<a href="debian-10.0.0-armhf-DVD-1.jigdo">DVD-1.jigdo</a>
<a href="debian-10.0.0-armhf-DVD-2.jigdo">DVD-2.jigdo</a>
</body>
</html>
"""

invalid_html_content = """
<html>
<body>
<a href="debian-10.0.0-armhf-DVD-2.jigdo">DVD-2.jigdo</a>
</body>
</html>
"""

empty_html_content = """
<html>
<body>
</body>
</html>
"""


@pytest.mark.parametrize("content,expected", [
    (valid_html_content, "debian-10.0.0-armhf-DVD-1.jigdo"),
])
def test_extract_jigdo_url_valid(content, expected):
    """
    Test case for valid HTML content containing the DVD1 Jigdo link.
    """
    from .extract_jigdo_url import extract_jigdo_url

    assert extract_jigdo_url(content) == expected


def test_extract_jigdo_url_invalid():
    """
    Test case for HTML content without the DVD1 Jigdo link.
    """
    from .extract_jigdo_url import extract_jigdo_url

    with pytest.raises(AnsibleFilterError):
        extract_jigdo_url(invalid_html_content)


def test_extract_jigdo_url_empty():
    """
    Test case for empty HTML content.
    """
    from .extract_jigdo_url import extract_jigdo_url

    with pytest.raises(AnsibleFilterError):
        extract_jigdo_url(empty_html_content)


class FilterModule(object):
    """
    This class is defined here in order to suppress ansible-playbook warning
        "...seems to be invalid: module ... has no attribute 'FilterModule'"
    """
    def filters(self):
        return {}


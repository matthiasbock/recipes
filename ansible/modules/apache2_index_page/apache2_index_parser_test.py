import pytest


# Test data for mocking the requests.get response
index_page_html = """
<html>
<head><title>Index of /</title></head>
<body>
<h1>Index of /</h1>
<table id="indexlist">
<tr class="indexhead">
    <th class="indexcolicon"><img src="/icons2/blank.png" alt="[ICO]"></th>
    <th class="indexcolname"><a href="?C=N;O=D">Name</a></th>
    <th class="indexcollastmod"><a href="?C=M;O=A">Last modified</a></th>
    <th class="indexcolsize"><a href="?C=S;O=A">Size</a></th>
</tr>
<tr class="odd">
    <td class="indexcolicon"><a href="SHA256SUMS"><img src="/icons2/text-x-generic-template.png" alt="[SUM]"></a></td>
    <td class="indexcolname"><a href="SHA256SUMS">SHA256SUMS</a></td>
    <td class="indexcollastmod">2024-06-29 22:49  </td>
    <td class="indexcolsize">6.4K</td>
</tr>
    <tr class="even"><td class="indexcolicon"><a href="SHA256SUMS.sign"><img src="/icons2/application-certificate.png" alt="[CRT]"></a></td>
    <td class="indexcolname"><a href="SHA256SUMS.sign">SHA256SUMS.sign</a></td>
    <td class="indexcollastmod">2024-06-29 22:50  </td>
    <td class="indexcolsize">833 </td>
</tr>
</table>
</body>
</html>
"""


@pytest.fixture
def mock_response(mocker):
    mock_response = mocker.patch("requests.get")
    mock_response.return_value.status_code = 200
    mock_response.return_value.headers = {"Content-Type": "text/html"}
    mock_response.return_value.content = index_page_html
    return mock_response


def test_fetch_and_parse(mock_response):
    from .apache2_index_parser import fetch_and_parse

    url = "https://example.com"
    expected_files = [
        {
            "name": "SHA256SUMS",
            "url": "https://example.com/SHA256SUMS",
            "last_modified": "2024-06-29 22:49",
            "size": "6.4K",
        },
        {
            "last_modified": "2024-06-29 22:50",
            "name": "SHA256SUMS.sign",
            "size": "833",
            "url": "https://example.com/SHA256SUMS.sign",
        }
    ]

    html, files, directories = fetch_and_parse(url)

    assert files == expected_files


def test_fetch_and_parse(mock_response):
    from .apache2_index_parser import fetch_and_parse

    url = "https://example.com"
    expected_files = [
        {
            "name": "SHA256SUMS",
            "url": "https://example.com/SHA256SUMS",
            "last_modified": "2024-06-29 22:49",
            "size": "6.4K",
        },
        {
            "last_modified": "2024-06-29 22:50",
            "name": "SHA256SUMS.sign",
            "size": "833",
            "url": "https://example.com/SHA256SUMS.sign",
        }
    ]

    html, files, directories = fetch_and_parse(url)

    assert files == expected_files


# @pytest.mark.parametrize(
#     argnames=()
# )
def test_pattern(mock_response):
    from .apache2_index_parser import fetch_and_parse

    url = "https://example.com"

    _, files, _ = fetch_and_parse(url, name_regex=r"SHA256SUMS")
    assert len(files) == 1

    _, files, _ = fetch_and_parse(url, name_regex=r"SHA[0-9]+SUMS")
    assert len(files) == 1

    _, files, _ = fetch_and_parse(url, name_regex=r"SHA.*")
    assert len(files) == 2

    _, files, _ = fetch_and_parse(url, name_regex=r"SHA[0-9]+SUMS.*")
    assert len(files) == 2

    _, files, _ = fetch_and_parse(url, name_regex=r".*\.sign")
    assert len(files) == 1


def test_fetch_and_parse():
    from .apache2_index_parser import fetch_and_parse

    url = "https://cdimage.debian.org/debian-cd/current/armhf/jigdo-dvd/"

    html, files, directories = fetch_and_parse(url)

    assert len(files) > 20
    assert len(directories) == 0


class FilterModule(object):
    """
    This class is defined here in order to suppress ansible-playbook warning
        "...seems to be invalid: module ... has no attribute 'FilterModule'"
    """

    def filters(self):
        return {}

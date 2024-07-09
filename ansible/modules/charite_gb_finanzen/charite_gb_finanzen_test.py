
import unittest
import json

from unittest.mock import patch, MagicMock

from ansible.module_utils import basic
from ansible.module_utils.common.text.converters import to_bytes


def set_module_args(args):
    args = json.dumps({"ANSIBLE_MODULE_ARGS": args})
    basic._ANSIBLE_ARGS = to_bytes(args)


class TestChariteGbFinanzenModule(unittest.TestCase):
    def setUp(self):
        self.mock_module = patch.object(basic, "AnsibleModule")
        self.mock_module.start()
        self.mock_request = patch("requests.get")
        self.mock_request.start()

    def tearDown(self):
        self.mock_module.stop()
        self.mock_request.stop()

    def test_successful_fetch(self):
        set_module_args({})

        mock_response = MagicMock()
        mock_response.content = """
        <html>
            <div id="centerColumn">
                <div class="csc-frame">
                    <a href="http://example.com/doc1">Document 1</a>
                    <a href="http://example.com/doc2">Document 2</a>
                </div>
            </div>
        </html>
        """
        mock_response.raise_for_status.return_value = None

        with patch("requests.get", return_value=mock_response):
            from .charite_gb_finanzen import run_module

            with patch("ansible.module_utils.basic.AnsibleModule") as mock_module:
                mock_instance = mock_module.return_value
                run_module()

                expected_documents = [
                    {"url": "http://example.com/doc1", "name": "Document 1"},
                    {"url": "http://example.com/doc2", "name": "Document 2"},
                ]

                mock_instance.exit_json.assert_called_once_with(
                    changed=False, documents=expected_documents
                )

    def test_failed_fetch(self):
        set_module_args({})

        with patch("requests.get", side_effect=Exception("Connection error")):
            from .charite_gb_finanzen import run_module

            with patch("ansible.module_utils.basic.AnsibleModule") as mock_module:
                mock_instance = mock_module.return_value
                run_module()

                mock_instance.fail_json.assert_called_once_with(
                    msg="Error fetching URL: Connection error"
                )


if __name__ == "__main__":
    unittest.main()

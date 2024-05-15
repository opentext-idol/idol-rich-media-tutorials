# Tests

This folder contains test files to be run to validate aspects of these tutorial files.

## List of validation tests

### External links

From this `tests` folder, run the script `python validate_external_links.py`.  This file searches all markdown files for docs URLs and checks for a 200 status code using the `requests` library.

### Config validation

From this `tests` folder, run the script `python validate_session_cfgs.py`, which requires access to IDOL Media Server, and sends all .cfg files for validation. This is intended to pick up any breaking changes in future releases of Media Server.

*That's all folks!*

# Tests

This folder contains test files to be run to validate aspects of these tutorial files.

> NOTE: The included scripts depend on having `python` installed. Please follow these [instructions](../tutorials/setup/PYTHON.md) if you do not already have it on your system.

## List of validation tests

### Internal links

From this `tests` folder, run the script `validate_internal_md_links.py`.  This file searches all markdown files for internal `[label](path/to/doc.md)` references and checks that those files exist.

From this `tests` folder, run the script `validate_internal_img_links.py`.  This file searches all markdown files for internal `![label](path/to/image.ext)` references and checks that those files exist.

From this `tests` folder, run the script `check_for_unreferenced_figs.py`. This file searches all markdown files for internal `![label](path/to/image.ext)` references, then cross-checks against a list of all figures assets to check that no unreferenced files exist.

From this `tests` folder, run the script `find_unexpected_links.py`. This file searches all markdown files for internal `[label](value)` links, then checks for the unexpected.

### External links

From this `tests` folder, run the script `validate_external_links.py`.  This file searches all markdown files for external URLs and checks for a 200 status code using the `requests` library.

### Config validation

From this `tests` folder, run the script `validate_session_cfgs.py`, which requires access to Knowledge Discovery Media Server, and sends all `.cfg` files for validation. This is intended to pick up any breaking changes in future releases of Media Server.

*That's all folks!*

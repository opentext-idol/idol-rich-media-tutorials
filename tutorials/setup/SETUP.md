# Create your own IDOL rich media setup

This is a setup guide for a basic installation of IDOL rich media and associated components.

---
<!-- TOC -->

- [Useful third-party tools](#useful-third-party-tools)
- [IDOL components](#idol-components)
  - [Obtain an IDOL license](#obtain-an-idol-license)
  - [Install IDOL software](#install-idol-software)
  - [Obtaining tutorial materials](#obtaining-tutorial-materials)
    - [Following this guide offline](#following-this-guide-offline)
    - [Validate install](#validate-install)
  - [Further reading](#further-reading)

<!-- /TOC -->
---

## Useful third-party tools

A text editor, *e.g.*:

- [VS Code](https://code.visualstudio.com/download), or
- [Notepad++](https://notepad-plus-plus.org/download)

A log follower, *e.g.*:

- `tail -F` from the command line, or
- [Baretail](https://www.baremetalsoft.com/baretail/) - select the *Free Version*

## IDOL components

IDOL components are licensed via the IDOL License Server application, which requires a license key.

### Obtain an IDOL license

You can obtain software and licenses from the [Software Licensing and Downloads](https://sld.microfocus.com/mysoftware/index) portal.

1. Under the *Entitlements* tab, search for *IDOL*
1. Select from your available environment types:
1. Scroll to the bottom and click `Activate` next to your *IDOL SW license*

    ![get-license](./figs/get-license.png)
 
1. On the "License Activation" screen, at the bottom, select the check box, choose your preferred version (the latest is 12.13), then fill in the quantity to activate:

   ![eSoftware-selectLicense](./figs/eSoftware-selectLicense.png)

1. Above this section, fill in the requested details, including the MAC address and host name of the machine where you will install IDOL License Server:

   ![eSoftware-configureLicense](./figs/eSoftware-configureLicense.png)

    > IDOL License Server listens for HTTP requests from other IDOL components to provide them license seats.  The default port is `20000` but you are free to change this.

    > To obtain your MAC address and host name on Windows, open a command prompt and enter `ipconfig /all`.  Now look for the "Host Name" and "Physical Address" fields:
    >
    > ![ipconfig](./figs/ipconfig.png)
    >
    > On Linux the equivalent command is [`ifconfig`](https://man.openbsd.org/ifconfig.8).

1. Click "Next", then confirm your details and click "Submit".  You will soon received your key, which is a `.dat` file, by email.

### Install IDOL software

Follow one of these two methods to obtain and install IDOL software on your system:

- Follow [these steps](INSTALL_WIZARD.md) to install IDOL using the graphical installer (*recommended*).
- Follow [these steps](INSTALL_ZIPS.md) for a scripted installation of IDOL components (*advanced*).

### Obtaining tutorial materials

Get a local copy of this tutorial to give you all the configuration files and sample media you will need.  You can either clone this repository or download the `.zip` from [GitHub](https://github.com/microfocus-idol/idol-rich-media-tutorials).

![github-download](./figs/github-download.png)

In the following tutorials, we will assume these materials are stored under `C:\MicroFocus`.

#### Following this guide offline

You can stay on GitHub to follow the steps in this and further linked README files in your browser or, if you prefer to work with the downloaded files, see [these steps](../appendix/Markdown_reader.md) for some convenient offline reading options.

#### Validate install

If you used the installer wizard, or the scripts without altering them, your installed software will be in:

- `C:\MicroFocus\IDOLServer-12.13.0` (Windows)
- `~/IDOLServer-12.13.0` (Linux)

Each installed IDOL component will have its own sub-directory, which includes all required executables, dependencies and configuration files.  The primary configuration file for each shares the name of the component executable, *e.g.* `mediaserver.cfg` for `mediaserver.exe`.

Now let's start up License Server:

- On Windows, start the `MicroFocus-LicenseServer` Windows Service.
- On Linux, launch the startup script from the License Server directory:

  ```sh
  ./start-licenseserver.sh
  ```

To ensure IDOL License Server is running, point your browser to [`action=getLicenseInfo`](http://localhost:20000/a=getlicenseinfo).

Next start up IDOL Media Server in the same way and verify it is also running at [`action=getStatus`](http://localhost:14000/a=getstatus).

### Further reading

The admin guides for all components can be accessed from these links:

- [IDOL documentation home page](https://www.microfocus.com/documentation/idol/)
- [License Server administration guide](https://www.microfocus.com/documentation/idol/IDOL_12_13/LicenseServer_12.13_Documentation/Help/index.html)
- [Media Server administration guide](https://www.microfocus.com/documentation/idol/IDOL_12_13/MediaServer_12.13_Documentation/Guides/html/index.html)

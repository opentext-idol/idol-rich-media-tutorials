# Create your own Knowledge Discovery rich media setup

This is a setup guide for a basic installation of Knowledge Discovery rich media and associated components.

---

- [Useful third-party tools](#useful-third-party-tools)
- [Knowledge Discovery components](#knowledge-discovery-components)
  - [Generate a Knowledge Discovery license key](#generate-a-knowledge-discovery-license-key)
  - [Install Knowledge Discovery software](#install-knowledge-discovery-software)
  - [Obtaining tutorial materials](#obtaining-tutorial-materials)
    - [Following this guide offline](#following-this-guide-offline)
    - [Validate install](#validate-install)
  - [Further reading](#further-reading)

---

## Useful third-party tools

A text editor, *e.g.*:

- [VS Code](https://code.visualstudio.com/download), or
- [Notepad++](https://notepad-plus-plus.org/downloads/)

A log follower, *e.g.*:

- `tail -F` from the command line, or
- [Baretail](https://www.baremetalsoft.com/baretail/) - select the *Free Version*

## Knowledge Discovery components

Knowledge Discovery components are licensed via the Knowledge Discovery License Server application, which requires a license key.

### Generate a Knowledge Discovery license key

You can obtain software and licenses from the [Software Licensing and Downloads](https://sld.microfocus.com/mysoftware/index) portal.

1. Under the *Entitlements* tab, search for *IDOL*
1. Select from your available environment types:
1. Scroll to the bottom and click `Activate` next to your *Knowledge Discovery SW license*

    ![get-license](./figs/get-license.png)

1. On the "License Activation" screen, at the bottom, select the check box, choose your preferred version (the latest is 25.2), then fill in the quantity to activate:

   ![eSoftware-selectLicense](./figs/eSoftware-selectLicense.png)

1. Above this section, fill in the requested details, including the MAC address and host name of the machine where you will install Knowledge Discovery License Server:

   ![eSoftware-configureLicense](./figs/eSoftware-configureLicense.png)

    > NOTE: Knowledge Discovery License Server listens for HTTP requests from other Knowledge Discovery components to provide them license seats.  The default port is `20000` but you are free to change this.

    > TIP: To obtain your host name and [MAC address](https://en.wikipedia.org/wiki/MAC_address) on Windows, open a command prompt and enter `ipconfig /all`.
    >
    > Copy the value of "Host Name" at the top of the response:
    >
    > ```sh
    > > ipconfig /all
    >
    > Windows IP Configuration
    >
    > Host Name . . . . . . . . . . . . : OTX-JL82BS3
    > ```
    >
    > Scrolling down, there may be more than one physical address to choose from. Copy the value of the "Physical Address" field for the "Wireless LAN adapter Wi-Fi":
    >
    > ```sh
    > > ipconfig /all
    > ...
    > Wireless LAN adapter Wi-Fi:
    > ...
    > Physical Address. . . . . . . . . : 8C-17-59-DD-ED-52
    > ...
    > ```
    >
    > On Linux the equivalent command is [`ifconfig`](https://man.openbsd.org/ifconfig.8).

1. Click "Next", then confirm your details and click "Submit".  You will soon received your key, which is a `.dat` file, by email.

### Install Knowledge Discovery software

Follow [these steps](./INSTALL_ZIPS.md) for a scripted installation of Knowledge Discovery components.

### Obtaining tutorial materials

Get a local copy of this tutorial to give you all the configuration files and sample media you will need.  You can either clone this repository or download the `.zip` from [GitHub](https://github.com/opentext-idol/idol-rich-media-tutorials).

![github-download](./figs/github-download.png)

In the following tutorials, we will assume these materials are stored under `C:\OpenText`.

#### Following this guide offline

You can stay on GitHub to follow the steps in this and further linked README files in your browser or, if you prefer to work with the downloaded files, see [these steps](../appendix/Markdown_reader.md) for some convenient offline reading options.

#### Validate install

If you used the scripts without altering them, your installed software will be in:

- `C:\OpenText\IDOLServer-25.2.0` (Windows)
- `~/IDOLServer-25.2.0` (Linux)

Each installed Knowledge Discovery component will have its own sub-directory, which includes all required executables, dependencies and configuration files.  The primary configuration file for each shares the name of the component executable, *e.g.* `mediaserver.cfg` for `mediaserver.exe`.

Now let's start up Knowledge Discovery License Server:

- On Windows, start the `OpenText-LicenseServer` Windows Service.
- On Linux, launch the startup script from the Knowledge Discovery License Server directory:

  ```sh
  ./start-licenseserver.sh
  ```

To ensure Knowledge Discovery License Server is running, point your browser to [`action=getLicenseInfo`](http://localhost:20000/a=getlicenseinfo).

Next start up Knowledge Discovery Media Server in the same way and verify it is also running at [`action=getStatus`](http://localhost:14000/a=getstatus).

### Further reading

The admin guides for all components can be accessed from these links:

- [Knowledge Discovery documentation home page](https://www.microfocus.com/documentation/idol/)
- [License Server admin guide](https://www.microfocus.com/documentation/idol/knowledge-discovery-25.2/LicenseServer_25.2_Documentation/Help/Content/_FT_SideNav_Startup.htm)
- [Media Server admin guide](https://www.microfocus.com/documentation/idol/knowledge-discovery-25.2/MediaServer_25.2_Documentation/Help/Content/_FT_SideNav_Startup.htm)

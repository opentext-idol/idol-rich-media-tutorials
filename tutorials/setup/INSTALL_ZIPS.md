# Install Knowledge Discovery Media Server

Use a script to install Knowledge Discovery Media Server from the component `.zip` files.

---

- [Download Knowledge Discovery components](#download-knowledge-discovery-components)
- [Install](#install)
  - [Windows](#windows)
  - [Ubuntu](#ubuntu)

---

## Download Knowledge Discovery components

Download software from the [Software Licensing and Downloads](https://sld.microfocus.com/mysoftware/index) portal.

1. Under the *Downloads* tab, select your product, product name and version from the dropdowns:

    ![get-software](./figs/get-software.png)

1. From the list of available files, select and download the following (depending on your operating system):

   - `LicenseServer_25.3.0_WINDOWS_X86_64.zip` or `LicenseServer_25.3.0_LINUX_X86_64.zip`, and
   - `MediaServer_25.3.0_WINDOWS_X86_64.zip` or `MediaServer_25.3.0_LINUX_X86_64.zip`.

    ![get-idol-zips](./figs/get-idol-zips.png)

## Install

Installation scripts are included in this tutorial for Windows (`install.bat`) and Linux (`install.sh`).

Before running the appropriate script, open it and check the following:

1. the `SOURCE_DIR` variable is pointed correctly at the directory where you have placed your `.zip` files and license key file, *e.g.* in `install.sh` for Linux this is assumed to be:

    ```sh
    SOURCE_DIR="~/Downloads"
    ```

1. the `LICENSE_KEY` variable gives the correct name for your license `.dat` file.

### Windows

You must edit a system environment variable in order to run Media Server as a Windows Service.

Add the target installation directory (`C:\OpenText\IDOLServer-25.3.0\MediaServer\libs\torch`) to your System Path environment variable as follows:

![torch_env](./figs/torch_env.png)

> NOTE: Please refer to the [admin guide](https://www.microfocus.com/documentation/idol/knowledge-discovery-25.3/MediaServer_25.3_Documentation/Help/Content/Getting_Started/StartMediaServer.htm) for more details.

Run `install.bat` with administrator privileges:

- right click
- select 'Run as administrator'

### Ubuntu

Run the following command to execute the installation script:

```sh
sudo ./install.sh
```

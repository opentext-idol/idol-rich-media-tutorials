# Rich Media Tutorials

A set of guides to introduce you to IDOL Media Server and associated components.

---

- [Taster](#taster)
- [Getting started](#getting-started)
  - [Recommended setup requirements](#recommended-setup-requirements)
  - [Setup IDOL Media Server](#setup-idol-media-server)
- [Introduction](#introduction)
- [Analytics showcase examples](#analytics-showcase-examples)
- [Further reading](#further-reading)
  - [Example configurations](#example-configurations)
  - [IDOL Media Server for OEM](#idol-media-server-for-oem)
  - [Hints and Tips](#hints-and-tips)
  - [Links](#links)

---

## Taster

A quick first look at IDOL Media Server.  Watch a demonstration video where IDOL Media Server's training GUI is used to quickly configure custom alert rules for a fun video.

[Watch](https://www.youtube.com/watch?v=Wl-uYCADreo&list=PLlUdEXI83_Xoq5Fe2iUnY8fjV9PuX61FA).

![youtube](https://img.youtube.com/vi/Wl-uYCADreo/hqdefault.jpg)

## Getting started

### Recommended setup requirements

- 8 cores, 16 GB RAM and 50GB free disk space.
- 64-bit Windows or Linux (this guide has been most recently tested on Windows 11 and Ubuntu 22.04).
- A text editor.
- Administrator privileges to install software.
- A webcam.

> NOTE: Sizing IDOL Media Server for your own production tasks depends greatly on your use case, as discussed [later in these tutorials](showcase/face-recognition/README.md#hardware-requirements).  Please refer to the [admin guide](https://www.microfocus.com/documentation/idol/IDOL_23_4/MediaServer_23.4_Documentation/Help/Content/Getting_Started/Install_Run/System_Requirements.htm) for more details.

### Setup IDOL Media Server

> NOTE: Do this before starting any tutorials.

Follow [these steps](setup/SETUP.md) to install IDOL Media Server and get ready to run the tutorials.

## Introduction

> NOTE: Everyone should do this tutorial.

Make a serious start with rich media analytics, using face analytics as our guiding example.  This end-to-end course takes you from your first IDOL Media Server configuration to running your own app, which makes use of IDOL Media Server as an analytics service.  All you need is a webcam (and a few hours of your time)!

[Get started](introduction/README.md).

## Analytics showcase examples

> NOTE: These guides assume some familiarity with IDOL Media Server concepts.

Dip into any of the showcase guides to try more analytics. These are grouped into categories:

- General interest
- Focus on CCTV analytics
- Focus on broadcast monitoring
- Focus on document processing

[Get started](showcase/README.md).

## Further reading

### Example configurations

Many more example analysis configurations are provided with your IDOL Media Server installation, under `configurations/examples`.  Now you know your IDOL Media Server, you can use these as inspiration for our own use cases!

### IDOL Media Server for OEM

When IDOL Media Server is used in OEM, communication requires the ACI API.  See our [IDOL OEM tutorial](https://github.com/microfocus-idol/idol-oem-tutorials) to learn more.

### Hints and Tips

- Working with audio, images and video. [Read more](appendix/Media_tips.md).
- Scripting in Lua. [Read more](appendix/Lua_tips.md).
- XSL transforms. [Read more](appendix/XSL_tips.md).

### Links

- Full administration guides are available for all IDOL products [here](https://www.microfocus.com/documentation/idol/).
- Read more tips on working with IDOL products in [IDOL Expert](https://www.microfocus.com/documentation/idol/IDOL_23_4/IDOLServer_23.4_Documentation/Guides/html/expert/Content/IDOLExpert_Welcome.htm).
- For details of the latest changes to IDOL Media Server, please see the [Release Notes](https://www.microfocus.com/documentation/idol/IDOL_23_4/IDOLReleaseNotes_23.4_Documentation/idol/Content/Servers/MediaServer.htm).
- To learn more about IDOL Media Server and other IDOL products, visit [microfocus.com/idol](https://www.microfocus.com/en-us/products/information-data-analytics-idol/overview).

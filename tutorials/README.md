# Rich Media Tutorials

A set of guides to introduce you to Knowledge Discovery Media Server and associated components.

---

- [Taster](#taster)
- [Getting started](#getting-started)
  - [Recommended setup requirements](#recommended-setup-requirements)
  - [Setup Knowledge Discovery Media Server](#setup-knowledge-discovery-media-server)
- [Introduction](#introduction)
- [Analytics showcase examples](#analytics-showcase-examples)
- [Further reading](#further-reading)
  - [Example configurations](#example-configurations)
  - [Knowledge Discovery Media Server for OEM](#knowledge-discovery-media-server-for-oem)
  - [Hints and Tips](#hints-and-tips)
  - [Links](#links)

---

## Taster

A quick first look at Knowledge Discovery Media Server.  Watch a demonstration video where Knowledge Discovery Media Server's training GUI is used to quickly configure custom alert rules for a fun video.

[Watch](https://www.youtube.com/watch?v=Wl-uYCADreo&list=PLlUdEXI83_Xoq5Fe2iUnY8fjV9PuX61FA).

![youtube](https://img.youtube.com/vi/Wl-uYCADreo/hqdefault.jpg)

## Getting started

### Recommended setup requirements

- 8 cores, 16 GB RAM and 50GB free disk space.
- 64-bit Windows or Linux (this guide has been most recently tested on Windows 11 and Ubuntu 22.04).
- A text editor.
- Administrator privileges to install software.
- A webcam.

> NOTE: Sizing Knowledge Discovery Media Server for your own production tasks depends greatly on your use case, as discussed [later in these tutorials](./showcase/face-recognition/README.md#hardware-requirements).  Please refer to the [admin guide](https://www.microfocus.com/documentation/idol/knowledge-discovery-25.1/MediaServer_25.1_Documentation/Help/Content/Getting_Started/Install_Run/System_Requirements.htm) for more details.

### Setup Knowledge Discovery Media Server

> NOTE: Do this before starting any tutorials.

Follow [these steps](./setup/SETUP.md) to install Knowledge Discovery Media Server and get ready to run the tutorials.

## Introduction

> NOTE: Everyone should do this tutorial.

Make a serious start with rich media analytics, using face analytics as our guiding example.  This end-to-end course takes you from your first Knowledge Discovery Media Server configuration to running your own app, which makes use of Knowledge Discovery Media Server as an analytics service.  All you need is a webcam (and a few hours of your time)!

[Get started](./introduction/README.md).

## Analytics showcase examples

> NOTE: These guides assume some familiarity with Knowledge Discovery Media Server concepts.

Dip into any of the showcase guides to try more analytics. These are grouped into categories:

- [General interest](./showcase/README.md#general-interest)
- [Focus on CCTV analytics](./showcase/README.md#focus-on-cctv-analytics)
- [Focus on broadcast monitoring](./showcase/README.md#focus-on-broadcast-monitoring)
- [Focus on document processing](./showcase/README.md#focus-on-document-processing)

## Further reading

### Example configurations

Many more example analysis configurations are provided with your Knowledge Discovery Media Server installation, under `configurations/examples`.  Now you know your Knowledge Discovery Media Server, you can use these as inspiration for our own use cases!

### Knowledge Discovery Media Server for OEM

When Knowledge Discovery Media Server is used in OEM, communication requires the ACI API.  See our [Knowledge Discovery OEM tutorial](https://github.com/opentext-idol/idol-oem-tutorials) to learn more.

### Hints and Tips

- Working with audio, images and video. [Read more](./appendix/Media_tips.md).
- Scripting in Lua. [Read more](./appendix/Lua_tips.md).
- XSL transforms. [Read more](./appendix/XSL_tips.md).

### Links

- Full administration guides are available for all Knowledge Discovery products [here](https://www.microfocus.com/documentation/idol/).
- Read more tips on working with Knowledge Discovery products in [Knowledge Discovery Expert](https://www.microfocus.com/documentation/idol/knowledge-discovery-25.1/IDOLServer_25.1_Documentation/Guides/html/expert/Content/IDOLExpert_Welcome.htm).
- For details of the latest changes to Knowledge Discovery Media Server, please see the [Release Notes](https://www.microfocus.com/documentation/idol/knowledge-discovery-25.1/IDOLReleaseNotes_25.1_Documentation/idol/Content/Servers/MediaServer.htm).
- To learn more about Knowledge Discovery Media Server and other Knowledge Discovery products, visit [opentext.com/idol](https://www.opentext.com/products/knowledge-discovery).

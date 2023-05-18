# XSL transform tips

---

- [Introduction](#introduction)
- [Uses with Media Server](#uses-with-media-server)
  - [Formatting process output](#formatting-process-output)
  - [Formatting synchronous server responses](#formatting-synchronous-server-responses)
- [People Counting app example](#people-counting-app-example)
  - [The XSL stylesheet](#the-xsl-stylesheet)
  - [Output method](#output-method)
  - [Removing unwanted whitespace](#removing-unwanted-whitespace)
  - [Applying templates](#applying-templates)
    - [Main template](#main-template)
    - [Section templates](#section-templates)
    - [Null templates](#null-templates)
- [Developing templates](#developing-templates)
  - [Obtaining a source sample](#obtaining-a-source-sample)
  - [Test running XSL transforms](#test-running-xsl-transforms)
  - [Our first iteration](#our-first-iteration)
- [Next steps](#next-steps)

---

## Introduction

XSL (eXtensible Stylesheet Language) is a styling language for XML.  XSL transformations (XSLT) are commonly used on the web to reformat XML data, *e.g.* to publish that data as an HTML page.  These transforms make use of the XPath query language to navigate through elements and attributes in an XML document.  For a general introduction to XSL transforms, [w3schools](https://www.w3schools.com/xml/xsl_intro.asp) has a good beginners tutorial.  For key concepts that are commonly used with Media Server, read on.

## Uses with Media Server

### Formatting process output

In Media Server land, we use XSL extensively to customize the XML records produced by output engines.  Many such XSL templates can be found in your `configurations/xsl` directory.

### Formatting synchronous server responses

XSL templates are also commonly employed across many IDOL components to reformat ACI responses.  Media Server also includes some such templates in the `acitemplates` directory.  For a simple example, compare the difference between the following two Media Server requests:

- <http://localhost:14000/a=getExampleRecord&engineType=ColorCluster>
- <http://localhost:14000/a=getExampleRecord&engineType=ColorCluster&template=getExampleRecord>

## People Counting app example

Let's walk through the XSL transform we used in the people counting app in [PART IV](../introduction/PART_IV.md#receiving-alerts) of the introductory tutorial.  You can find the full file under `introduction/peopleCounter/toPeopleCounter.xsl`.

### The XSL stylesheet

XSL transforms are defined with valid XML.  They require the following minimal headers and wrapping node.

```xml
<?xml version='1.0'?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

  <!-- CONTENTS GO HERE -->

</xsl:stylesheet>
```

> Media Server supports XSL version 1.0.

### Output method

Common output formats are HTML, XML and text. The first two methods can optionally be output with hierarchical indentations, *e.g.*

```xml
<xsl:output method="html" version="4.0" encoding="UTF-8" indent="yes"/>
```

For the people counting app, we want to send JSON data.  For this, we can choose `text` output as follows:

```xml
<xsl:output method="text" version="4.0" encoding="UTF-8"/>
```

### Removing unwanted whitespace

XSL preserves whitespace around all source element content by default.  We can remove all of this with the following:

```xml
<xsl:strip-space elements="*"/>
```

### Applying templates

XSL templates can quickly become quite complex.  It is useful to separate logic into `xsl:template`s which are each responsible for parsing a particular node, or set of nodes, in the source XML.

#### Main template

In the main template, we attach to the root node of the source XML, then call `xsl:apply-templates` on all sub nodes that we want to parse, *i.e.* as follows:

```xml
<xsl:template match="/output">
  <xsl:apply-templates select="metadata/segment/importantRecord"/>
</xsl:template>
```

, remembering that the output XML looks like:

```xml
<output>
  <metadata>
    <session>...</session>
    <segment>
      ...
      <importantRecord>...</importantRecord>
    </segment>
  </metadata>
  <results>...</results>
</output>
```

#### Section templates

In this example we only want to parse one node, the `importantRecord`, which has the following structure:

```xml
<importantRecord>
  <timestamp>
    <startTime iso8601="2018-06-26T13:01:38.153736Z">1530018098153736</startTime>
    <duration iso8601="PT00H00M10.289000S">10289000</duration>
    <peakTime iso8601="2018-06-26T13:01:39.656736Z">1530018099656736</peakTime>
    <endTime iso8601="2018-06-26T13:01:48.442736Z">1530018108442736</endTime>
  </timestamp>
  <trackname>FaceTracker.Result</trackname>
  <FaceResult>
    <id>0c10e6d0-6ada-48fc-ac65-671bb41449c4</id>
    <face>
      <region>
        <left>380</left>
        <top>206</top>
        <width>190</width>
        <height>190</height>
      </region>
      <outOfPlaneAngleX>0</outOfPlaneAngleX>
      <outOfPlaneAngleY>0</outOfPlaneAngleY>
      <percentageInImage>100</percentageInImage>
      <ellipse>
        <center>
          <x>474.67511</x>
          <y>300.666016</y>
        </center>
        <a>77.0538788</a>
        <b>107.875435</b>
        <angle>-5.45241642</angle>
      </ellipse>
      <lefteye>
        <center>
          <x>502.76</x>
          <y>270.48</y>
        </center>
        <radius>11</radius>
      </lefteye>
      <righteye>
        <center>
          <x>441.39</x>
          <y>276.34</y>
        </center>
        <radius>12</radius>
      </righteye>
    </face>
  </FaceResult>
</importantRecord>
```

We will create a template to parse the `FaceResult` sub-node of `importantRecord`.  Here is that template:

```xml
<xsl:template match="FaceResult">

  <xsl:variable name="trackName" select="../trackname"></xsl:variable>
  <xsl:variable name="duration" select="../timestamp/duration"></xsl:variable>

  <xsl:text>{ </xsl:text>
  <xsl:text>"eventType" : "</xsl:text><xsl:value-of select="substring-after($trackName, '.')"/><xsl:text>"</xsl:text>
  <xsl:text>, </xsl:text>
  <xsl:text>"elapsedMSec" : </xsl:text><xsl:value-of select="$duration div 1000"/>
  <xsl:text> }</xsl:text>

</xsl:template>
```

This method reads (or *selects*) two variables form the XML, namely the track name and track duration and uses their values to initialize two variables.

The output part of the method relies on `xsl:text` elements to construct the framing JSON syntax we want and then `xsl:value-of` elements to fill in the variables.  In doing so we can also perform simple mathematical or string manipulations on those values.  Here we take the track name before the '.' and we convert the tracking duration from microseconds to milliseconds.

```json
{ "eventType" : "Result", "elapsedMSec" : 10289 }
```

#### Null templates

Our `importantRecord` contains additional sub-nodes that we do not need to process.  By default, the XSL template would simply copy the contents of these nodes into the output.  To stop this happening we can define a null template and apply it onto those nodes with a `match` criteria:

```xml
<xsl:template match="timestamp|trackname"/>
```

## Developing templates

My preferred approach for developing a new XSL transform is the following:

1. Get an example source XML file from Media Server output
1. Take an existing XSL transform
1. Iterate changes until you achieve your aims

### Obtaining a source sample

When we ran the XSL transform for the people counting app in [PART IV](../introduction/PART_IV.md#running-the-app) of the introductory tutorial, we configured the output engine to store XML before the transform with the following lines:

```ini
SavePreXML = True
XMLOutputPath = output/toPeopleCounter/%session.token%/%segment.type%_%segment.sequence%_%segment.endTime.timestamp%.xml
```

You can go to this directory and copy one of those files, *e.g.* `pre_2_20180626-134615.xml` into your `introduction/peopleCounter` folder.

### Test running XSL transforms

To make iterative testing faster, you can avoid the need to keep reprocessing your source with Media Server, *e.g.* on Windows by using a free command line tool `msxsl.exe` from Microsoft, and included in the folder next to this README.

To run the transformation from your `introduction/peopleCounter` folder, download the command line tool and copy it here, then do:

```sh
msxsl.exe pre_2_20180626-134615.xml toPeopleCounter.xsl -o out.json
```

Open the `out.json` to see the results.

### Our first iteration

Let's make one change to the transform together now.  Make a copy of the existing transform and call it `toPeopleCounter2.xsl`.

Now, add an additional line to get the face width:

```xml
<xsl:text>{ </xsl:text>
<xsl:text>"eventType" : "</xsl:text><xsl:value-of select="substring-after($trackName, '.')"/><xsl:text>"</xsl:text>
<xsl:text>, </xsl:text>
<xsl:text>"elapsedMSec" : </xsl:text><xsl:value-of select="$duration div 1000"/>
<xsl:text>, </xsl:text>
<xsl:text>"faceWidth" : </xsl:text><xsl:value-of select="face/region/width"/>
<xsl:text> }</xsl:text>
```

Re-run the command line tool to see the new results:

```sh
$ msxsl.exe pre_2_20180626-134615.xml toPeopleCounter2.xsl

{ "eventType" : "Result", "elapsedMSec" : 10289, "faceWidth" : 190 }
```

Now you are ready to collect any nodes you wish from this source XML.

## Next steps

Why not try some tutorials to explore some of the analytics available in Media Server, linked from the [main page](../../README.md).

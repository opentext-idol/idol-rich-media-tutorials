# PART I - Use an out-of-the-box classifier

In this tutorial we will use the IDOL Media Server GUI to:

1. import pre-trained classes to enable classification (labelling) of common types in a test image,
1. build and run a process configuration to label a random image from Flickr.

This guide assumes you have already familiarized yourself with IDOL Media Server by completing the [introductory tutorial](../../README.md#introduction).

If you want to start here, you must at least follow these [installation steps](../../setup/SETUP.md) before continuing.

---

- [Setup](#setup)
  - [Configure IDOL Media Server](#configure-idol-media-server)
    - [Enabled modules](#enabled-modules)
    - [Licensed channels](#licensed-channels)
- [Training Image Classifiers](#training-image-classifiers)
  - [Import pre-defined classifiers](#import-pre-defined-classifiers)
- [Process configuration](#process-configuration)
  - [Obtaining a random test image](#obtaining-a-random-test-image)
  - [Config file](#config-file)
- [Running our analysis](#running-our-analysis)
- [PART II - Build a custom classifier](#part-ii---build-a-custom-classifier)

---

## Setup

### Configure IDOL Media Server

IDOL Media Server must be licensed for visual analytics, as described in the [introductory tutorial](../../introduction/PART_I.md#enabling-analytics).  To reconfigure IDOL Media Server you must edit your `mediaserver.cfg` file.

#### Enabled modules

The `Modules` section is where we list the engines that will be available to IDOL Media Server on startup.  Ensure that this list contains the module `imageclassification`:

```ini
[Modules]
Enable=...,imageclassification,...
```

#### Licensed channels

The `Channels` section is where we instruct IDOL Media Server to request license seats from IDOL License Server.  To enable *Image Classification* for this tutorial, you need to enable at least one channel of type *Visual*:

```ini
[Channels]
...
VisualChannels=1
```

> NOTE: For any changes you make in `mediaserver.cfg` to take effect you must restart IDOL Media Server.

## Training Image Classifiers

OpenText provides a set of pre-defined training packs for IDOL Media Server, including image classifiers. IDOL Media Server also allows you to train your own classifiers by uploading and labelling your own images.

That training can be performed through IDOL Media Server's web API, detailed in the [reference guide](https://www.microfocus.com/documentation/idol/IDOL_24_2/MediaServer_24.2_Documentation/Help/index.html#Actions/Training/_ImageClassification.htm).  For smaller projects, demos and testing, you may find it easier to use the [`gui`](http://localhost:14000/a=gui) web interface.

### Import pre-defined classifiers

Pre-trained *Image Classification* packages are distributed separately from the main IDOL Media Server installer.  To obtain the training pack, return to the [Software Licensing and Downloads](https://sld.microfocus.com/mysoftware/index) portal, then:

1. Under the *Downloads* tab, select your product, product name and version from the dropdowns:

    ![get-software](../../setup/figs/get-software.png)

1. From the list of available files, select and download `MediaServerPretrainedModels_24.2.0_COMMON.zip`.

    ![get-pretrained-zip](../../setup/figs/get-pretrained-zip.png)

Extract the training pack `.zip` then, to load one of the classifiers, open the IDOL Media Server GUI at [`/action=gui`](http://127.0.0.1:14000/a=gui#/train/imageClass(tool:select)) and follow these steps:

1. in the left column, click `Import`
1. navigate to your extracted training pack and select `ImageClassifier_Imagenet.dat`

    ![import-pretrained-classifier](./figs/import-pretrained-classifier.png)

1. wait a few minutes for the import to complete.  You are now ready to classify media.

This classifier contains 1000 classes (from "abucus" to "zucchini") and was built from the [ImageNet](https://www.image-net.org/index.php) set of labelled images.  

This word-cloud gives an indication of the relative abundance of labels in that training set:

![imagenet-wordcloud](./figs/imagenet-wordcloud.png)

## Process configuration

### Obtaining a random test image

A fun source of random photographs is the [Lorem Flickr](https://loremflickr.com/) project.  To obtain a random kitten photo for example, try <https://loremflickr.com/320/240/kitten>.  Here's one obtained earlier:

![random-image](./kitten.jpg)

### Config file 

Let's build a process configuration using the interactive [config builder](http://localhost:14000/a=gui#/process).

To analyze an image file, include the following engines:

1. Click the `Add Engine` button, then select the *Image*-type ingest engine:

    ![config-ingest](./figs/config-ingest.png)

1. Next, to classify the image, add the *Image Classification*-type analysis engine:

    ![config-analyze](./figs/config-analyze.png)

1. You will now be prompted to specify the classifier to use.  Select the imported `ImageClassifier_ImageNet` from the dropdown menu:

    ![config-classifier](./figs/config-classifier.png)

    > NOTE: For full details on this and other available options for *Image Classification*, please read the [reference guide](https://www.microfocus.com/documentation/idol/IDOL_24_2/MediaServer_24.2_Documentation/Help/index.html#Configuration/Analysis/ImageClass/_ImageClassification.htm).

1. Let's output the results to disk.  Add the "XML"-type output engine to do that:

    ![config-output](./figs/config-output.png)

1. Finally, you need to now set the output path.  With the `[XMLOutput]` section selected, click `Show` to reveal the available configuration parameters.  Set the "Xml Output Path" parameter to `output/%source.filename.stem%.xml`:

    ![config-classifier](./figs/config-output-path.png)

## Running our analysis

Still in the *Configuration Builder* page, click the `Run` button to open the source selection dialog.

Locate an image file to process, *e.g.* the example image from LoremFlickr included in this tutorial.

![process-source](./figs/process-source.png)

Click "Run" to launch the process:

![process-run](./figs/process-run.png)

To review the results, go to IDOL Media Server's `output` directory to find `kitten.xml`.

Open this file to see the classification results.  Within this XML, note the `<ImageClassificationResult>` tags, which contain the class labels for this image.  In this case, three cat-like classes from ImageNet have been matched:

```xml
<record>
  <pageNumber>1</pageNumber>
  <trackname>ImageClassificationEngine.Result</trackname>
  <ImageClassificationResult>
    <id>374727aa-d90c-4b19-aa78-dd80c07afa04</id>
    <classification>
      <identifier>tabby, tabby cat</identifier>
      <confidence>49.63</confidence>
    </classification>
    <classifier>ImageClassifier_Imagenet</classifier>
  </ImageClassificationResult>
</record>
<record>
  <pageNumber>1</pageNumber>
  <trackname>ImageClassificationEngine.Result</trackname>
  <ImageClassificationResult>
    <id>374727aa-d90c-4b19-aa78-dd80c07afa04</id>
    <classification>
      <identifier>tiger cat</identifier>
      <confidence>22.66</confidence>
    </classification>
    <classifier>ImageClassifier_Imagenet</classifier>
  </ImageClassificationResult>
</record>
<record>
  <pageNumber>1</pageNumber>
  <trackname>ImageClassificationEngine.Result</trackname>
  <ImageClassificationResult>
    <id>374727aa-d90c-4b19-aa78-dd80c07afa04</id>
    <classification>
      <identifier>Egyptian cat</identifier>
      <confidence>15.07</confidence>
    </classification>
    <classifier>ImageClassifier_Imagenet</classifier>
  </ImageClassificationResult>
</record>
```

> NOTE: This image labelling can be used to facilitate image search, where:
> - the image can be retrieved from the search term "Egyptian cat". and
> - the image can be used to generate a query looking for documents (and other images) about Egyptian cats.

## PART II - Build a custom classifier

Start [here](PART_II.md).

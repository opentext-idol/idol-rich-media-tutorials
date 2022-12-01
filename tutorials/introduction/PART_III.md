# PART III - People counting: an example of app integration

In this tutorial we will:

1. run a simple *people counting* application (using `node.js`) that makes use of Media Server as an analytical service
1. create a template process configuration file to be customized at runtime by the app
1. configure Media Server's output engine with XSL to send `FaceDetect` events to the app for processing

---
<!-- TOC -->

- [Exploring the app](#exploring-the-app)
  - [Runtime configuration](#runtime-configuration)
  - [Managing processes](#managing-processes)
  - [Receiving alerts](#receiving-alerts)
- [Application logic](#application-logic)
- [Running the app](#running-the-app)
- [Conclusion](#conclusion)

<!-- /TOC -->
---

## Exploring the app

The app lives in the included `peopleCounter` folder.  Soon we will run the entry point `app.js` file to launch the app but first, let's explore what it does and, in so doing, see some of the key features of Media Server that facilitate integration with third-party applications.

These key features are:

1. How to direct Media Server to process content
1. How to remotely manage processes running in Media Server
1. How to customize Media Server output to meet your requirements

### Runtime configuration

So far in these tutorials, when launching a process action, we have defined the process configuration with `configName=<FILE_NAME>`.  This references a file stored under your `configurations` directory and is therefore fixed.  In an application, you may want to modify some settings at runtime, *e.g.* based on a user setting the minimum face size or defining a region of interest.  To provide this flexibility, Media Server also allows you to send a session configuration file in the process action, *e.g.* as a [base-64 encoded](https://en.wikipedia.org/wiki/Base64#URL_applications) string, using `config=<BASE_64_STRING>` in the process request.  Please read the [reference guide](https://www.microfocus.com/documentation/idol/IDOL_12_13/MediaServer_12.13_Documentation/Help/index.html#Actions/VideoAnalysis/Process.htm) for details.

In this app, our runtime options are defined in `options.js`.  These are used to fill in a templated process configuration file `mediaserver/peopleCounter.tmpl.cfg`, which is then base-64 encoded and sent to Media Server.  One way to achieve this in `node.js` is with standard JavaScript [templated strings](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Template_literals), *e.g.*:

```javascript
const cfgTmpl = fs.readFileSync(cfgFile, 'utf8'), // read the templated config file
  cfg = eval(`\`${cfgTmpl}\``),                   // process the template to create a plain text config
  bsf = new Buffer(cfg).toString('base64'),       // create a base 64 encoded string
  path = '/action=process' +
    '&source=video=USB Video Device' +
    `&config=${encodeURIComponent(bsf)}` +        // make the encoded string URI safe
    '&responseFormat=JSON';
```

### Managing processes

As you know, the `/action=process` request returns a unique token (returned, as directed above, in JSON format).  This token can be used by the people counting app to poll the process for status updates and to stop the process, *e.g.* if requested by the user (by pressing `Ctrl-C` with the command window in focus).

```javascript
var path = '/action=queueinfo&queueaction=GETSTATUS' +
      `&queuename=process&token=${token}`;
```

```javascript
var path = '/action=queueinfo&queueaction=STOP' +
      `&queuename=process&token=${token}`;
```

Other queue actions are available, including `PAUSE` and `RESUME`, as well as `PROGRESS` (only relevant for sources with known length, *i.e.* files).  Please read the [reference guide](https://www.microfocus.com/documentation/idol/IDOL_12_13/MediaServer_12.13_Documentation/Help/index.html#Actions/General/_ACI_QueueInfo.htm) for details.

### Receiving alerts

The people counting app's template process configuration includes an output engine that instructs Media Server to send `FaceDetect` records form the *Start* and *Result* tracks to the app server in the body of an HTTP POST request:

```ini
[Session]
...
Engine2 = ToPeopleCounter

[ToPeopleCounter]
Type = httppost
Mode = singleRecord
Input = FaceTracker.Start,FaceTracker.Result
DestinationURL = http://${appHost}:${appPort}/api/v1?addFaceTrackingEvent
```

The people counting app API expects to receive data in the HTTP POST request body in the form:

```json
{ "eventType" : "Start", "elapsedMSec" : 0 }
```

```json
{ "eventType" : "Result", "elapsedMSec" : 3210 }
```

To meet this requirement, a custom XSL transform `toPeopleCounter.xsl` has been included to convert Media Server's XML output to the required format.  See [tips on XSL transforms](../appendix/XSL_tips.md) for more information.

Copy `toPeopleCounter.xsl` into the `configurations/xsl` directory. The output engine then requires further configuration to make use of that `.xsl` file:

```ini
XSLTemplate = toPeopleCounter.xsl
```

Finally, we can also configure out output engine to save both the original XML and the converted JSON data to disk, so we can look at them both later.  These files will be stored, as directed, under `output/toPeopleCounter`.

```ini
SavePreXML = True
XMLOutputPath = output/toPeopleCounter/%session.token%/%segment.type%_%segment.sequence%_%segment.endTime.timestamp%.xml
```

## Application logic

Our people counting app can now send runtime configurations to Media Server, has the tools to monitor and manage on-going processes and will receive alerts in a tailored format.  We are now free to concentrate on the application logic itself, *i.e.* what do we want to acheive?

On receipt of a face tracking event from Media Server, we want to update three quantities:

1. The total number of people seen so far, *i.e.* the sum of *Start*-type events received.
1. The number of people currently being tracked, *i.e.* the difference between the number of *Start*- and *Result*-type events received.
1. The average track duration, *i.e.* the average of the track durations received from the *Result*-type events.

## Running the app

This app depends on having `node.js` installed.  Please follow these [instructions](../setup/NODE_JS.md) if you do not already have it on your system.

To launch the app, open a command prompt and execute the following instruction:

```sh
$ node app.js

2019-03-29 11:36:53.696 [listener] peopleCounter has started on port 4000.
2019-03-29 11:36:56.932 [checkProgress] Media Server process state: 'Processing'
```

We will see counts being output to the command window:

```sh
2019-03-29 11:37:05.379 [count] Cumulative count: 2
2019-03-29 11:37:05.383 [count] Tracking now: 1
2019-03-29 11:37:05.387 [count] Average duration (seconds): 5.3
```

You can make use of all the now familiar resources to monitor Media Server, such as [`/action=GUI`](http://localhost:14000/a=gui#/monitor(tool:options)).

To trigger a new count, get your neighbor to look in your webcam or interrupt the tracking by covering your webcam.  When you're satisfied, stop the app with [`Ctrl-C`].  The app will instruct Media Server to stop processing before it exits.

## Conclusion

Over these introductory tutorials, we have built up a fundamental understanding of the inner workings of Media Server, from ingest through multiple levels of processing to transformations, encoding and output.  We have also run an application that integrates Media Server as an analytical service.  Why not try more tutorials to explore some of the other analytics available in Media Server, linked from the [main page](../README.md).

# Rich media tips

---

- [Useful third-party software](#useful-third-party-software)
- [Collecting sample media](#collecting-sample-media)
  - [Video file and streamed sources from the web](#video-file-and-streamed-sources-from-the-web)
    - [Live YouTube channels](#live-youtube-channels)
  - [CCTV camera streams](#cctv-camera-streams)
  - [Academic datasets](#academic-datasets)
- [Working with video sources](#working-with-video-sources)
  - [Devices](#devices)
  - [Video files](#video-files)
    - [Examine the metadata of a video file](#examine-the-metadata-of-a-video-file)
    - [Extract still images from a video file](#extract-still-images-from-a-video-file)
    - [Split a video into shorter clips](#split-a-video-into-shorter-clips)
    - [Make a video clip of an interesting section](#make-a-video-clip-of-an-interesting-section)
    - [Concatenate video clips into one video file](#concatenate-video-clips-into-one-video-file)
    - [Ingest a sequence of videos as a playlist](#ingest-a-sequence-of-videos-as-a-playlist)
    - [Add tracks to existing media file](#add-tracks-to-existing-media-file)
    - [Strip tracks to existing media file](#strip-tracks-to-existing-media-file)
  - [Video streams](#video-streams)
    - [Test availability of an IP stream](#test-availability-of-an-ip-stream)
    - [Record video/audio from an IP stream](#record-videoaudio-from-an-ip-stream)
    - [Loop a video file to produce a continuous RTSP stream](#loop-a-video-file-to-produce-a-continuous-rtsp-stream)
  - [YouTube](#youtube)
    - [Download a video from YouTube](#download-a-video-from-youtube)
    - [Play a live YouTube channel](#play-a-live-youtube-channel)
    - [Record video/audio from a live YouTube channel](#record-videoaudio-from-a-live-youtube-channel)
    - [Restream video/audio from a live YouTube channel](#restream-videoaudio-from-a-live-youtube-channel)
- [Next steps](#next-steps)

---

## Useful third-party software

- A text editor, *e.g.* [VS Code](https://code.visualstudio.com/download), [Notepad++](https://notepad-plus-plus.org/)
- A video player, *e.g.* [VLC](http://www.videolan.org/vlc/), [ffmpeg](https://ffmpeg.org/download.html)
- A video editor, *e.g.* [ffmpeg](https://ffmpeg.org/download.html)
- A screen recorder, *e.g.* with the [Xbox Game Bar](https://support.xbox.com/en-GB/help/friends-social-activity/share-socialize/record-game-clips-game-bar-windows-10) included with Windows 10, or [ffmpeg](https://ffmpeg.org/download.html)
- A scripting language, *e.g.* [node.js](https://nodejs.org/), [python](https://www.python.org/downloads/)
- A better terminal for Windows, *e.g.* [GitBash](https://gitforwindows.org/) (even better with [Cmder](https://cmder.app/) or [Windows Terminal](https://apps.microsoft.com/store/detail/windows-terminal/9N0DX20HK701))

## Collecting sample media

Typically, you will be able to get audio, video or image samples from your customer. If not you have (at least) these choice:

1. Use a webcam - see the setup guide to learn how to [connect](../setup/WEBCAM.md).
1. Make use of open data shared by the academic community, see [below](#academic-datasets).
1. Search for rights-free media on the web, *e.g.* [pexels.com](https://www.pexels.com/).
1. Download video files or stream video from YouTube, *e.g.* as described [below](#download-a-video-from-youtube).
1. Connect to a video file or stream embedded in a website, *e.g.* from a news broadcaster's website, as described [below](#video-stream-sources-from-the-web).

### Video file and streamed sources from the web

There exist many free news streams on the web that you can connect to.  Often news websites include a "Live" page where you can view the channel in your browser.  Under the hood, the page is often requesting an HLS stream index `.m3u8` file.  We can identify these files by manually inspecting websites, *i.e.* by pressing `F12` and filtering on files downloaded in the Network tab. 

![m3u8.png](./figs/m3u8.png)

> While IDOL Media Server's Video ingest engine does support `https` on Windows, *it does not on Linux*.  Luckily, you can often change the URL protocol to `http` and it will still work, *e.g.* <https://live-hls-web-aje.getaj.net/AJE/03.m3u8> seen in the above screenshot can be safely changed to <http://live-hls-web-aje.getaj.net/AJE/03.m3u8>, as listed in the table below.

The following streams were working at time of writing.

Language | Broadcaster | Resolution | Link
--- | --- | --- | ---
Arabic | Al Jazeera | 960x540 | http://live-hls-web-aja.getaj.net/AJA/03.m3u8
English | Al Jazeera | 960x540 | http://live-hls-web-aje.getaj.net/AJE/03.m3u8
English | CBS News | 640x360 | http://cbsn-us.cbsnstream.cbsnews.com/out/v1/55a8648e8f134e82a470f83d562deeca/master_11.m3u8
German | DW | 720x400 | http://dwamdstream106.akamaized.net/hls/live/2017965/dwstream106/stream04/streamPlaylist.m3u8
Spanish | RTVE 24h | 1024x576 | http://rtvelivestream-clnx.rtve.es/rtvesec/24h/24h_main_576.m3u8

These streams can be directly ingested by IDOL Media Server using the the multi-purpose [Video](https://www.microfocus.com/documentation/idol/IDOL_24_2/MediaServer_24.2_Documentation/Help/index.html#Configuration/Ingest/Libav/_Libav.htm) type ingest engine, as we do in the Speech to Text [tutorial](../showcase/speech-transcription/PART_I.md#process-a-news-channel-stream).

#### Live YouTube channels

Increasingly, broadcasters are offering live streaming news via YouTube.  Some examples working at time of writing:

Language | Broadcaster | Resolution | Link
--- | --- | --- | ---
Chinese | CCTV 4 | 1920x1080 (max) | https://www.youtube.com/watch?v=4AnywZLPBAg
French | France 24 | 1024x576 | https://www.youtube.com/watch?v=6x7lV6E32lA
Hindi | NDTV | 1920x1080 (max) | https://www.youtube.com/watch?v=MN8p-Vrn6G0
Spanish | Milenio TV | 1280x720 | https://www.youtube.com/watch?v=kKDMPnce24M
Ukrainian | 112 Украина | 1920x1080 (max) | https://www.youtube.com/watch?v=v1ipuy14lBg
Urdu | Geo TV | 640x360 | https://www.youtube.com/watch?v=HrrpR7zjFpU

These urls *cannot* be directly ingested by IDOL Media Server however, YouTube also provides HLS index `.m3u8` files, which *can* be ingested as described [below](#record-videoaudio-from-a-live-youtube-channel).

### CCTV camera streams

IDOL Media Server can connect directly to live streams from most CCTV camera brands.  To find the stream details you will usually need to consult the operating manual for the particular camera.  

Most modern cameras will offer an [RTSP](https://en.wikipedia.org/wiki/Real_Time_Streaming_Protocol) stream, which looks like `rtsp://<user>:<password>@<IP>:<port>/<channel>`, where `IP` is the IP address (or hostname) of the camera.  If the port is not specified, the default is `554` for RTSP.  The channel part of the URL is optional.  The username and password can be added as shown and are required if security has been enabled on the camera.  Some examples from common brands:

Manufacturer | RTSP
--- | ---
Arecont | `rtsp://<IP>/media/video1`
Axis | `rtsp://<IP>/axis-media/media.amp`
Bosch | `rtsp://<IP>/video?inst=1&h26x=4`
D-Link | `rtsp://<IP>/live1.sdp`
Flir | `rtsp://<IP>/avc`
Geovision | `rtsp://<IP>/CH001.sdp`
Hikvision | `rtsp://<IP>/Streaming/Channels/101/`
IndigoVision | `rtsp://<IP>/`
Pelco | `rtsp://<IP>/stream1`

> If you cannot find a manual for your camera, or your manual does not include RTSP connection details (which is not uncommon), there are a number of websites that aggregate camera connection details.  I have found this one to be useful: <https://community.geniusvision.net/platform/cprndr/manurtsplist>.

As with the Bosch connection example above, some cameras also expose configuration parameters in the URL.Most cameras will need to be configured via an embedded web configuration UI, similar to what you have on your internet router at home.  This UI will be accessible at `http://IP:80/`, where `IP` is again the IP address (or hostname) of the camera.

IDOL Media Server can connect directly to these RTSP streams if you configure the multi-purpose [Video](https://www.microfocus.com/documentation/idol/IDOL_24_2/MediaServer_24.2_Documentation/Help/index.html#Configuration/Ingest/Libav/_Libav.htm) type ingest engine.  IDOL Media Server also includes the following additional ingest engines to support alternative stream types:

- [MJPEG](https://www.microfocus.com/documentation/idol/IDOL_24_2/MediaServer_24.2_Documentation/Help/index.html#Configuration/Ingest/MJPEG/_MJPEG.htm): for cameras supporting motion Jpeg streaming
- [MxPEG](https://www.microfocus.com/documentation/idol/IDOL_24_2/MediaServer_24.2_Documentation/Help/index.html#Configuration/Ingest/MXPEG/_MXPEG.htm): for [Mobotix](https://www.mobotix.com/en/mxpeg) cameras
- [Genetec](https://www.microfocus.com/documentation/idol/IDOL_24_2/MediaServer_24.2_Documentation/Help/index.html#Configuration/Ingest/Genetec/_Genetec.htm): to connect to any camera already integrated into the Genetec Security Center Video Management System (VMS)
- [Milestone](https://www.microfocus.com/documentation/idol/IDOL_24_2/MediaServer_24.2_Documentation/Help/index.html#Configuration/Ingest/Milestone/_Milestone.htm): to connect to any camera already integrated into the Milestone XProtect VMS

### Academic datasets

> Please check the license terms for these datasets.

- [COCO](http://cocodataset.org/): The "Common Objects in COntext" dataset is a large-scale object detection, segmentation, and captioning benchmark.
- [Open Images](https://storage.googleapis.com/openimages/web/factsfigures.html): A dataset of 9.2M images with unified annotations for image classification, object detection and visual relationship detection.
- [ImageNet](http://www.image-net.org/): ImageNet is an image dataset organized according to the WordNet hierarchy.
- [LFW](http://vis-www.cs.umass.edu/lfw/): The University of Massachusetts Labeled Faces in the Wild dataset is a public benchmark for face verification.
- [MS-Celeb-1M](https://github.com/EB-Dodo/C-MS-Celeb): The Microsoft Research One Million Celebrities in the Real World dataset is a benchmark for large-scale face recognition.
- [PETS2009](http://cs.binghamton.edu/~mrldata/pets2009): The IEEE International Workshop on Performance Evaluation of Tracking and Surveillance 2009 dataset is a public benchmark for the characterization of different crowd activities.

    > The PETS2009 dataset is provided as folders of stills.  To concatenate them into videos, use the ffmpeg command:
    > ```sh
    > ffmpeg -r 7 -i S3/Multiple_Flow/Time_12-43/View_008/frame_%04d.jpg -c:v libx264 -vf fps=25 -pix_fmt yuv420p S3_MF_Time_12-43_View_008.mp4
    > ```

- [UA-DETRAC](http://detrac-db.rit.albany.edu/home): The University at Albany DEtection and TRACking dataset is a benchmark for challenging real-world multi-object detection and multi-object tracking.

    > The UA-DETRAC dataset is provided as folders of stills.  To concatenate them into videos, use the ffmpeg command:
    > ```sh
    > ffmpeg -r 25 -i ./MVI_40864/img%05d.jpg -c:v libx264 -vf fps=25 -pix_fmt yuv420p MVI_40864.mp4
    > ```

## Working with video sources

The two main tools to keep handy are ffmpeg and VLC player.  They have overlapping capabilities, so in the following example tips we will use a mix of both to give you a small flavour of what each is capable of.

The following examples are grouped by source type: video files, video steams and YouTube:

### Devices

Many devices, such as webcams and HDMI-to-USB dongles, can be used as video sources for IDOL Media Server thanks to DirectShow on Windows or Video4Linux on Linux.  For tips on connecting to such devices, see the [webcam setup page](../../tutorials/setup/WEBCAM.md).

### Video files

#### Examine the metadata of a video file

With ffmpeg, you also get an executable called `ffprobe`. From the command line:

```sh
ffprobe -v quiet -print_format json -show_format -show_streams myVideo.mp4
```

#### Extract still images from a video file

Use ffmpeg to extract an image from the third second of your video:

```sh
ffmpeg -ss 00:00:03 -i path\to\my\video.mp4 -frames:v 1 path\to\interesting\frame.png
```

Use ffmpeg to extract one image every second from a video, starting from the third second:

```sh
ffmpeg -ss 00:00:03 -i path\to\my\video.mp4 -vf fps=1 out%03d.png
```

For more details, read this [documentation](https://trac.ffmpeg.org/wiki/Create%20a%20thumbnail%20image%20every%20X%20seconds%20of%20the%20video).

#### Split a video into shorter clips

Use ffmpeg to create a sequence of 60-second clips from your video:

```sh
ffmpeg -i path\to\my\video.mp4 -c copy -map 0 -segment_time 00:01:00 -f segment out%03d.mp4
```

#### Make a video clip of an interesting section

Use ffmpeg to create a 135 second long clip, starting from the 1st hour, 6th minute and 11th second of your video:

```sh
ffmpeg -ss 01:06:11 -i path\to\my\video.ext -t 135 path\to\interesting\clip.ext
```

or

```sh
ffmpeg -i path\to\my\video.ext -ss 01:06:11 -t 135 path\to\interesting\clip.ext
```

If the start time `-ss` option is passed before the input `-i`, ffmpeg will jump straight to that time in the video. Although this is a faster option, you might start copying far away from an I-frame and so have some mess at the start of your clip.

If the start time `-ss` option is passed after the input `-i`, ffmpeg will process all frames from the start. This can be a slower option but guarantees that your clip will be created with an full frame at the start.

#### Concatenate video clips into one video file

Create a playlist file, called *e.g.* `playlist.txt`, containing the text:

```ini
# comment
file 'path\to\my\first\video.ext'
file 'path\to\my\second\video.ext'
file 'path\to\my\third\video.ext'
```

Then use ffmpeg to perform the concatenation:

```sh
ffmpeg -f concat -i playlist.txt -c copy output.ext
```

For more details, read this [documentation](https://trac.ffmpeg.org/wiki/Concatenate).

#### Ingest a sequence of videos as a playlist

IDOL Media Server can read a playlist file in order to ingest a sequence of video files in a single process action.  The easiest way to ingest a playlist file, is with the Ingest Test page:

![playlist-ingest](./figs/playlist-ingest.png)

> To do this, note the Video-type ingest engine requires the `Format` option to be set to `Concat`.

#### Add tracks to existing media file

To add an empty audio track to a video file: 

```sh
ffmpeg -f lavfi -i aevalsrc=0 -i in.mp4 -vcodec copy -acodec aac -map 0:0 -map 1:0 -shortest -strict experimental -y out.mp4
```

To add a video track to an audio file by:

1. looping over an image file:

    ```sh
    ffmpeg -loop 1 -i image.png -i audio.mp3 -shortest out.mp4
    ```

1. generating a test page:

    ```sh
    ffmpeg -f lavfi -i testsrc -i audio.mp3 -shortest out.mp4
    ```

1. generating a blue background:

    ```sh
    ffmpeg -f lavfi -i color=c=blue -i audio.mp3 -shortest out.mp4
    ```

#### Strip tracks to existing media file

To remove the audio track to a video file: 

```sh
ffmpeg -i in.mp4 -vcodec copy -an out.mp4
```

### Video streams

#### Test availability of an IP stream

With ffmpeg, you also get an executable called `ffplay`. From the command line you can ingest, *e.g.* this HLS stream:

```sh
ffplay http://live-hls-web-aje.getaj.net/AJE/03.m3u8
```

This executable uses the same underlying libraries as IDOL Media Server. So, if you can play with this, it is highly likely you can ingest with IDOL Media Server.

#### Record video/audio from an IP stream

From the command line, *e.g.* to record a five minute clip:

```sh
ffmpeg -i http://live-hls-web-aje.getaj.net/AJE/03.m3u8 -t 300 clip-5mins.mp4
```

From the command line, *e.g.* to record from a CCTV camera's RTSP stream in five minute chunks, maintaining the original video encoding:

```sh
ffmpeg -i rtsp://host:port/channel -f segment -segment_time 300 -an -vcodec copy clip%04d.ts
```

From the command line, *e.g.* to record from a CCTV camera's MJPEG stream in five minute chunks, with a workaround to estimate frame timestamps (for which transcoding is required):

```sh
ffmpeg -use_wallclock_as_timestamps 1 -i http://localhost:port/ -f segment -segment_time 300 -an -vcodec h264 clip%04d.mp4
```

#### Loop a video file to produce a continuous RTSP stream

Sometimes I want to to analyze a video file on a loop for testing. This can be achieved by creating a looping stream of the video content. Using VLC player, from the command line:

```sh
vlc C:\video\anpr.mp4 --loop :sout=#duplicate{dst=rtp{sdp=rtsp://127.0.0.1:8554/mystream} } :sout-all :sout-keep
```

To view this stream in VLC player, from the command line:

```sh
vlc rtsp://127.0.0.1:8554/mystream
```

To process this stream with IDOL Media Server, do:

<http://127.0.0.1:14000/action=process&source=rtsp://127.0.0.1:8554/mystream&persist=true&configName=mySessionConfig>

, where setting `persist=true` instructs IDOL Media Server to wait out any short term interruptions in the incoming video stream that can occur due to network latency.

### YouTube

The free tool `youtube-dl` allows you to download video files from YouTube.

Obtain it through your Python package manager:

```sh
pip install youtube-dl
```

#### Download a video from YouTube

Using `youtube-dl`, query a YouTube video URL for available formats:

```sh
$ youtube-dl https://www.youtube.com/watch?v=MDn20owH-uI --list-formats
[youtube] MDn20owH-uI: Downloading webpage
[info] Available formats for MDn20owH-uI:
format code  extension  resolution note
249          webm       audio only tiny   50k , webm_dash container, opus @ 50k (48000Hz), 244.63KiB
250          webm       audio only tiny   62k , webm_dash container, opus @ 62k (48000Hz), 306.16KiB
251          webm       audio only tiny  118k , webm_dash container, opus @118k (48000Hz), 576.86KiB
140          m4a        audio only tiny  127k , m4a_dash container, mp4a.40.2@127k (44100Hz), 621.95KiB
278          webm       256x144    144p   82k , webm_dash container, vp9@  82k, 13fps, video only, 404.22KiB
160          mp4        256x144    144p  109k , mp4_dash container, avc1.42c00c@ 109k, 13fps, video only, 532.95KiB
242          webm       426x240    240p  124k , webm_dash container, vp9@ 124k, 25fps, video only, 608.08KiB
133          mp4        426x240    240p  244k , mp4_dash container, avc1.4d4015@ 244k, 25fps, video only, 1.17MiB
243          webm       640x360    360p  211k , webm_dash container, vp9@ 211k, 25fps, video only, 1.01MiB
134          mp4        640x360    360p  284k , mp4_dash container, avc1.4d401e@ 284k, 25fps, video only, 1.36MiB
244          webm       854x480    480p  332k , webm_dash container, vp9@ 332k, 25fps, video only, 1.58MiB
135          mp4        854x480    480p  624k , mp4_dash container, avc1.4d401e@ 624k, 25fps, video only, 2.98MiB
18           mp4        640x360    360p  377k , avc1.42001E, 25fps, mp4a.40.2 (44100Hz), 1.80MiB (best)
```

I want the best available quality, which is format code 18.  I can then download that video as follows:

```sh
youtube-dl -f 18 https://www.youtube.com/watch?v=MDn20owH-uI
```

#### Play a live YouTube channel

Live YouTube channels wrap standard HLS streams in their own API.

Using `youtube-dl`, query a channel for available HLS streams:

```sh
$ youtube-dl https://www.youtube.com/watch?v=gxG3pdKvlIs --list-formats
[youtube] gxG3pdKvlIs: Downloading webpage
[youtube] gxG3pdKvlIs: Downloading m3u8 information
[youtube] gxG3pdKvlIs: Downloading MPD manifest
[info] Available formats for gxG3pdKvlIs:
format code  extension  resolution note
91           mp4        256x144     269k , avc1.4d400c, 30.0fps, mp4a.40.5
92           mp4        426x240     507k , avc1.4d4015, 30.0fps, mp4a.40.5
93           mp4        640x360     962k , avc1.4d401e, 30.0fps, mp4a.40.2
94           mp4        854x480    1282k , avc1.4d401f, 30.0fps, mp4a.40.2
95           mp4        1280x720   2447k , avc1.4d401f, 30.0fps, mp4a.40.2
96           mp4        1920x1080  4561k , avc1.4d4028, 30.0fps, mp4a.40.2 (best)
```

I want a medium quality video with best available audio, *e.g.* format code 94.

I can obtain the HLS playlist file URL for that channel as follows:

```sh
$ youtube-dl -f 94 --get-url https://www.youtube.com/watch?v=gxG3pdKvlIs
https://manifest.googlevideo.com/api/manifest/hls_playlist/expire/1669911507/ei/.../playlist/index.m3u8
```

I can play the stream in `ffplay` as follows:

```sh
ffplay $(youtube-dl -f 94 --get-url https://www.youtube.com/watch?v=gxG3pdKvlIs)
```

Press `Ctrl`+`C` to stop the stream.

#### Record video/audio from a live YouTube channel

Following from the above example, I can next record that stream continuously with `ffmpeg` in one-minute segments, copying the audio and dropping the video as follows:

```sh
ffmpeg -i $(youtube-dl -f 94 --get-url https://www.youtube.com/watch?v=gxG3pdKvlIs) -f segment -segment_time 60 -vn -acodec copy recording%04d.aac
```

> NOTE: To record the video and audio, I would modify that command to:
> 
> ```sh
> ffmpeg -i $(youtube-dl -f 94 --get-url https://www.youtube.com/watch?v=gxG3pdKvlIs) -f segment -segment_time 60 -c copy recording%04d.mp4
> ```

#### Restream video/audio from a live YouTube channel

YouTube stream URLs use the `https:` protocol.  If I'm running IDOL Media Server on Linux, I cannot connect directly to an `https:` stream due to licensing restrictions of some underlying libraries; therefore, I want to convert this stream, *e.g.* to multicast `udp:`.

This can be achieved, following from the above example, with `ffmpeg` as follows:

```sh
ffmpeg -i $(youtube-dl -f 94 --get-url https://www.youtube.com/watch?v=gxG3pdKvlIs) -f mpegts udp://239.255.1.4:1234
```

To view this stream in `ffmpeg`, from the command line:

```sh
ffplay udp://239.255.1.4:1234
```

To process this stream with IDOL Media Server, do:

<http://127.0.0.1:14000/action=process&source=udp://239.255.1.4:1234&persist=true&configName=mySessionConfig>

, where setting `persist=true` instructs IDOL Media Server to wait out any short term interruptions in the incoming video stream that can occur due to network latency.


## Next steps

Why not try some tutorials to explore some of the analytics available in IDOL Media Server, linked from the [main page](../../README.md).

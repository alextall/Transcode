[![Stories in Ready](https://badge.waffle.io/alextall/Transcode.png?label=ready&title=Ready)](https://waffle.io/alextall/Transcode)
# Transcode

This shell script leverages Don Melton's [video_transcoding](http://github.com/donmelton/video_transcoding) scripts and adds my own custom settings.

Video transcoding takes a long time, especially if you are transcoding several files. I highly recommend doing this on a dedicated computer, over night, or at another time when you won't need to use your computer.

## Dependencies

I designed this script to be used with [Hazel](http://www.noodlesoft.com/hazel) for queue management and [transcode-video](https://www.github.com/donmelton/transcode-video) to manage [Handbrake](http://www.handbrake.fr) for the transcoding operation.

## Setup

Be sure to install Hazel according to Noodlesoft's instructions. I recommend installing transcode-video.sh and HandbrakeCLI using Homebrew Cask. Check out [Homebrew](http://www.brew.sh) and [Homebrew Cask](http://www.caskroom.io) to get set up.

Pick a work folder and place your files to transcode inside.
Set up Hazel to watch the work folder and create a rule  with the following criteria:

	If ALL of the following conditions are met
	EXTENSION IS ".mkv"
	Do the following to the matched file or folder:
	RUN SHELL SCRIPT
	and choose transcode.sh.

## Use

Transcode.sh will accept just about any video you can find, but I recommend using [MakeMKV](http://makemkv.com) to rip full quality .mkv files of your DVDs and Blu-rays. Place these files in the work folder, and Hazel will automatically trigger transcode-batch.sh to do its work.

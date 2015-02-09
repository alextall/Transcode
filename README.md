# Transcode

This shell script leverages Don Melton's transcode-video scripts, adds my own custom settings, and performs batch management.

Video transcoding takes a long time, especially if you are transcoding several files. I highly recommend doing this on a dedicated computer, over night, or at another time when you won't need to use your computer.

## Dependencies

I designed this script to be used with [Hazel](http://www.noodlesoft.com/hazel) for queue management and [transcode-video](https://www.github.com/donmelton/transcode-video) to manage [Handbrake](http://www.handbrake.fr) for the transcoding operation.

## Installation

Be sure to install Hazel according to Noodlesoft's instructions. I recommend installing transcode-video.sh and HandbrakeCLI using Homebrew Cask. Check out [Homebrew](http://www.brew.sh) and [Homebrew Cask](http://www.caskroom.io) to get set up.

Pick a work folder and create 4 folders inside called "_crops", "_finals", "_logs", and "_originals".
Set up Hazel to watch the work folder and create a rule  with the following criteria:

	If ALL of the following conditions are met EXTENSION IS ".mkv"
	Do the following to the matched file or folder:
	RUN SHELL SCRIPT EMBEDDED SCRIPT
	and copy the text of transcode-batch.sh into the embedded script.

## Use

Transcode-video.sh will accept just about any video you can find, but I recommend using MakeMKV to rip full quality .mkv files of your DVDs and Blu-rays. Place these files in the work folder, and Hazel will automatically trigger transcode-batch.sh to do its work.

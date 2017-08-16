[![Stories in Ready](https://badge.waffle.io/alextall/Transcode.png?label=ready&title=Ready)](https://waffle.io/alextall/Transcode)
# Transcode

This shell script leverages [Don Melton's](https://donmelton.com) [video_transcoding](http://github.com/donmelton/video_transcoding) scripts and adds my own custom settings.

Video transcoding takes a long time, especially if you are transcoding several files. I highly recommend doing this on a dedicated computer, over night, or at another time when you won't need to use your computer.

## Install

`transcode.sh` may be installed using Homebrew.
1. Run `brew tap alextall/homebrew-tools` to tap my cask.
2. Then run `brew install transcode`.

## Dependencies

* Install [video_transcoding](http://github.com/donmelton/video_transcoding).
* Install [HandbrakeCLI](https://handbrake.fr).
* Optional: Install [Hazel](https://www.noodlesoft.com) according to Noodlesoft's instructions.

## Setup

Pick a work folder and place your files to transcode inside. `transcode.sh` will create several folders to organize the generated files. These will all be named with a `_` prefix.

## Use

Simply run `transcode.sh [File...]` from the Terminal. You may add 1 or more files separated by spaces.

`transcode.sh` will accept just about any video you can find, but I recommend using [MakeMKV](http://makemkv.com) to rip full quality .mkv files of your DVDs and Blu-rays. Place these files in the work folder, and Hazel will automatically trigger transcode-batch.sh to do its work.

## Using Hazel

Set up Hazel to watch the work folder and create a rule  with the following criteria:

	If ALL of the following conditions are met
	EXTENSION IS ".mkv"
	Do the following to the matched file or folder:
	RUN SHELL SCRIPT
	and choose transcode.sh.

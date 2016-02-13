#!/bin/bash
#
# This script will accept video files as input and use Don Melton's
# video transcoding scripts to control Handbrake in order to produce
# portable video files.
#

readonly program="$(basename "$0")"

about() {
	cat <<EOF
$program 1.2 of February 13, 2016
Copyright (c) 2016 Alex Du Bois
EOF
	exit 0
}

usage(){
	cat <<EOF
Transcode video files. Works best with Blu-ray or DVD rips.

Transcode.sh automatically determines target video bitrate, number of audio tracks, etc. WITHOUT ANY command line options.

It is recommended to use Hazel to provide automated queue management and trigger transcode.sh.

Usage: $program [FILE]

  --help          display basic options and exit
  --version       display program version and exit

Requires "video_transcoding", "HandBrakeCLI", "mp4track", "mplayer" and "mkvpropedit".
EOF
  exit 0
}

# OPTIONS
#
case $1 in
	--help)
		usage
		;;
	--version)
		about
		;;
esac

syntax_error() {
	echo "$program: $1" >&2
	echo "Try \`$program --help\` for more information." >&2
	exit 1
}

die() {
	echo "$program: $1" >&2
	exit ${2:-1}
}

if [ ! "$1" ]; then
	syntax_error 'too few arguments'
fi

if [ ! -e "$1" ]; then
	die "file not found: $input"
fi

# Set global variables
#
PATH="/usr/local/bin:$PATH"
readonly input="$1"
readonly work_dir=`dirname "$input"`
readonly title_name="$(basename "$input" | sed 's/\.[^.]*$//')"
readonly base_name=`echo $title_name | sed 's/_[^_]*$//'`
readonly crop_dir="_crops/$base_name"
readonly crop_file="$crop_dir/${title_name}.txt"
readonly originals_dir="_originals/$base_name"
readonly finals_dir="_finals/$base_name"
readonly logs_dir="_logs/$base_name"
readonly media_info=`transcode-video --scan $input`

crop_options=''
video_options=''
audio_options=''
subtitle_options=''
logging_options='--quiet'

function enableLogging() {
  logging_options='--verbose'
}

function setupWorkingDirectory() {
  if [ ! -d "_originals" ]; then
    mkdir "_originals"
  fi

  if [ ! -d "_logs" ]; then
    mkdir "_logs"
  fi

  if [ ! -d "_finals" ]; then
    mkdir "_finals"
  fi
}

function setCroppingOptions() {
  if [ ! -d "_crops" ]; then
    mkdir "_crops"
  fi

  if [ ! -d "$crop_dir" ]; then
  	mkdir "$crop_dir"
  fi

  detect-crop "$input" &> "$crop_file"

  if [[ -f "$crop_file" ]] && [[ ! `grep differ $crop_file` ]]; then
  	crop_options=`grep transcode-video $crop_file | egrep -o -e "--crop "[0-9]+:[0-9]+:[0-9]+:[0-9]+`
  else
  	crop_options=''
  fi
}

function setVideoOptions() {
  video_options="--max-width 1920 --max-height 1080"
}

function setAudioOptions() {
  if [ `echo "$media_info" | egrep "(\d\.\d ch)" | wc -l` -gt 10 ]; then
    audio_options="--add-audio language=eng"
  else
    audio_options="--add-audio all"
  fi

  audio_options="$audio_options --audio-width all=double"
}

function setSubtitleOptions() {
  srt_file=`ls "$work_dir" | egrep '\.(srt)$'`

  if [ -n "$srt_file" ]; then
    subtitle_options="--add-srt $work_dir/$srt_file"
  elif [ `echo "$media_info" | egrep "English \(iso639-2: eng\)" | wc -l` -gt 0 ]; then
    subtitle_options='--add-subtitle language=eng'
  else
    subtitle_options=''
  fi
}

function setupVideoDirectories() {
  setupWorkingDirectory

  if [ ! -d "$originals_dir" ]; then
    mkdir "$originals_dir"
  fi

  if [ ! -d "$logs_dir" ]; then
    mkdir "$logs_dir"
  fi

  if [ ! -d "$finals_dir" ]; then
    mkdir "$finals_dir"
  fi
}

function cleanup() {
  setupVideoDirectories

  mv "$input" "$originals_dir"
  mv "$title_name.mp4.log" "$logs_dir"
  mv "$title_name.mp4" "$finals_dir"
}

if [ -f "$input" ]; then
  setCroppingOptions
  setVideoOptions
  setAudioOptions
  setSubtitleOptions

  transcode-video --mp4 $crop_options $video_options $audio_options $subtitle_options $logging_options "$input"

  cleanup
else
  echo "There was a problem with the file you selected."
fi

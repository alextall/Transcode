#!/bin/bash
#
# This script will accept video files as input and use Don Melton's
# video transcoding scripts to control Handbrake in order to produce
# portable video files.
#

readonly program="$(basename "$0")"

about() {
	cat <<EOF
$program 1.6 of August 2, 2017
Copyright (c) 2017 Alex Du Bois
EOF
	exit 0
}

usage(){
	cat <<EOF
Transcode video files. Works best with Blu-ray or DVD rips.

Transcode.sh automatically determines target video bitrate, number of audio
tracks, etc. WITHOUT ANY command line options.

It is recommended to use Hazel to provide automated queue management and 
trigger transcode.sh, but you can also provide multiple files or folders as arguments and
they will be transcoded one at a time.

Usage: $program [FILES...]

  --help          display basic options and exit
  --version       display program version and exit

Requires "video_transcoding" from https://github.com/donmelton/video_transcoding
Requires "HandBrakeCLI" from https://handbrake.fr
EOF
  exit 0
}

syntax_error() {
	echo "$program: $1" >&2
	echo "Try \`$program --help\` for more information." >&2
	exit 1
}

die() {
	echo "$program: $1" >&2
	exit ${2:-1}
}

install_homebrew() {
  /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
}

test_homebrew() {
  if [ `which brew | wc -l` -lt 1 ]; then
    echo "Homebrew is not installed. Do you want to install it?"
    read -p "[y/n]: " homebrew_install_input
    if [ "$homebrew_install_input" = "y" ]; then
      install_homebrew
    else
      die "Please install Handbrake manually and try again."
    fi
  fi
}

install_handbrake() {
  test_homebrew
  brew update && brew install handbrake
}

install_video_transcoding() {
  gem install video_transcoding
}

test_handbrake() {
  if [ `brew leaves | grep handbrake | wc -l` -lt 1 ]; then
    echo "Handbrake is not installed. Do you want to install it?"
    read -p "[y/n]:" handbrakeinstallinput
    if [ "$handbrakeinstallinput" = "y" ]; then
      install_handbrake
    else
      die "Please install handbrake and try again."
    fi
  fi
}

test_video_transcoding() {
  if [ `gem list --quiet video_transcoding | grep video_transcoding | wc -l` -lt 1 ]; then
    echo "video_transcoding is not install. Do you want to install it?"
    read -p "[y/n]:" video_transcodinginstallinput
    if [ "$video_transcodinginstallinput" = "y" ]; then
      install_video_transcoding
    else
      die "Please install video_transcoding and try again."
    fi
  fi
}

test_dependencies() {
  test_handbrake
  test_video_transcoding
}

# Set global variables
#
PATH="/usr/local/bin:$PATH"
readonly crop_dir="_crops"
readonly originals_dir="_originals"
readonly finals_dir="_finals"
readonly logs_dir="_logs"
crop_options=''
video_options=''
audio_options=''
subtitle_options=''
logging_options='--quiet'
use_h265=''
dry_run=''

function enableLogging() {
  logging_options='--verbose'
}

function enableH265() {
  use_h265='--handbrake-option encoder=x265'
}

function dry-run() {
  dry_run='--dry-run'
}

# Process Options
#
while [ "$1" ]; do
  case "$1" in
    --help | -h)
      usage
      ;;
    --version | -v)
      about
      ;;
    --h265)
      enableH265
      ;;
    --dry-run)
      dry-run
      ;;
    -*)
      syntax_error "unrecognized option: $1"
      ;;
    *)
      break
      ;;
  esac
  shift
done

if [ ! "$1" ]; then
	syntax_error 'too few arguments'
fi

test_dependencies

function transcode() {
  if [ ! -e "$1" ]; then
    die "file not found: $1"
  fi

  input="$1"
  work_dir=`dirname "$input"`
  title_name="$(basename "$input" | sed 's/\.[^.]*$//')"
  crop_file="$crop_dir/${title_name}.txt"
  media_info=`transcode-video --scan $input`

  function setupWorkingDirectory() {
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

  function setCroppingOptions() {
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
    if [ `echo "$media_info" | egrep "x480" | wc -l` -gt 0 ]; then
      video_options="--force-rate 23.976 --filter detelecine"
    else
      video_options="--max-width 1920 --max-height 1080"
    fi
  }

  function setAudioOptions() {
    if [ `echo "$media_info" | egrep "(\d\.\d ch)" | wc -l` -gt 1 ]; then
      audio_options="--main-audio eng"
    else
      audio_options="--add-audio all"
    fi

    audio_options="$audio_options --audio-width all=double"
  }

  function setSubtitleOptions() {
    srt_file="$title_name.srt"

    if [ -e "$srt_file" ]; then
      subtitle_options="--add-srt $work_dir/$srt_file"
    else
      subtitle_options="--burn-subtitle scan"
    fi
  }

  function cleanup() {
    setupWorkingDirectory

    mv "$input" "$originals_dir"
    if [ -e $srt_file ]; then
      mv "$srt_file" "$originals_dir"
    fi
    mv "$title_name.mp4.log" "$logs_dir"
    mv "$title_name.mp4" "$finals_dir"
  }

  if [ -f "$input" ]; then
    setCroppingOptions
    setVideoOptions
    setAudioOptions
    setSubtitleOptions

    if [ $dry_run ]; then
      echo transcode-video --mp4 $crop_options $video_options $audio_options $subtitle_options $logging_options $use_h265 "$input"
    else
      transcode-video --mp4 $crop_options $video_options $audio_options $subtitle_options $logging_options $use_h265 "$input"
      cleanup
    fi
  else
    echo "There was a problem with $input and it could not be transcoded."
  fi
}

while [ "$1" ]; do

  if [ -d $1 ]; then
    for file in $( ls | egrep -e \.[^.]*mkv ); do
      transcode $file
    done
  else
    transcode $1
  fi

  shift
done

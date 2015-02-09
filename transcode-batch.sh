#!/bin/bash
#
# transcode-batch.sh
#
# Copyright (c) 2015 Alex Du Bois
#

about() {
	cat <<EOF
$program 0.9 of February 8, 2015
Copyright (c) 2015 Alex Du Bois
EOF
	exit 0
}

usage_prologue(){
	cat <<EOF
Batch transcode video files using transcode-video.sh. Works best with Blu-ray or DVD rips.

Transcode-video.sh automatically determines target video bitrate, number of audio tracks, etc. WITHOUT ANY command line options.

It is recommended to use Hazel to provide automated queue management and trigger transcode-batch.sh.

Usage: $program [OPTION]... [FILE|DIRECTORY]

	--help          display basic options and exit
EOF
}

usage() {
	usage_prologue
	cat <<EOF
EOF
	exit 0
}

readonly program="$(basename "$0")"

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

# Set global variables
#
readonly input="$1"
readonly title_name="$(basename "$1" | sed 's/\.[^.]*$//')"
readonly base_name=`echo $title_name | sed 's/_[^_]*$//'`
readonly crop_dir="_crops/$base_name"
readonly crop_file="$crop_dir/${title_name}.txt"
readonly originals_dir="_originals/$base_name"
readonly finals_dir="_finals/$base_name"
readonly logs_dir="_logs/$base_name"

if [ ! "$input" ]; then
	syntax_error 'too few arguments'
fi

if [ ! -e "$input" ]; then
	die "input not found: $input"
fi

## Run crop detection and save output to file
# Crop option is currently not used in transcode operations
if [ ! -d $crop_dir ]; then
	mkdir $crop_dir
fi

detect-crop.sh $1 &> $crop_file

if [[ -f "$crop_file" ]] && [[ `grep identical $crop_file` ]]; then
	crop_option="--crop `grep transcode-video $crop_file | egrep -o [0-9]+:[0-9]+:[0-9]+:[0-9]+`"
else
	crop_option=''
fi

# Detect audio streams
#
audio_streams=`ffmpeg -i $input 2>&1 | grep -c Audio:`

if [ "$audio_streams" -gt 1 ]; then
  for i in `seq 1 $audio_streams`; do
	audio_options="$audio_options --add-audio $i"
  done
else
  audio_options=''
fi

# Detect subtitles
#
subtitle_streams=`ffmpeg -i $input 2>&1 | grep -v pgs | grep -c Subtitle:`

if [ "$subtitle_streams" -gt 0 ]; then
  for i in `seq 1 $subtitle_streams`; do
	subtitle_options="$subtitle_options --add-subtitle $i"
  done
else
  subtitle_options=''
fi

# Begin transcode operation
#
transcode-video.sh --allow-ac3 $audio_options $subtitle_options $crop_option $input

# Clean up source and generated files
#
if [ ! -d "$originals_dir" ]; then
  mkdir "$originals_dir"
fi
mv $input "$originals_dir"

if [ ! -d "$logs_dir" ]; then
  mkdir "$logs_dir"
fi
mv "$title_name.mp4.log" "$logs_dir"

if [ ! -d "$finals_dir" ]; then
  mkdir "$finals_dir"
fi
mv "$title_name.mp4" "$finals_dir"

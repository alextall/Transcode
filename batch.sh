# Set global variables

readonly title_name="$(basename "$1" | sed 's/\.[^.]*$//')"
readonly crop_file="_crops/${title_name}.txt"

# Run crop detection and save output to file
# Crop option is currently not used in transcode operations

detect-crop.sh $1 > $crop_file

if [ -f "$crop_file" ]; then
	crop_option="--crop $(cat "$crop_file")"
else
	crop_option=''
fi

# Detect audio streams

audio_streams=“ffmpeg -i $1 2>&1 | grep -c Audio:”

if [ $audio_streams > 1 ]
  then
	for i in `seq 1 $audio_streams`; do
	  audio_option="$audio_option --add-audio $i"
  done
else
  audio_option=''
fi

# Detect subtitles
# Subtitles are not currently added automatically

subtitle_streams=“ffmpeg -i $1 2>&1 | grep -c Subtitles:”

if [ $subtitle_streams > 0 ]
  then
	for i in `seq 1 $subtitle_streams`; do
	  subtitle_option="$subtitle_option --add-subtitle $i"
  done
else
  subtitle_option=''
fi

# Begin transcode operation

transcode-video.sh --allow-ac3 $audio_option $1

# CLEAN UP

# Move source file

if [ ! -d "_originals/$title_name" ]
  then
	mkdir "_originals/$title_name"
fi
mv $1 "_originals/$title_name/"

# Move log file

if [ ! -d "_logs/$title_name" ]
  then
	mkdir "_logs/$title_name"
fi
mv "$title_name.mp4.log" "_logs/$title_name/"
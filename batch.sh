# Set global variables

readonly title_name="$(basename "$1" | sed 's/\.[^.]*$//')"
readonly crop_file="_crops/${title_name}.txt"
readonly base_name=`echo $title_name | sed 's/_[^_]*$//'`

## Run crop detection and save output to file
# Crop option is currently not used in transcode operations

# detect-crop.sh $1 > $crop_file

if [ -f "$crop_file" ]; then
	crop_option="--crop $(cat "$crop_file")"
else
	crop_option=''
fi

## Detect audio streams

audio_streams=`ffmpeg -i $1 2>&1 | grep -c Audio:`

if [ "$audio_streams" -gt 1 ]
  then
	for i in `seq 1 $audio_streams`; do
	  audio_options="$audio_options --add-audio $i"
  done
else
  audio_options=''
fi

## Detect subtitles

subtitle_streams=`ffmpeg -i $1 2>&1 | grep -v pgs | grep -c Subtitle:`

if [ "$subtitle_streams" -gt 0 ]
  then
	for i in `seq 1 $subtitle_streams`; do
	  subtitle_options="$subtitle_options --add-subtitle $i"
  done
else
  subtitle_options=''
fi

## Begin transcode operation

transcode-video.sh --allow-ac3 $audo_options $subtitle_options $1

## CLEAN UP

## Move source file

if [ ! -d "_originals/$base_name" ]
  then
	mkdir "_originals/$base_name"
fi
mv $1 "_originals/$base_name/"

## Move log file

if [ ! -d "_logs/$base_name" ]
  then
 	mkdir "_logs/$base_name"
 fi
mv "$title_name.mp4.log" "_logs/$base_name/"

## Move final video file

if [ ! -d "_finals/$base_name" ]
	then
	  mkdir "_finals/$base_name"
fi
mv "$title_name.mp4" "_finals/$base_name/"

#!/usr/bin/env bash

usage() {
    echo "Usage: ${0##*/} -f INFILE [-o OUTFILE] [-v]"
    echo
    echo "    -i INFILE     Input file to convert"
    echo "    -o OUTFILE    Optional output file"
    echo "    -h            Show this help message"
    echo "    -v            Enable verbose output"
    echo
    exit 5
}

INFILE=
OUTFILE=
VERBOSE=0

while getopts :i:o:hv FLAG; do
    case $FLAG in
        i)  INFILE=$OPTARG
            ;;
        o)  OUTFILE=$OPTARG
            ;;
        v)  VERBOSE=1
            ;;
        *)  usage
            ;;
    esac
done

if [[ "$INFILE" == "" ]]; then
    echo "Missing input file"
    echo
    usage
fi

if [[ "$OUTFILE" == "" ]]; then
    OUTFILE="./${INFILE%*.*}.gif"
    ((VERBOSE)) && echo "Setting output file to $OUTFILE"
fi

temp_dir=$(mktemp -d)
((VERBOSE)) && echo "Setting temp dir to $temp_dir"
ffmpeg_output=$(ffmpeg -i "$INFILE" -vf scale=420:-1:flags=lanczos,fps=10 "$temp_dir"/ffout%03d.png 2>&1)
((VERBOSE)) && echo "$ffmpeg_output"
convert -loop 0 "$temp_dir"/*.png "$OUTFILE"
((VERBOSE)) && echo "Removing temp dir $temp_dir"
rm -rf "$temp_dir"

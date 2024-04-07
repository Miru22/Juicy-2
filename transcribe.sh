#!/bin/bash

# Define input and output directories
input_dir="$1"
output_dir="$2"

# Ensure the output directory exists, if not create it
mkdir -p "$output_dir"

# Step 1: Convert non-.wav files to .wav using ffmpeg
for file in "$input_dir"/*; do
    if [ "${file##*.}" != "wav" ]; then
        new_file="${file%.*}.wav"
        ffmpeg -i "$file" "$new_file"
    fi
done

source /opt/transcription_diarization/venv/bin/activate

# Iterate over .wav files in the input directory
for file in "$input_dir"/*.wav; do
    # Check if the file is a .wav file
    if [ -f "$file" ]; then
        # Run the command on the file        					
        python /opt/transcription_diarization/src/main.py --input_file "$file" --output_file_dir "$output_dir"
        
        # Optionally, you may want to add some logging or error handling here
        echo "Transcribed $file"
    fi
done

# Function to countdown for 5 minutes, allowing cancellation
countdown() {
    secs=$((2 * 60))
    while [ $secs -gt 0 ]; do
        echo -ne "Shutting down in $((secs / 60)) minutes and $((secs % 60)) seconds. Enter 'STOP' to cancel: \r"
        read -t 5 input
        if [ "$input" = "STOP" ]; then
            echo "Shutdown cancelled."
            exit 0
        fi
        : $((secs -= 5))
    done
    echo "Shutting down now..."
    sudo shutdown now
}

# Step 3: Start countdown
countdown

#!/bin/bash

# Function to setup storage for Termux
setup_storage() {
    if [ ! -d ~/storage ]; then
        echo "Setting up Termux storage..."
        termux-setup-storage
        echo "Storage setup complete."
    fi
}

# Function to install yt-dlp if not already installed
install_yt_dlp() {
    echo "Checking for yt-dlp installation..."
    if ! command -v yt-dlp &> /dev/null; then
        echo "yt-dlp not found. Installing yt-dlp..."
        pkg update -y && pkg upgrade -y
        pkg install python -y
        pip install yt-dlp
        echo "yt-dlp installed successfully."
    else
        echo "yt-dlp is already installed."
    fi
}

# Function to display quality options and get user input
select_quality() {
    echo "Select video quality:"
    echo "1. 144p"
    echo "2. 360p"
    echo "3. 720p"
    echo "4. 1080p"
    echo "5. 1440p (2K)"
    echo "6. 2160p (4K)"
    echo "7. Best (Default)"

    read -p "Enter your choice (1-7): " quality_choice

    case $quality_choice in
        1) quality="worst[height=144]" ;;
        2) quality="best[height=360]" ;;
        3) quality="best[height=720]" ;;
        4) quality="best[height=1080]" ;;
        5) quality="best[height=1440]" ;;
        6) quality="best[height=2160]" ;;
        7 | "") quality="best" ;;
        *) 
            echo "Invalid choice, defaulting to 'Best' quality."
            quality="best"
            ;;
    esac
}

# Function to download the video
download_video() {
    echo "Enter YouTube video URL:"
    read video_url

    echo "Do you want to download the full video? (y/n)"
    read full_video

    if [[ "$full_video" == "y" ]]; then
        start_time=""
        end_time=""
        echo "Downloading full video..."
    else
        echo "Enter start time (format: HH:MM:SS):"
        read start_time

        echo "Enter end time (format: HH:MM:SS):"
        read end_time
    fi

    select_quality

    echo "Enter a name for the output file (without extension, press Enter for default):"
    read file_name
    file_name=${file_name:-output_video}
    output_file=~/storage/downloads/"$file_name.mp4"

    echo "Downloading video..."
    if [[ -z "$start_time" && -z "$end_time" ]]; then
        yt-dlp -o "$output_file" -f "$quality" "$video_url"
    else
        yt-dlp -o "$output_file" -f "$quality" --download-sections "*${start_time}-${end_time}" "$video_url"
    fi

    echo "Download complete. Saved as $output_file"
}

# Main script execution
setup_storage
install_yt_dlp
download_video

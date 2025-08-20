#!/bin/bash

# Function to check if a command exists
check_tool() {
    if ! command -v "$1" &>/dev/null; then
        echo "[ERROR] $1 is not installed or not in PATH. Please install it and try again."
        exit 1
    fi
}

# Tools to verify
tools=("hakrawler" "katana" "waybackurls")

# Check if all tools are installed
echo "[INFO] Checking installed tools..."
for tool in "${tools[@]}"; do
    check_tool "$tool"
done

# Prompt user for subdomains file
read -p "Enter the path to the subdomains file: " subdomains_file

# Verify input file exists
if [[ ! -f "$subdomains_file" ]]; then
    echo "[ERROR] The file $subdomains_file does not exist. Please provide a valid file."
    exit 1
fi

# Output file
output_file="all_urls.txt"
echo "[INFO] Extracting URLs using crawlers..."
echo "[INFO] Results will be saved in $output_file"
> "$output_file" # Clear the file if it exists

# Run hakrawler
echo "[INFO] Running hakrawler..."
cat "$subdomains_file" | hakrawler -d 5 -subs -insecure -t 10 -timeout 3600 >> "$output_file"

# Run katana
echo "[INFO] Running katana..."
katana -u "$subdomains_file" -d 5 -ef jpg,png,gif,svg,css,eot,ttf,ico,webp,mp4,mp3,avi,mov,flv,mkv -kf all -td -jc -ct 1h -aff -fx -s depth-first >> "$output_file"

# Run waybackurls
echo "[INFO] Running waybackurls..."
cat "$subdomains_file" | waybackurls >> "$output_file"

# Remove duplicates and sort
echo "[INFO] Removing duplicates and sorting the URLs..."
sort -u "$output_file" -o "$output_file"

echo "[SUCCESS] URL extraction completed. Results saved in $output_file."

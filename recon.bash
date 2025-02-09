#!/bin/bash

# Install required dependencies if not available
install_dependencies() {
    echo "Checking and installing dependencies..."
    sudo apt update
    sudo apt install -y subfinder amass assetfinder findomain httprobe pandoc zenity
}

# Ask for the domain using Zenity GUI
domain=$(zenity --entry --title="Automated Recon" --text="Enter the target domain:")

if [[ -z "$domain" ]]; then
    zenity --error --text="No domain entered. Exiting..."
    exit 1
fi

# Show a progress dialog
(
    echo "10"; sleep 1
    echo "# Finding subdomains..."; sleep 1
    echo "40"; sleep 2
    echo "# Checking live subdomains..."; sleep 1
    echo "70"; sleep 2
    echo "# Generating report..."; sleep 1
    echo "100"; sleep 1
) | zenity --progress --title="Recon in Progress" --percentage=0 --auto-close

# Start Subdomain Enumeration
echo "Finding subdomains for $domain..."
subfinder -d $domain -o subdomains_subfinder.txt
amass enum -d $domain -o subdomains_amass.txt
assetfinder --subs-only $domain > subdomains_assetfinder.txt
findomain -t $domain -q > subdomains_findomain.txt

# Merge results and remove duplicates
cat subdomains_*.txt | sort -u > subdomains.txt
echo "Subdomains saved to subdomains.txt"

# Check for Live Subdomains
echo "Checking for live subdomains..."
cat subdomains.txt | httprobe | tee live_subdomains.txt
echo "Live subdomains saved in live_subdomains.txt"

# Generate Report
echo "Generating report..."
echo "# Recon Report for $domain" > report.md
echo "## Subdomains Found" >> report.md
cat subdomains.txt >> report.md
echo "## Live Subdomains" >> report.md
cat live_subdomains.txt >> report.md

# Convert Markdown to PDF and HTML
pandoc report.md -o report.pdf
pandoc report.md -o report.html

zenity --info --text="Recon complete! Report saved as report.pdf and report.html"

echo "Recon complete! Reports saved as report.pdf and report.html"

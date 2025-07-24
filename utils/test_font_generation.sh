#!/bin/bash

# Make the Python scripts executable
chmod +x ./generate_refind_font_fixed.py

# Check if SpaceMono-Regular.ttf exists
if [ -f "SpaceMono-Regular.ttf" ]; then
    echo "Found SpaceMono-Regular.ttf"
    
    # Generate font using fixed script
    echo "Generating font with fixed script..."
    ./generate_refind_font_fixed.py SpaceMono-Regular.ttf 28 spacemono-28-fixed.png
    
    echo "Done! Generated font files:"
    echo "- spacemono-28-fixed.png"
    
    echo "Compare these with nimbus-mono-28.png to see which one works better with rEFInd."
else
    echo "Error: SpaceMono-Regular.ttf not found in the current directory."
    echo "Please make sure the font file is in the same directory as this script."
fi
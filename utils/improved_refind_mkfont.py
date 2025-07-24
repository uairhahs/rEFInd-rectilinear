#!/usr/bin/env python3
#
# Generates a rEFInd-compatible font file from a TTF or OTF font.
# Matches the exact dimensions of nimbus-mono-28.png (1632x28)
#
import argparse
from PIL import Image, ImageDraw, ImageFont

def create_refind_font(font_path, cell_height, output_filename):
    """
    Creates a PNG font sheet for rEFInd from a given font file.
    Matches the exact dimensions of nimbus-mono-28.png (1632x28)
    """
    # --- Configuration ---
    TOTAL_WIDTH = 1632  # Match nimbus-mono-28.png width
    CHAR_START = 32     # Space character
    CHAR_END = 126      # Last printable ASCII character
    NUM_CHARS = CHAR_END - CHAR_START + 2  # +1 for extra question mark
    CELL_WIDTH = TOTAL_WIDTH // NUM_CHARS
    
    # Character scaling factor to reduce padding (1.0 = no change, >1.0 = larger)
    SCALE_FACTOR = 1.2

    print(f"Loading font: {font_path}")
    # Increase point size to reduce padding between characters
    point_size = int(cell_height * 0.75 * SCALE_FACTOR)
    font = ImageFont.truetype(font_path, point_size)

    # --- Create canvas ---
    image_width = TOTAL_WIDTH
    image_height = cell_height
    
    print(f"Creating image of size: {image_width}x{image_height}px...")
    image = Image.new("RGBA", (image_width, image_height), (0, 0, 0, 0))
    draw = ImageDraw.Draw(image)

    # --- Draw all characters into their cells ---
    font_ascent, font_descent = font.getmetrics()
    
    # Draw standard characters
    for i in range(CHAR_START, CHAR_END + 1):
        char = chr(i)
        idx = i - CHAR_START
        
        # Calculate position
        cell_x = idx * CELL_WIDTH
        
        # Center the character in its cell
        try:
            bbox = font.getbbox(char)
            char_width = bbox[2] - bbox[0]
            x_offset = (CELL_WIDTH - char_width) // 2
            
            # Vertical centering based on font metrics
            y_offset = (cell_height - (font_ascent + font_descent)) // 2
            
            # Draw the character with black color (0,0,0,255)
            draw.text((cell_x + x_offset, y_offset), char, font=font, fill=(0, 0, 0, 255))
        except Exception as e:
            print(f"Warning: Could not render character {i} ({char}): {e}")
    
    # Add the extra question mark at the end
    idx = CHAR_END - CHAR_START + 1
    cell_x = idx * CELL_WIDTH
    char = '?'
    
    try:
        bbox = font.getbbox(char)
        char_width = bbox[2] - bbox[0]
        x_offset = (CELL_WIDTH - char_width) // 2
        y_offset = (cell_height - (font_ascent + font_descent)) // 2
        draw.text((cell_x + x_offset, y_offset), char, font=font, fill=(0, 0, 0, 255))
    except Exception as e:
        print(f"Warning: Could not render extra question mark: {e}")

    # --- Save the final image ---
    # Convert to grayscale with alpha to match nimbus-mono-28.png format
    image = image.convert("LA")
    image.save(output_filename)
    print(f"Successfully saved font to '{output_filename}'")
    print(f"Image dimensions: {image_width}x{image_height}")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Generate a rEFInd-compatible font PNG.")
    parser.add_argument("font_path", help="Path to the TTF or OTF font file.")
    parser.add_argument("height", type=int, default=28, help="The desired character cell height in pixels (default: 28).")
    parser.add_argument("output_file", help="The output PNG filename (e.g., spacemono-28.png).")
    args = parser.parse_args()

    create_refind_font(args.font_path, args.height, args.output_file)
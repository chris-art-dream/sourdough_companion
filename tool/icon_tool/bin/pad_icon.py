#!/usr/bin/env python3
"""Generate a padded adaptive foreground icon from app_icon.png"""

from PIL import Image
import os
import sys

def main():
    src_path = 'assets/icon/app_icon.png'
    out_path = 'assets/icon/app_icon_fg.png'
    
    if not os.path.exists(src_path):
        print(f"Source icon not found: {src_path}")
        sys.exit(2)
    
    # Load image
    img = Image.open(src_path).convert('RGBA')
    
    # Canvas size and content ratio
    canvas_size = 1024
    content_ratio = 0.60
    
    # Calculate target size preserving aspect ratio
    max_content = int(canvas_size * content_ratio)
    w, h = img.size
    
    if w > max_content or h > max_content:
        scale = max_content / max(w, h)
        w = int(w * scale)
        h = int(h * scale)
        img = img.resize((w, h), Image.Resampling.LANCZOS)
    
    # Create transparent canvas
    canvas = Image.new('RGBA', (canvas_size, canvas_size), (0, 0, 0, 0))
    
    # Center and paste
    dx = (canvas_size - img.width) // 2
    dy = (canvas_size - img.height) // 2
    
    canvas.paste(img, (dx, dy), img)
    
    # Ensure output dir exists
    os.makedirs(os.path.dirname(out_path) or '.', exist_ok=True)
    
    canvas.save(out_path)
    print(f"Wrote padded foreground icon to {out_path}")

if __name__ == '__main__':
    main()

#!/bin/bash

# This script generates app icons using ImageMagick
# Install ImageMagick first: brew install imagemagick

# Make sure images directory exists
mkdir -p assets/images

# Set the brand color
BRAND_COLOR="#4286F5"

# Generate square app icon with transparent background and blue bolt (1024x1024)
echo "Generating app icon..."
convert -size 1024x1024 xc:none \
  -fill "$BRAND_COLOR" -stroke none \
  -draw "path 'M 512,180 C 485.5,180 460,183 435.5,189 L 341,420 L 483,420 L 341,844 L 683,513 L 512,513 L 683,180 Z'" \
  -define png:format=png32 \
  assets/images/app_icon.png

# Generate the foreground icon with blue bolt
echo "Generating adaptive foreground icon..."
convert -size 1024x1024 xc:none \
  -fill "$BRAND_COLOR" -stroke none \
  -draw "path 'M 512,150 C 485.5,150 460,153 435.5,159 L 341,390 L 483,390 L 341,874 L 683,513 L 512,513 L 683,150 Z'" \
  -define png:format=png32 \
  assets/images/icon_foreground.png

# Generate transparent background
echo "Generating adaptive background..."
convert -size 1024x1024 xc:none \
  -define png:format=png32 \
  assets/images/icon_background.png

echo "App icons generated successfully!"

# Run flutter_launcher_icons to generate platform-specific icons
echo "Generating platform-specific icons..."
flutter pub run flutter_launcher_icons

echo "All done!" 
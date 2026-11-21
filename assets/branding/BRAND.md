# ShowShelf brand assets

## Core identity
- Primary app icon: lime rounded-square tile with the black bookshelf glyph.
- Wordmark: white “ShowShelf” lettering with the lime icon.
- Keep the icon glyph and proportions consistent. Do not add a clapperboard, play button, gradients, shadows, or extra decoration.

## Colors
- ShowShelf Lime: `#C5FF36`
- Ink: `#111111`
- Charcoal: `#151515`
- White: `#FFFFFF`
- Muted text: `#929292`

## Source files
- `showshelf-app-icon.svg`: square master artwork, lime tile and black symbol.
- `showshelf-adaptive-foreground.svg`: transparent Android adaptive foreground.
- `showshelf-symbol-white.svg`: white symbol for dark backgrounds.
- `showshelf-wordmark.svg`: horizontal icon and wordmark lockup.

## Platform guidance
- Android: use the adaptive foreground with a solid `#C5FF36` background. Use the platform mask; do not bake a rounded mask into the adaptive foreground.
- iOS: generate a 1024 × 1024 full-bleed icon from the square master. Do not add transparent margins or pre-round the corners; iOS applies its own mask.
- Monochrome Android icon: use the symbol as a single-color mask, without the lime tile.
- Keep the app display name as `ShowShelf`.

## Generated platform assets
Run `python3 tool/generate_platform_icons.py` (needs `rsvg-convert` and Pillow) to regenerate every launcher icon, launch image and web icon from the master glyph.
- iOS ships light, dark and tinted 1024 icons (single-size asset catalog, iOS 18 appearances).
- Android adaptive foreground and monochrome layers are scaled to the 66dp safe zone.
- The launch screens (Android, Android 12+, iOS) are lime with the ink glyph centred, matching the in-app splash in `lib/ui/splash.dart`.

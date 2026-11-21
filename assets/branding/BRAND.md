# ShowShelf brand assets

## Core identity
- Mark: a lime film ribbon folded into an "S" around a play button. It says movies, series and your list in one shape.
- Logo: the mark above the "ShowShelf" wordmark, white "Show" and lime "Shelf", on charcoal.
- Primary app icon: lime tile with the charcoal mark. Dark variant: charcoal tile with the lime mark. Light variant: white tile with the charcoal mark.
- Keep the mark's shape and proportions. Do not add a clapperboard, outline, drop shadow or extra decoration. The only effect allowed is the soft neon glow used in the splash.

## Colors
- ShowShelf Lime: `#C6FF4D`
- Charcoal: `#111216`
- White: `#FFFFFF`
- Muted text: `#8E939D`

## Typography
- Poppins (Bold for the wordmark and headings, Medium for labels). Inter remains the UI text face.

## Source files
- `showshelf-mark.svg`: the bare mark, lime on transparent. Source of truth for the geometry (`tool/generate_platform_icons.py` reads it; `lib/ui/brand_mark.dart` mirrors it).
- `showshelf-logo.svg`: stacked logo, mark over wordmark. Wordmark is outlined, so no font is needed.
- `showshelf-wordmark.svg`: horizontal lockup, mark beside the wordmark.
- `showshelf-app-icon.svg`, `-dark.svg`, `-light.svg`: 1024 square masters.
- `showshelf-adaptive-foreground.svg`: transparent Android adaptive foreground.
- `showshelf-symbol-white.svg`: white mark for monochrome and tinted icons.

## Platform guidance
- Android: adaptive foreground (charcoal mark) on a solid `#C6FF4D` background. Use the platform mask; do not bake a rounded mask into the foreground.
- iOS: 1024 full-bleed icons, light (lime), dark (charcoal and lime) and tinted. Do not add transparent margins or pre-round the corners.
- Monochrome Android icon: the white mark without a tile.
- Keep the app display name as `ShowShelf`.

## Generated platform assets
Run `python3 tool/generate_platform_icons.py` (needs `rsvg-convert` and Pillow) to regenerate every launcher icon, launch image and web icon from `showshelf-mark.svg`.
- Launch screens (Android, Android 12+, iOS) are charcoal with only the lime play triangle, in the exact spot where the animated splash in `lib/ui/splash.dart` starts. The splash then winds the ribbon round it, so the hand-off has no jump.
- If you change the splash mark width (`_markWidth` in `lib/ui/splash.dart`), change `SPLASH_MARK_W` in the generator to match and rerun it.

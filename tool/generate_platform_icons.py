#!/usr/bin/env python3
"""Regenerate every platform icon / launch image from the ShowShelf master glyph.

Geometry is the 1024-unit glyph in assets/branding/showshelf-app-icon.svg and the
colours are from assets/branding/BRAND.md. Run from anywhere:

    python3 tool/generate_platform_icons.py

Needs `rsvg-convert` (librsvg) and Pillow. Writes into android/, ios/ and web/.
"""
import json
import subprocess
from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parent.parent
LIME, INK, WHITE, BLACK = '#C5FF36', '#111111', '#FFFFFF', '#000000'

# Glyph bounding box in master units (books + shelf) and its centre.
BBOX = (178, 250, 668, 468)  # x, y, w, h
CX, CY = 512, 484


def glyph(fill):
    return (
        f'<g fill="{fill}">'
        '<rect x="250" y="360" width="140" height="250" rx="34"/>'
        '<rect x="440" y="250" width="140" height="360" rx="34"/>'
        '<g transform="rotate(-12 725 440)"><rect x="655" y="270" width="140" height="340" rx="34"/></g>'
        '<rect x="178" y="650" width="668" height="68" rx="34"/>'
        '</g>'
    )


def centred(fill, canvas, scale):
    """Glyph centred (by bounding box) on a square canvas."""
    return (f'<g transform="translate({canvas / 2} {canvas / 2}) scale({scale}) '
            f'translate({-CX} {-CY})">{glyph(fill)}</g>')


def doc(w, h, body, view=None):
    view = view or f'0 0 {w} {h}'
    return f'<svg xmlns="http://www.w3.org/2000/svg" width="{w}" height="{h}" viewBox="{view}">{body}</svg>'


def render(svg, out, w, h=None, flatten=None):
    out = ROOT / out
    out.parent.mkdir(parents=True, exist_ok=True)
    tmp = out.with_suffix('.tmp.svg')
    tmp.write_text(svg)
    subprocess.run(['rsvg-convert', '-w', str(w), '-h', str(h or w), '-o', str(out), str(tmp)], check=True)
    tmp.unlink()
    if flatten:
        im = Image.open(out).convert('RGBA')
        Image.alpha_composite(Image.new('RGBA', im.size, flatten), im).convert('RGB').save(out)


def write(path, text):
    p = ROOT / path
    p.parent.mkdir(parents=True, exist_ok=True)
    p.write_text(text)


# Master artwork variants (1024 canvas) --------------------------------------------------
def full_bleed(bg, fg):  # iOS: no pre-rounded corners, no transparency
    return doc(1024, 1024, f'<rect width="1024" height="1024" fill="{bg}"/>{glyph(fg)}')


def tile(fg=INK, bg=LIME):  # legacy Android / web "any": brand tile with rounded corners
    return doc(1024, 1024, f'<rect width="1024" height="1024" rx="220" fill="{bg}"/>{glyph(fg)}')


def round_icon():
    return doc(1024, 1024, f'<circle cx="512" cy="512" r="512" fill="{LIME}"/>{glyph(INK)}')


# Adaptive layers: glyph must sit inside the 66dp (61%) safe circle of the 108dp canvas.
ADAPTIVE_SCALE = 0.32


def adaptive(fg):
    return doc(432, 432, centred(fg, 432, ADAPTIVE_SCALE))


def main():
    # ---------------- iOS (single 1024 + dark + tinted, iOS 18) ----------------
    ios = 'ios/Runner/Assets.xcassets/AppIcon.appiconset'
    for old in (ROOT / ios).glob('Icon-App-*.png'):
        old.unlink()
    render(full_bleed(LIME, INK), f'{ios}/AppIcon.png', 1024, flatten=LIME)
    render(full_bleed(INK, LIME), f'{ios}/AppIcon-Dark.png', 1024, flatten=INK)
    render(full_bleed(BLACK, WHITE), f'{ios}/AppIcon-Tinted.png', 1024, flatten=BLACK)
    base = {'idiom': 'universal', 'platform': 'ios', 'size': '1024x1024'}
    write(f'{ios}/Contents.json', json.dumps({
        'images': [
            {**base, 'filename': 'AppIcon.png'},
            {**base, 'appearances': [{'appearance': 'luminosity', 'value': 'dark'}], 'filename': 'AppIcon-Dark.png'},
            {**base, 'appearances': [{'appearance': 'luminosity', 'value': 'tinted'}], 'filename': 'AppIcon-Tinted.png'},
        ],
        'info': {'author': 'xcode', 'version': 1},
    }, indent=2) + '\n')

    # iOS launch image: ink glyph, 156pt wide, centred on a lime storyboard
    launch_view = f'{BBOX[0]} {BBOX[1]} {BBOX[2]} {BBOX[3]}'
    for scale, suffix in ((1, ''), (2, '@2x'), (3, '@3x')):
        w = 156 * scale
        h = round(w * BBOX[3] / BBOX[2])
        render(doc(w, h, glyph(INK), launch_view), f'ios/Runner/Assets.xcassets/LaunchImage.imageset/LaunchImage{suffix}.png', w, h)

    # ---------------- Android ----------------
    res = 'android/app/src/main/res'
    for d, k in {'mdpi': 1, 'hdpi': 1.5, 'xhdpi': 2, 'xxhdpi': 3, 'xxxhdpi': 4}.items():
        render(tile(), f'{res}/mipmap-{d}/ic_launcher.png', int(48 * k))
        render(round_icon(), f'{res}/mipmap-{d}/ic_launcher_round.png', int(48 * k))
        render(adaptive(INK), f'{res}/mipmap-{d}/ic_launcher_foreground.png', int(108 * k))
        render(adaptive(WHITE), f'{res}/mipmap-{d}/ic_launcher_monochrome.png', int(108 * k))
        # Pre-Android-12 launch screen glyph: 156dp wide
        w = int(156 * k)
        h = round(w * BBOX[3] / BBOX[2])
        render(doc(w, h, glyph(INK), launch_view), f'{res}/drawable-{d}/launch_mark.png', w, h)
    adaptive_xml = ('<?xml version="1.0" encoding="utf-8"?>\n'
                    '<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">\n'
                    '    <background android:drawable="@color/ic_launcher_background"/>\n'
                    '    <foreground android:drawable="@mipmap/ic_launcher_foreground"/>\n'
                    '    <monochrome android:drawable="@mipmap/ic_launcher_monochrome"/>\n'
                    '</adaptive-icon>\n')
    write(f'{res}/mipmap-anydpi-v26/ic_launcher.xml', adaptive_xml)
    write(f'{res}/mipmap-anydpi-v26/ic_launcher_round.xml', adaptive_xml)
    write(f'{res}/values/ic_launcher_background.xml',
          f'<?xml version="1.0" encoding="utf-8"?>\n<resources>\n    <color name="ic_launcher_background">{LIME}</color>\n</resources>\n')
    render(full_bleed(LIME, INK), 'android/playstore-icon-512.png', 512, flatten=LIME)

    # ---------------- Web / PWA ----------------
    render(tile(), 'web/favicon.png', 32)
    write('web/favicon.svg', tile())
    render(tile(), 'web/icons/Icon-192.png', 192)
    render(tile(), 'web/icons/Icon-512.png', 512)
    # maskable: full-bleed, glyph inside the 80% safe zone
    mask = lambda: doc(1024, 1024, f'<rect width="1024" height="1024" fill="{LIME}"/>{centred(INK, 1024, 0.85)}')
    render(mask(), 'web/icons/Icon-maskable-192.png', 192, flatten=LIME)
    render(mask(), 'web/icons/Icon-maskable-512.png', 512, flatten=LIME)
    render(full_bleed(LIME, INK), 'web/icons/apple-touch-icon.png', 180, flatten=LIME)


if __name__ == '__main__':
    main()

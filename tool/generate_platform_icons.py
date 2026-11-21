#!/usr/bin/env python3
"""Regenerate every platform icon / launch image from the ShowShelf filmstrip mark.

The geometry is read from assets/branding/showshelf-mark.svg (the single source of
truth, also mirrored in lib/ui/brand_mark.dart) and the colours are from
assets/branding/BRAND.md. Run from anywhere:

    python3 tool/generate_platform_icons.py

Needs `rsvg-convert` (librsvg) and Pillow. Writes into android/, ios/ and web/.
"""
import json
import re
import subprocess
from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parent.parent
LIME, LIME_HI, LIME_LO = '#C6FF4D', '#D6FF72', '#BDF73A'
CHAR, WHITE, BLACK = '#111216', '#FFFFFF', '#000000'

# Mark geometry ------------------------------------------------------------------------
_src = (ROOT / 'assets/branding/showshelf-mark.svg').read_text()
MARK_W, MARK_H = (float(v) for v in re.search(r'viewBox="0 0 ([\d.]+) ([\d.]+)"', _src).groups())
PARTS = dict(re.findall(r'<path id="(\w+)" d="([^"]+)"', _src))
CX, CY = MARK_W / 2, MARK_H / 2

# The Flutter splash (lib/ui/splash.dart) draws the mark this wide, in dp. The native
# launch screens show only the play triangle at the same spot, so the hand-off to the
# animated reveal does not jump.
SPLASH_MARK_W = 112


def mark(fill, parts=('top', 'play', 'bottom')):
    return f'<g fill="{fill}" fill-rule="evenodd">' + ''.join(f'<path d="{PARTS[p]}"/>' for p in parts) + '</g>'


def centred(fill, canvas, height, parts=('top', 'play', 'bottom')):
    """Mark centred (by bounding box) on a square canvas, `height` units tall."""
    s = height / MARK_H
    return (f'<g transform="translate({canvas / 2} {canvas / 2}) scale({s}) translate({-CX} {-CY})">'
            f'{mark(fill, parts)}</g>')


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


GRAD = (f'<defs><linearGradient id="g" x1="0" y1="0" x2="1" y2="1"><stop offset="0" stop-color="{LIME_HI}"/>'
        f'<stop offset="1" stop-color="{LIME_LO}"/></linearGradient></defs>')
ICON_H = 600  # mark height inside the 1024 master icon


# Master artwork variants (1024 canvas) --------------------------------------------------
def full_bleed(bg, fg):  # iOS: no pre-rounded corners, no transparency
    bg_el = f'<rect width="1024" height="1024" fill="{"url(#g)" if bg == LIME else bg}"/>'
    return doc(1024, 1024, (GRAD if bg == LIME else '') + bg_el + centred(fg, 1024, ICON_H))


def tile():  # legacy Android / web "any": rounded lime tile
    return doc(1024, 1024, f'{GRAD}<rect width="1024" height="1024" rx="220" fill="url(#g)"/>{centred(CHAR, 1024, ICON_H)}')


def round_icon():
    return doc(1024, 1024, f'{GRAD}<circle cx="512" cy="512" r="512" fill="url(#g)"/>{centred(CHAR, 1024, ICON_H)}')


# Adaptive layers: the mark must sit inside the 66dp (61%) safe circle of the 108dp canvas.
def adaptive(fg):
    return doc(432, 432, centred(fg, 432, 190))


def launch_canvas(dp, k):
    """Splash mark box (transparent) holding only the lime play triangle, at k px per dp."""
    s = SPLASH_MARK_W / MARK_W
    w = round(SPLASH_MARK_W * k)
    h = round(MARK_H * s * k)
    return doc(w, h, f'<g transform="scale({SPLASH_MARK_W * k / MARK_W})">{mark(LIME, ("play",))}</g>',
               f'0 0 {w} {h}'), w, h


def splash_icon(k):
    """Android 12+ splash icon: 288dp canvas with the launch canvas centred in it."""
    s = SPLASH_MARK_W / MARK_W
    size = round(288 * k)
    mh = MARK_H * s
    body = (f'<g transform="translate({(288 - SPLASH_MARK_W) / 2 * k} {(288 - mh) / 2 * k}) scale({SPLASH_MARK_W * k / MARK_W})">'
            f'{mark(LIME, ("play",))}</g>')
    return doc(size, size, body)


def main():
    # ---------------- iOS (single 1024 + dark + tinted, iOS 18) ----------------
    ios = 'ios/Runner/Assets.xcassets/AppIcon.appiconset'
    for old in (ROOT / ios).glob('Icon-App-*.png'):
        old.unlink()
    render(full_bleed(LIME, CHAR), f'{ios}/AppIcon.png', 1024, flatten=CHAR)
    render(full_bleed(CHAR, LIME), f'{ios}/AppIcon-Dark.png', 1024, flatten=CHAR)
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

    # iOS launch image: the play triangle inside the splash mark box, centred on a charcoal storyboard
    for scale, suffix in ((1, ''), (2, '@2x'), (3, '@3x')):
        svg, w, h = launch_canvas(SPLASH_MARK_W, scale)
        render(svg, f'ios/Runner/Assets.xcassets/LaunchImage.imageset/LaunchImage{suffix}.png', w, h)

    # ---------------- Android ----------------
    res = 'android/app/src/main/res'
    for d, k in {'mdpi': 1, 'hdpi': 1.5, 'xhdpi': 2, 'xxhdpi': 3, 'xxxhdpi': 4}.items():
        render(tile(), f'{res}/mipmap-{d}/ic_launcher.png', int(48 * k))
        render(round_icon(), f'{res}/mipmap-{d}/ic_launcher_round.png', int(48 * k))
        render(adaptive(CHAR), f'{res}/mipmap-{d}/ic_launcher_foreground.png', int(108 * k))
        render(adaptive(WHITE), f'{res}/mipmap-{d}/ic_launcher_monochrome.png', int(108 * k))
        # Pre-Android-12 launch screen: play triangle in the splash mark box
        svg, w, h = launch_canvas(SPLASH_MARK_W, k)
        render(svg, f'{res}/drawable-{d}/launch_mark.png', w, h)
        # Android 12+ system splash icon
        render(splash_icon(k), f'{res}/drawable-{d}/splash_icon.png', int(288 * k))
    adaptive_xml = ('<?xml version="1.0" encoding="utf-8"?>\n'
                    '<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">\n'
                    '    <background android:drawable="@color/ic_launcher_background"/>\n'
                    '    <foreground android:drawable="@mipmap/ic_launcher_foreground"/>\n'
                    '    <monochrome android:drawable="@mipmap/ic_launcher_monochrome"/>\n'
                    '</adaptive-icon>\n')
    write(f'{res}/mipmap-anydpi-v26/ic_launcher.xml', adaptive_xml)
    write(f'{res}/mipmap-anydpi-v26/ic_launcher_round.xml', adaptive_xml)
    write(f'{res}/values/ic_launcher_background.xml',
          '<?xml version="1.0" encoding="utf-8"?>\n<resources>\n'
          f'    <color name="ic_launcher_background">{LIME}</color>\n'
          f'    <color name="launch_background">{CHAR}</color>\n</resources>\n')
    render(full_bleed(LIME, CHAR), 'android/playstore-icon-512.png', 512, flatten=CHAR)

    # ---------------- Web / PWA ----------------
    render(tile(), 'web/favicon.png', 32)
    write('web/favicon.svg', tile())
    render(tile(), 'web/icons/Icon-192.png', 192)
    render(tile(), 'web/icons/Icon-512.png', 512)
    # maskable: full-bleed, mark inside the 80% safe zone
    mask = lambda: doc(1024, 1024, f'{GRAD}<rect width="1024" height="1024" fill="url(#g)"/>{centred(CHAR, 1024, 620)}')
    render(mask(), 'web/icons/Icon-maskable-192.png', 192, flatten=CHAR)
    render(mask(), 'web/icons/Icon-maskable-512.png', 512, flatten=CHAR)
    render(full_bleed(LIME, CHAR), 'web/icons/apple-touch-icon.png', 180, flatten=CHAR)


if __name__ == '__main__':
    main()

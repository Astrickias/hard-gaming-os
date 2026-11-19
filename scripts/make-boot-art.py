"""Erzeugt GRUB-Hintergrund und Installer-Vorschaubilder aus dem HG-Logo.

Aufruf: python3 scripts/make-boot-art.py PROJEKTORDNER  (benötigt Pillow und DejaVu-Schriften)
"""
import sys
from pathlib import Path
from PIL import Image, ImageDraw, ImageFont, ImageFilter

root = Path(sys.argv[1])
logo = Image.open(root / "assets/HG OS.png").convert("RGBA")
FONT = "/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf"
BOLD = "/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf"

def background(w, h):
    img = Image.new("RGB", (w, h), (12, 14, 13))
    d = ImageDraw.Draw(img)
    for y in range(h):  # sanfter Verlauf
        c = int(12 + 14 * y / h)
        d.line([(0, y), (w, y)], fill=(c, c + 2, c + 1))
    glow = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    g = ImageDraw.Draw(glow)
    g.polygon([(int(w*.62), 0), (w, 0), (w, int(h*.55))], fill=(84, 239, 97, 22))
    g.polygon([(0, int(h*.7)), (0, h), (int(w*.35), h)], fill=(84, 239, 97, 14))
    img = Image.alpha_composite(img.convert("RGBA"), glow.filter(ImageFilter.GaussianBlur(6)))
    size = int(h * 0.30)
    l = logo.resize((size, size), Image.LANCZOS)
    img.alpha_composite(l, ((w - size) // 2, int(h * 0.05)))
    return img

grub = background(1920, 1080)
out = root / "packaging/hgos-branding/root/usr/share/grub/themes/hard-gaming-os"
out.mkdir(parents=True, exist_ok=True)
grub.convert("RGB").save(out / "background.png", optimize=True)

prev = background(1280, 720)
d = ImageDraw.Draw(prev)
f, fb = ImageFont.truetype(FONT, 24), ImageFont.truetype(BOLD, 24)
items = ["Hard Gaming OS", "Erweiterte Optionen für Hard Gaming OS", "Hard Gaming OS Snapshots", "UEFI-Firmware-Einstellungen"]
x, y = int(1280 * .32), int(720 * .48)
for i, t in enumerate(items):
    if i == 0:
        d.rounded_rectangle([x - 16, y - 8, int(1280 * .70), y + 34], 6, fill=(28, 48, 33))
    d.text((x, y), t, font=fb if i == 0 else f, fill=(84, 239, 97) if i == 0 else (200, 205, 202))
    y += 52
d.text((640, 660), "Start in 5 Sekunden", font=ImageFont.truetype(FONT, 20), fill=(130, 138, 134), anchor="mm")
cal = root / "installer/calamares/images"
cal.mkdir(parents=True, exist_ok=True)
prev.convert("RGB").save(cal / "bootloader-grub.png", optimize=True)
background(1280, 720).convert("RGB").save(cal / "bootloader-generic.png", optimize=True)
print("ok")

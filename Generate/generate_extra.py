#!/usr/bin/env python3
import struct, zlib, os, json

def create_png(pixels, width, height, filepath):
    def make_chunk(ct, data):
        c = ct + data
        crc = struct.pack('>I', zlib.crc32(c) & 0xffffffff)
        return struct.pack('>I', len(data)) + c + crc
    sig = b'\x89PNG\r\n\x1a\n'
    ihdr = struct.pack('>IIBBBBB', width, height, 8, 6, 0, 0, 0)
    raw = b''
    for y in range(height):
        raw += b'\x00'
        for x in range(width):
            idx = (y * width + x) * 4
            raw += bytes(pixels[idx:idx+4])
    compressed = zlib.compress(raw)
    png = sig + make_chunk(b'IHDR', ihdr) + make_chunk(b'IDAT', compressed) + make_chunk(b'IEND', b'')
    with open(filepath, 'wb') as f:
        f.write(png)

def render_sprite(grid_str, color_map, pixel_size, filepath):
    lines = [l for l in grid_str.strip().split('\n')]
    rows = len(lines)
    cols = max(len(l) for l in lines)
    width = cols * pixel_size
    height = rows * pixel_size
    pixels = [0] * (width * height * 4)
    for r, line in enumerate(lines):
        for c, char in enumerate(line):
            if char in color_map:
                cr, cg, cb = color_map[char]
                for py in range(pixel_size):
                    for px_off in range(pixel_size):
                        x = c * pixel_size + px_off
                        y = r * pixel_size + py
                        idx = (y * width + x) * 4
                        pixels[idx] = cr
                        pixels[idx+1] = cg
                        pixels[idx+2] = cb
                        pixels[idx+3] = 255
    create_png(pixels, width, height, filepath)

def write_contents_json(folder, filename):
    contents = {
        "images": [
            {"filename": filename, "idiom": "universal", "scale": "1x"},
            {"idiom": "universal", "scale": "2x"},
            {"idiom": "universal", "scale": "3x"}
        ],
        "info": {"author": "xcode", "version": 1},
        "properties": {"template-rendering-intent": "original"}
    }
    with open(os.path.join(folder, 'Contents.json'), 'w') as f:
        json.dump(contents, f, indent=2)

ham_colors = {
    'E': (92, 58, 30), 'B': (245, 200, 130), 'D': (232, 176, 96),
    'K': (26, 26, 26), 'H': (255, 255, 255), 'P': (255, 143, 160),
    'W': (196, 148, 74), 'L': (255, 244, 224), 'M': (139, 69, 19),
    'R': (255, 100, 100),  # 하트
    'X': (255, 180, 200),  # 볼 빨개짐
}

base = '/Users/kim-eunchan/Documents/swift/Hampy/Hampy/Assets.xcassets'

# 기뻐하기 (밥 먹고 난 후) - 눈 감고 웃음 + 양볼 빨개짐
yummy = """
....EE....EE....
...EEEE..EEEE...
...EBBB..BBBE...
..EBBBBBBBBBBEE.
.EBBBBBBBBBBBEE.
.EBBEEBBBBEEBBE.
EBBBEEBBBBEEBBEE
EBBBBBBBBBBBBBBE
EXXBBBBBBBBBBXXE
EXXBBBBWWBBBBXXE
EBBBBBBBBBBBBBBE
.EBBBLLLLLLLBBE.
.EBBBLLLLLLLBBE.
..EBBBBBBBBBEE..
....EEEEEEEE....
.....EE..EE.....
"""

# 쓰다듬기 반응 - 눈 감고 행복 + 하트
love = """
....EE....EE....
...EEEE..EEEE...
...EBBB..BBBE..R
..EBBBBBBBBBBEER
.EBBBBBBBBBBBERR
.EBBEEBBBBEEBRRE
EBBBEEBBBBEEBBEE
EBBBBBBBBBBBBBBE
EBPBBBBBBBBBBPBE
EBBBBBBWWBBBBBBE
EBBBBBBBBBBBBBBE
.EBBBLLLLLLLBBE.
.EBBBLLLLLLLBBE.
..EBBBBBBBBBEE..
....EEEEEEEE....
.....EE..EE.....
"""

PX = 8

for name, grid in [('HampyYummy', yummy), ('HampyLove', love)]:
    folder = os.path.join(base, f'{name}.imageset')
    filepath = os.path.join(folder, f'{name}.png')
    render_sprite(grid, ham_colors, PX, filepath)
    write_contents_json(folder, f'{name}.png')
    print(f'✓ {name}.png')

# Extension에도 복사
ext_base = '/Users/kim-eunchan/Documents/swift/Hampy/HampyActivityExtension/Assets.xcassets'
for name in ['HampyYummy', 'HampyLove']:
    src = os.path.join(base, f'{name}.imageset')
    dst = os.path.join(ext_base, f'{name}.imageset')
    os.makedirs(dst, exist_ok=True)
    import shutil
    for f in os.listdir(src):
        shutil.copy2(os.path.join(src, f), os.path.join(dst, f))
    print(f'✓ Extension에 {name} 복사')

print('\n추가 에셋 생성 완료!')

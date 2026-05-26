#!/usr/bin/env python3
"""Canvas 스프라이트 데이터를 고해상도 PNG로 생성"""
import struct
import zlib
import os
import json

def create_png(pixels, width, height, filepath):
    """RGBA 픽셀 배열을 PNG로 저장"""
    def make_chunk(chunk_type, data):
        c = chunk_type + data
        crc = struct.pack('>I', zlib.crc32(c) & 0xffffffff)
        return struct.pack('>I', len(data)) + c + crc

    sig = b'\x89PNG\r\n\x1a\n'
    ihdr = struct.pack('>IIBBBBB', width, height, 8, 6, 0, 0, 0)
    raw = b''
    for y in range(height):
        raw += b'\x00'  # filter none
        for x in range(width):
            idx = (y * width + x) * 4
            raw += bytes(pixels[idx:idx+4])

    compressed = zlib.compress(raw)
    png = sig + make_chunk(b'IHDR', ihdr) + make_chunk(b'IDAT', compressed) + make_chunk(b'IEND', b'')

    with open(filepath, 'wb') as f:
        f.write(png)

def render_sprite(grid_str, color_map, pixel_size, filepath):
    """그리드 문자열을 PNG로 렌더링"""
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
    """imageset Contents.json 생성"""
    contents = {
        "images": [
            {"filename": filename, "idiom": "universal", "scale": "1x"},
            {"idiom": "universal", "scale": "2x"},
            {"idiom": "universal", "scale": "3x"}
        ],
        "info": {"author": "xcode", "version": 1},
        "properties": {"preserves-vector-representation": False, "template-rendering-intent": "original"}
    }
    with open(os.path.join(folder, 'Contents.json'), 'w') as f:
        json.dump(contents, f, indent=2)

# 색상 맵 (햄스터)
ham_colors = {
    'E': (92, 58, 30),
    'B': (245, 200, 130),
    'D': (232, 176, 96),
    'K': (26, 26, 26),
    'H': (255, 255, 255),
    'P': (255, 143, 160),
    'W': (196, 148, 74),
    'L': (255, 244, 224),
    'M': (139, 69, 19),
}

# 옆모습 색상
side_colors = {
    'O': (92, 58, 30),
    'B': (245, 200, 130),
    'b': (232, 176, 96),
    'L': (255, 244, 224),
    'P': (255, 143, 160),
    'K': (26, 26, 26),
    'H': (255, 255, 255),
    'N': (212, 149, 106),
    'W': (196, 148, 74),
}

# 아이콘 색상
seed_colors = {
    'O': (26, 26, 26),
    'D': (61, 61, 61),
    'L': (212, 201, 168),
}

wheel_colors = {
    'D': (200, 168, 112),
    'L': (184, 152, 96),
}

heart_colors = {
    'R': (255, 107, 157),
    'H': (255, 170, 204),
}

apple_colors = {
    'R': (255, 68, 68),
    'G': (78, 205, 196),
    'H': (255, 136, 136),
}

bolt_colors = {
    'Y': (255, 215, 0),
}

# 스프라이트 데이터
PIXEL = 8  # @1x 기준 픽셀 크기

base = '/Users/kim-eunchan/Documents/swift/Hampy/Hampy/Assets.xcassets'

sprites = {
    'Hampy': {
        'grid': """
....EE....EE....
...EEEE..EEEE...
...EBBB..BBBE...
..EBBBBBBBBBBEE.
.EBBBBBBBBBBBEE.
.EBBHKBBBBHKBEE.
EBBBKKBBBBKKBBEE
EBBBBBBBBBBBBBBE
EBPBBBBBBBBBBPBE
EBBBBBBWWBBBBBBE
EBBBBBBBBBBBBBBE
.EBBBLLLLLLLBBE.
.EBBBLLLLLLLBBE.
..EBBBBBBBBBEE..
....EEEEEEEE....
.....EE..EE.....""",
        'colors': ham_colors
    },
    'HampyHungry': {
        'grid': """
....EE....EE....
...EEEE..EEEE...
...EBBB..BBBE...
..EBBBBBBBBBBEE.
.EBBBBBBBBBBBEE.
.EBBHKBBBBHKBEE.
EBBBKKBBBBKKBBEE
EBBBBBBBBBBBBBBE
EBPBBBBBBBBBBPBE
EBBBBBBMMBBBBBBE
EBBBBBBMMBBBBBBE
.EBBBLLLLLLLBBE.
.EBBBLLLLLLLBBE.
..EBBBBBBBBBEE..
....EEEEEEEE....
.....EE..EE.....""",
        'colors': ham_colors
    },
    'HampyTired': {
        'grid': """
....EE....EE....
...EEEE..EEEE...
...EBBB..BBBE...
..EBBBBBBBBBBEE.
.EBBBBBBBBBBBEE.
.EBBEEBBBBEEBBE.
EBBBBBBBBBBBBBBE
EBBBBBBBBBBBBBBE
EBPBBBBBBBBBBPBE
EBBBBBBWBBBBBBEE
EBBBBBBBBBBBBBBE
.EBBBLLLLLLLBBE.
.EBBBLLLLLLLBBE.
..EBBBBBBBBBEE..
....EEEEEEEE....
.....EE..EE.....""",
        'colors': ham_colors
    },
    'HampyUpset': {
        'grid': """
....EE....EE....
...EEEE..EEEE...
...EBBB..BBBE...
..EBBBBBBBBBBEE.
.EBEBBBBBBBBEBE.
.EBBHKBBBBHKBEE.
EBBBKKBBBBKKBBEE
EBBBBBBBBBBBBBBE
EBPBBBBBBBBBBPBE
EBBBBBBBBBBBBBBE
EBBBBBBWWBBBBBBE
.EBBBLLLLLLLBBE.
.EBBBLLLLLLLBBE.
..EBBBBBBBBBEE..
....EEEEEEEE....
.....EE..EE.....""",
        'colors': ham_colors
    },
    'HampyEating': {
        'grid': """
....EE....EE....
...EEEE..EEEE...
...EBBB..BBBE...
..EBBBBBBBBBBEE.
.EBBBBBBBBBBBEE.
.EBBEEBBBBEEBBE.
EBBBBBBBBBBBBBBE
EBBBBBBBBBBBBBBE
EBPBBBBBBBBBBPBE
EPPBBBBBBBBBPPEE
EBBBBBBMMBBBBBBE
.EBBBLLLLLLLBBE.
.EBBBLLLLLLLBBE.
..EBBBBBBBBBEE..
....EEEEEEEE....
.....EE..EE.....""",
        'colors': ham_colors
    },
}

# 옆모습 (쳇바퀴용)
side_sprites = {
    'HampySide': {
        'grid': """
.OO..OO.......
OBBB.OBBO.....
OBBBBBBBbO....
OBHKB.BBbO....
OBKKNBBBbO....
OPBBBBBBbO....
OBBLLLLLBO....
.OBLLLLLBO....
..OBLLLO......
..OO..OO......
..OO..OO......""",
        'colors': side_colors
    },
    'HampySideRun1': {
        'grid': """
.OO..OO.......
OBBB.OBBO.....
OBBBBBBBbO....
OBHKB.BBbO....
OBKKNBBBbO....
OPBBBBBBbO....
OBBLLLLLBO....
.OBLLLLLBO....
..OBLLLO......
.OO...OBO.....
.O.....OO.....""",
        'colors': side_colors
    },
    'HampySideRun2': {
        'grid': """
.OO..OO.......
OBBB.OBBO.....
OBBBBBBBbO....
OBHKB.BBbO....
OBKKNBBBbO....
OPBBBBBBbO....
OBBLLLLLBO....
.OBLLLLLBO....
..OBLLLO......
...OBO.OO.....
...OO...O.....""",
        'colors': side_colors
    },
}

# 아이콘
icons = {
    'SeedIcon': {
        'grid': """
....OO....
...ODDO...
..ODDLDO..
.ODDLDDO..
ODDLDDDO..
ODDDDDDO..
.ODDDDDO..
..ODDDO...
...OOO....
..........""",
        'colors': seed_colors, 'px': 6
    },
    'WheelIcon': {
        'grid': """
...DDDD...
..D....D..
.D..LL..D.
D..L..L..D
D.L.LL.L.D
D.L.LL.L.D
D..L..L..D
.D..LL..D.
..D....D..
...DDDD...""",
        'colors': wheel_colors, 'px': 6
    },
    'PixelHeart': {
        'grid': """
.RR.RR..
RHRRRR..
RRRRRR..
RRRRRR..
.RRRR...
..RR....
........
........""",
        'colors': heart_colors, 'px': 6
    },
    'PixelApple': {
        'grid': """
...G....
..GG....
.RRRR...
RRRRRR..
RRHRRR..
RRRRRR..
.RRRR...
..RR....""",
        'colors': apple_colors, 'px': 6
    },
    'PixelBolt': {
        'grid': """
...YY...
..YY....
.YY.....
YYYYY...
..YY....
.YY.....
YY......
........""",
        'colors': bolt_colors, 'px': 6
    },
}

# 생성
for name, data in sprites.items():
    folder = os.path.join(base, f'{name}.imageset')
    filepath = os.path.join(folder, f'{name}.png')
    render_sprite(data['grid'], data['colors'], PIXEL, filepath)
    write_contents_json(folder, f'{name}.png')
    print(f'✓ {name}.png')

for name, data in side_sprites.items():
    folder = os.path.join(base, f'{name}.imageset')
    filepath = os.path.join(folder, f'{name}.png')
    render_sprite(data['grid'], data['colors'], 6, filepath)
    write_contents_json(folder, f'{name}.png')
    print(f'✓ {name}.png')

for name, data in icons.items():
    folder = os.path.join(base, f'{name}.imageset')
    filepath = os.path.join(folder, f'{name}.png')
    render_sprite(data['grid'], data['colors'], data['px'], filepath)
    write_contents_json(folder, f'{name}.png')
    print(f'✓ {name}.png')

print('\n모든 에셋 생성 완료!')

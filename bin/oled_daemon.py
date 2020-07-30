#!/usr/bin/env python3

import Adafruit_SSD1306
from PIL import Image, ImageDraw, ImageFont
import time
from datetime import datetime
import sys
import pigpio
import DHT

# Set up DHT22
pi = pigpio.pi()
S = []

# Set up display
disp = Adafruit_SSD1306.SSD1306_128_64(rst=None, i2c_address=0x3C)
font = ImageFont.truetype("/home/portex/etc/ARIALUNI.TTF", 14)
disp.begin()
disp.clear()
disp.display()
# Make an image to draw on in 1-bit color.
width = disp.width
height = disp.height
image = Image.new('1', (width, height))
draw = ImageDraw.Draw(image)

# Set up data upload
d = {}

# Display a message on 3 lines, first line big font


def display_message(top_line, line_2, line_3, line_4):
    draw.rectangle((0, 0, width, height), outline=0, fill=0)
    draw.text((0, 0),  top_line, font=font, fill=255)
    draw.text((20, 13),  line_2, font=font, fill=255)
    draw.text((0, 27),  line_3, font=font, fill=255)
    draw.text((20, 41),  line_4, font=font, fill=255)
    disp.image(image)
    disp.display()


try:
    while True:
        S = []
        s = DHT.sensor(pi, 4)
        S.append((4, s))
        for s in S:
            d = s[1].read()
            temperature_01 = '{:3.1f}\xb0C'.format((d[3]))
            humidity_01 = '{:3.1f}%'.format((d[4]))

        S = []
        s = DHT.sensor(pi, 18)
        S.append((18, s))
        for s in S:
            d = s[1].read()
            temperature_02 = '{:3.1f}\xb0C'.format((d[3]))
            humidity_02 = '{:3.1f}%'.format((d[4]))

        now = datetime.now()
        date_message = '{:%Y/%m/%d}'.format(now)
        time_message = '{:%H:%M:%S}'.format(now)
        display_message('Date:', date_message,
                        'Time:', time_message)
        time.sleep(1.9)
        display_message('Temperature_01', temperature_01,
                        'Humidity_01', humidity_01)
        time.sleep(1.9)
        display_message('Temperature_02', temperature_02,
                        'Humidity_02', humidity_02)
        time.sleep(1.9)
except KeyboardInterrupt:
    print('Program is closed by keyboard interrupt')
finally:
    disp.clear()
    disp.display()

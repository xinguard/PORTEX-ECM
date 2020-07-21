#!/usr/bin/env python2.7
import time
import os
from datetime import datetime

from PIL import Image
from PIL import ImageDraw
from PIL import ImageFont

import Adafruit_SSD1306
import Adafruit_DHT

FONT_SIZE = 14
data = {}

def getCPUTemperature():
    res = os.popen('vcgencmd measure_temp').readline()
    return(res.replace("temp=","").replace('\'',chr(0xB0)).replace("\n",""))

disp = Adafruit_SSD1306.SSD1306_128_64(rst=0)

disp.begin()
disp.clear()
disp.display()

width = disp.width
height = disp.height

image = Image.new('1', (width, height))
draw = ImageDraw.Draw(image)

font=ImageFont.truetype("/opt/mcs/ecm/ARIALUNI.TTF", FONT_SIZE)
try:
    while True:
        humidity, temperature = Adafruit_DHT.read_retry(22, 4)
        #load = os.getloadavg()
        draw.rectangle((0, 0, width, height), outline=0, fill=0)
        draw.text((0, 0), 'DATE: {}'.format(time.strftime("%Y/%m/%d")),  font=font, fill=255)
        draw.text((0, FONT_SIZE-1), 'TIME:{}'.format(time.strftime("%H:%M:%S")), font=font, fill=255)
        draw.text((0, 2*FONT_SIZE-1), 'HUM: {:0.2f}%'.format(humidity),  font=font, fill=255)
    	draw.text((0, 3*FONT_SIZE-1), 'TEMP:{:0.2f}\xb0C'.format(temperature),  font=font, fill=255)
        # '{:0.2f}'.format(originalvalue)
        disp.image(image)
        disp.display()
        data['temperature'] = temperature
        data['humidity'] = humidity
        LOG = str(time.time()) + "\tMQTT_F_0\tHTTP_F_0" + "\ttemperature:" + str(temperature) + "\thumidity:" + str(humidity) + "\n"
        print LOG

        sensordata = "/dev/shm/dht22_data.raw"
        datafile = open(sensordata, 'a+')
        datafile.write(LOG)
        datafile.close()

        time.sleep(30)
except KeyboardInterrupt:
    print('close program')
finally:
    disp.clear()
    disp.display()


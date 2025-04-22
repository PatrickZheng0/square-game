import numpy as np
import os
import sys

from collections import defaultdict

try:
    from PIL import Image
except:
    response = input("This script requires the image processing package, Pillow. \nWould you like to download it? (y/n) ")
    if(response.strip() == "y"):
        os.system("pip3 install pillow")
        sys.exit()
    else:
        sys.exit()

if len(sys.argv) < 2:
    print("Usage: PictoCSV.py FileName.jpg bit_depth")
    print("Valid bit_depths are 12, 9, 6, 3.")
    sys.exit()

path = os.getcwd() + '/'
image_path = path + sys.argv[1]
image = np.asarray(Image.open(image_path).convert('RGB'))
rows,cols,depth = image.shape

if len(sys.argv) == 3:
    depth = int(sys.argv[2])
    if depth not in [12,9,6,3]:
        print("Invalid bit depth. Defaulting to 12.")
        depth = 12
else:
    depth = 12
    
depth_shift = 4 - (depth//3)

color_addresses = dict()
address = 0

with open(image_path.rsplit('.', 1)[0] + "_image.mem", "w") as imagemem:
    for row in range(rows):
        for col in range(cols):
            r,g,b = image[row, col]
            r = int(r)>>(4+depth_shift)
            g = int(g)>>(4+depth_shift)
            b = int(b)>>(4+depth_shift)
            rgb12bit = (r<<(8+depth_shift)) | (g<<(4+depth_shift)) | (b<<depth_shift)
            if rgb12bit not in color_addresses:
                color_addresses[rgb12bit] = address
                address += 1
            imagemem.write(f'{color_addresses[rgb12bit]:0{3}x} ')
        imagemem.write('\n')

with open(image_path.rsplit('.', 1)[0] + "_colors.mem", "w") as colormem:
    newline_counter = 0
    for colors in color_addresses:
        colormem.write(f'{colors:0{3}x} ')
        newline_counter += 1
        if (newline_counter % 8 == 0):
            colormem.write('\n')
    while (newline_counter % 8 != 0):
        newline_counter += 1
        colormem.write('000 ')

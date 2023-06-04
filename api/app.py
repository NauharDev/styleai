from flask import Flask, jsonify, request
import numpy as np
from flask_restful import Resource, Api, reqparse
from sklearn.cluster import KMeans
import cv2
from collections import Counter
import math
import base64
from urllib.request import urlopen

app = Flask(__name__)
api = Api(app)


# class ColourDetector(Resource):
#     def get(self, imagePath):
#         for i in range(len(imagePath)):
#             if imagePath[i] == ')':
#                 imagePath[i] = '+'
#         d = {}
#         colour_rec = colour_recs(imagePath)
#         d['colour_rec'] = colour_rec
#         return jsonify(d)


#         # base64_bytes = base64_message.encode('ascii')
#         # decoded_bytes = base64.b64decode(base64_bytes)
#         # string = decoded_bytes.decode('ascii')
#         # rec = colour_recs(string)
#         # return {"colour_rec": rec}
    

# api.add_resource(ColourDetector, '/<string:imagePath>')


def get_image_colour(image_path: str) -> str:
    """
    Return the name of the colour of the clothing item in the image given by image_path.
    """
    req = urlopen(image_path)
    arr = np.asarray(bytearray(req.read()), dtype=np.uint8)
    image = cv2.imdecode(arr, -1)
    image = cv2.cvtColor(image, cv2.COLOR_BGR2RGB)
    image = image.reshape(image.shape[0] * image.shape[1], 3)
    model = KMeans(n_clusters=3, n_init=10)
    labels = Counter(model.fit_predict(image))
    colours = model.cluster_centers_
    dominant_index = max(labels, key=lambda x: labels[x])
    return get_colour_string(list(colours[dominant_index]))


def get_colour_string(colour: list) -> str:
    """
    Return the string name of the colour given by colour.
    """
    colour_options = [
        ((4, 35, 145), 'blue'),
        ((200, 0, 0), 'red'),
        ((0, 128, 0), 'green'),
        ((90, 117, 43), 'olive green'),
        ((255, 165, 0), 'orange'),
        ((2, 11, 77), 'navy blue'),
        ((66, 104, 143), 'grey-blue'),
        ((128, 0, 128), 'purple'),
        ((0, 128, 128), 'teal'),
        ((0, 0, 0), 'black'),
        ((255, 255, 255), 'white'),
        ((190, 190, 190), 'light grey'),
        ((255, 229, 33), 'yellow'),
        ((192, 192, 192), 'charcoal grey'),
        ((128, 0, 0), 'maroon'),
        ((255, 215, 0), 'gold'),
        ((255, 192, 230), 'pink'),
        ((250, 250, 227), 'off white'),
        ((200, 173, 127), 'beige')
    ]

    if all(x <= 225 for x in colour):
        for col in colour:
            col += 30

    min_diff = math.inf
    item_colour = None
    for tup in colour_options:
        r_d = abs(colour[0] - tup[0][0])
        g_d = abs(colour[1] - tup[0][1])
        b_d = abs(colour[2] - tup[0][2])
        total = r_d + g_d + b_d
        if total < min_diff:
            item_colour = tup[1]
            min_diff = total

    return item_colour

# def colour_recs2(image_path: str) -> str:
#     """
#     :param image_path: path of the image to analyze
#     :return: string representing the colour suggestions for the given clothing item
#     """
#     item_colour = get_image_colour(image_path=image_path)
#     if item_colour == 'black':
#         return 'black goes with almost every colour. Try matching with white, black, grey, olive green or orange.'
#     elif item_colour == 'blue':
#         return 'blue goes well with muted colours like beige, brown, white and dark orange.'
#     elif item_colour == 'red':
#         return 'red goes well with white, light blue and earthy green tones.'
#     elif item_colour == 'green':
#         return 'green goes well with brown, grey, white and purple accents.'
#     elif item_colour == 'olive green':
#         return 'olive green goes well with beige, navy blue, white, brown, black and purple accents.'
#     elif item_colour == 'navy blue':
#         return 'navy blue goes well with white, beige, lighter shades of blue, and dark oranges and yellows.'
#     elif item_colour == 'orange':
#        return 'orange goes well with black, beige, dark grey, blue and yellow accents.'
#     elif item_colour == 'purple':
#         return 'purple goes well with white, off-white, grey, beige, dark blue and yellow accents.'
#     elif item_colour == 'grey-blue':
#         return 'grey-blue goes well with orange, black, navy blue and white.'
#     elif item_colour == 'teal':
#         return 'teal goes well with orange, off-white, beige, white and gold.'
#     elif item_colour == 'white':
#         return 'white goes well with almost every colour. It works exceptionally well with navy blue, olive green, ' \
#                 'black, gold and pink.'
#     elif item_colour == 'light grey':
#         return 'light grey goes well with navy blue, beige, red, yellow and orange, along with gold accents.'
#     elif item_colour == 'yellow':
#         return 'a bright yellow colour works well with black, blue, green, olive green and white.'
#     elif item_colour == 'charcoal grey':
#         return 'charcoal grey goes well with black, maroon, white, orange and light pink.'
#     elif item_colour == 'maroon':
#         return 'maroon goes well with off-white, navy blue, olive green, light grey and black.'
#     elif item_colour == 'gold':
#         return 'red goes well with white, light blue and earthy green tones.'
#     elif item_colour == 'pink':
#         return 'pink goes well with white, light grey, charcoal grey, red, black and light blue.'
#     elif item_colour == 'off white':
#         return 'off white goes well with navy blue, pink, brown, beige, maroon and gold.'
#     else:
#         return 'beige goes well with white, black, maroon, brown, blue and yellow'


@app.route('/recs', methods=['GET'])
def colour_recs() -> str:
    """
    :param image_path: path of the image to analyze
    :return: string representing the colour suggestions for the given clothing item
    """
    d = {}
    modified = str(request.args['imagePath']).replace('!', '/')
    modified = modified.replace('nozzyk', '&')
    modified = modified.replace('nozzzyk', '%')
    print(modified)
    # d['colour_rec'] = modified
    item_colour = get_image_colour(image_path=modified)
    if item_colour == 'black':
        d['colour_rec'] = 'black goes with almost every colour. Try matching with white, black, grey, olive green or orange.'
    elif item_colour == 'blue':
        d['colour_rec'] = 'blue goes well with muted colours like beige, brown, white and dark orange.'
    elif item_colour == 'red':
        d['colour_rec'] = 'red goes well with white, light blue and earthy green tones.'
    elif item_colour == 'green':
        d['colour_rec'] = 'green goes well with brown, grey, white and purple accents.'
    elif item_colour == 'olive green':
        d['colour_rec'] = 'olive green goes well with beige, navy blue, white, brown, black and purple accents.'
    elif item_colour == 'navy blue':
        d['colour_rec'] = 'navy blue goes well with white, beige, lighter shades of blue, and dark oranges and yellows.'
    elif item_colour == 'orange':
       d['colour_rec'] = 'orange goes well with black, beige, dark grey, blue and yellow accents.'
    elif item_colour == 'purple':
        d['colour_rec'] = 'purple goes well with white, off-white, grey, beige, dark blue and yellow accents.'
    elif item_colour == 'grey-blue':
        d['colour_rec'] = 'grey-blue goes well with orange, black, navy blue and white.'
    elif item_colour == 'teal':
        d['colour_rec'] = 'teal goes well with orange, off-white, beige, white and gold.'
    elif item_colour == 'white':
        d['colour_rec'] = 'white goes well with almost every colour. It works exceptionally well with navy blue, olive green, ' \
                'black, gold and pink.'
    elif item_colour == 'light grey':
        d['colour_rec'] = 'light grey goes well with navy blue, beige, red, yellow and orange, along with gold accents.'
    elif item_colour == 'yellow':
        d['colour_rec'] = 'a bright yellow colour works well with black, blue, green, olive green and white.'
    elif item_colour == 'charcoal grey':
        d['colour_rec'] = 'charcoal grey goes well with black, maroon, white, orange and light pink.'
    elif item_colour == 'maroon':
        d['colour_rec'] = 'maroon goes well with off-white, navy blue, olive green, light grey and black.'
    elif item_colour == 'gold':
        d['colour_rec'] = 'red goes well with white, light blue and earthy green tones.'
    elif item_colour == 'pink':
        d['colour_rec'] = 'pink goes well with white, light grey, charcoal grey, red, black and light blue.'
    elif item_colour == 'off white':
        d['colour_rec'] = 'off white goes well with navy blue, pink, brown, beige, maroon and gold.'
    else:
        d['colour_rec'] = 'beige goes well with white, black, maroon, brown, blue and yellow'

    return jsonify(d)

if __name__ == '__main__':
    app.run(port=3333, debug=True)
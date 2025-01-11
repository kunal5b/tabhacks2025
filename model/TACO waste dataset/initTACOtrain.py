import google.generativeai as genai
import PIL.Image
from PIL import Image
import requests
from io import BytesIO

rating = []

genai.configure(api_key="AIzaSyCuSUfxq9uTa1QIDbMtz6PAPnzk0cbNxJ0")

model = genai.GenerativeModel("gemini-1.5-flash")


import json

with open('model/TACO waste dataset/annotations.json') as f:
    data = json.load(f)

images = data.get("images", [])

scale = "25/25: Extraordinary, irreplaceable contributions (e.g., saving a life). 20-22/25: Significant and transformative community impact (e.g., organizing large-scale volunteer events, planting forests) 15-19/25: Meaningful and positive contributions (e.g., consistent environmental cleanup, mentoring youth). 10-14/25: Helpful but smaller-scale contributions (e.g., assisting at events, minor volunteering) 1-9/25: Actions with very limited impact (e.g., sporadic good deeds without lasting effect) 0/25: Harmful or destructive acts."
caption = "picked up trash"

for image in images:
    flickr_url = image.get("flickr_url")
    imag = Image.open(BytesIO(requests.get(flickr_url).content))
    response = model.generate_content(["give me a community service score 0-25 based off of the point scale provided. Only give me the number and nothing else", imag, caption, scale])
    rating.append(int(response.text))

print(rating)

#average function for rating
top = 0
count = 0

for i in rating:
    top += i
    count += 1

average = top / count

#scatter plot
import matplotlib.pyplot as plt
import numpy as np

y = np.array(rating)
x = np.arange(1, 1501)

plt.scatter(x, y)
plt.show

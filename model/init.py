import google.generativeai as genai
import PIL.Image
from PIL import Image
import requests
from io import BytesIO

rating = []
genai.configure(api_key="AIzaSyCuSUfxq9uTa1QIDbMtz6PAPnzk0cbNxJ0")

model = genai.GenerativeModel("gemini-1.5-flash")




# replace with path to image
organ = PIL.Image.open("model/thisisimage.png")
imag = Image.open(BytesIO(requests.get("https://farm66.staticflickr.com/65535/47066083354_b7e8968056_o.png").content))


#replace with corresponding caption
caption = "set this building on fire"



#fixed scale
scale = "25/25: Extraordinary, irreplaceable contributions (e.g., saving a life). 20-22/25: Significant and transformative community impact (e.g., organizing large-scale volunteer events, planting forests) 15-19/25: Meaningful and positive contributions (e.g., consistent environmental cleanup, mentoring youth). 10-14/25: Helpful but smaller-scale contributions (e.g., assisting at events, minor volunteering) 1-9/25: Actions with very limited impact (e.g., sporadic good deeds without lasting effect) 0/25: Harmful or destructive acts."


response = model.generate_content(["give me a community service score 0-25 and a reason based off of the point scale provided. Only give me the number as a response, nothing else", organ, caption, scale])
print(response.text)
rating.append(int(response.text))
print(rating)
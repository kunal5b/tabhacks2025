import google.generativeai as genai
import PIL.Image
from PIL import Image
import requests
from io import BytesIO
import json
import matplotlib.pyplot as plt
import numpy as np
import time

# Configure the GenAI API
genai.configure(api_key="AIzaSyDdP7jFq9KtAu_nlNVVVYyFSW0FtLcFISQ")
model = genai.GenerativeModel("gemini-1.5-flash")


# Load dataset annotations
with open('model/TACO waste dataset/annotations.json') as f:
    data = json.load(f)

images = data.get("images", [])

# Define the scoring scale and caption
scale = ("25/25: Extraordinary, irreplaceable contributions (e.g., saving a life). "
         "20-22/25: Significant and transformative community impact "
         "(e.g., organizing large-scale volunteer events, planting forests). "
         "15-19/25: Meaningful and positive contributions "
         "(e.g., consistent environmental cleanup, mentoring youth). "
         "10-14/25: Helpful but smaller-scale contributions "
         "(e.g., assisting at events, minor volunteering). "
         "1-9/25: Actions with very limited impact (e.g., sporadic good deeds without lasting effect). "
         "0/25: Harmful or destructive acts.")
caption = "picked up trash"

# Initialize ratings list
ratings = []

for image in images[:300]:
    flickr_url = image.get("flickr_url")
    if flickr_url:  # Check if URL is present
        try:
            # Fetch the image
            response = requests.get(flickr_url)
            response.raise_for_status()
            imag = Image.open(BytesIO(response.content))
            
            # Prepare the prompt
            prompt = (f"Analyze the image and caption '{caption}'. Based on the scale: {scale}, "
                      "give me a community service score (0-25). Only return the number.")
            
            # Generate a score
            result = model.generate_content([prompt])
            score = int(result.text)  # Ensure you access the correct part of the response
            
            ratings.append(score)
        except Exception as e:
            print(f"Error processing image {flickr_url}: {e}")
        finally:
            time.sleep(5)

# Calculate the average score
if ratings:
    average = sum(ratings) / len(ratings)
    print(f"Average rating: {average}")

# Plot the scatter plot
if ratings:
    y = np.array(ratings)
    x = np.arange(1, len(ratings) + 1)

    plt.scatter(x, y)
    plt.xlabel("Image Index")
    plt.ylabel("Community Service Score")
    plt.title("Community Service Scores of Images")
    plt.show()

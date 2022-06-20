from selenium import webdriver
from selenium.webdriver.common.by import By
import time
import pandas as pd
import math
from bs4 import BeautifulSoup

# Start driver and navigate to the reviews page of 
# Jurassic World: Dominion

driver = webdriver.Chrome('/Users/spencer/Downloads/chromedriver')
driver.get("https://www.imdb.com/title/tt8041270/reviews")

# Find the load more button so we can click it
# I use the SelectorGadget chrome extension to help with this

loadMoreButton = driver.find_element(by = By.XPATH, value = "//*[(@id = 'load-more-trigger')]")

# There were 1174 reviews when I pulled the data,
# requests returned 25 reviews at a time. 

# Potention Update: remove hard-coding of number, instead scrape number
# of reviews. Or, use a while loop to click the button while it is there.

for i in range(math.floor(1174/25)):
    loadMoreButton.click()
    time.sleep(2)

# Now process HTML with BeautifulSoup

html = driver.page_source.encode('utf-8')
soup = BeautifulSoup(html, 'lxml')

# Instead of pulling individual divs, 
# I decided to pull the full review-container divs and process in R.

#mydivs = soup.find_all("div", "text show-more__control clickable")
#mydivs2 = soup.find_all("div", "text show-more__control")
#alldivs = mydivs + mydivs2
#ratings = soup.find_all("div", "ipl-ratings-bar")
#rates = {'ratings':ratings}

# Pull each review container, convert to dataframe and save to csv.

mydivs = soup.find_all("div", "review-container")
dict = {'rev': mydivs}
df = pd.DataFrame(dict)
df.to_csv('../data/reviews.csv')

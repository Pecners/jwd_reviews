library(tidyverse)
library(rvest)

# The data here is the full review container,
# so we'll have to pull out the parts we want.

data <- read_csv("data/reviews.csv")

# Create character vector of review title

titles <- map_chr(1:nrow(data), function(i) {
  d <- data[[i,2]]
  read_html(d) %>%
    html_element(".title") %>%
    html_text()
})

# Create dbl vector of reviewer's rating (out of 10)

ratings <- map_dbl(1:nrow(data), function(i) {
  d <- data[[i,2]]
  read_html(d) %>%
    html_element(".ipl-ratings-bar") %>%
    html_text() %>%
    str_remove_all("\n") %>%
    str_remove_all("/10") %>%
    as.numeric()
})

# Create vector of reviews. Note that certain of the
# divs are "clickable" -- these are the spoiler divs

reviews <- map_chr(1:nrow(data), function(i) {
  d <- data[[i,2]]
  
  if (str_detect(d, "text show-more__control clickable")) {
    c <- ".text.show-more__control.clickable"
  } else {
    c <- ".text.show-more__control"
  }
  read_html(d) %>%
    html_element(c) %>%
    html_text()
})

# Combine it all in a single tibble

all <- tibble(
  id = 1:length(reviews),
  review_title = titles,
  reviewer_rating = ratings,
  review = reviews
)

write_csv(all, "data/tidy_reviews.csv")

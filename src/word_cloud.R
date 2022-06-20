library(tidyverse)
library(tidytext)
library(wordcloud2)
library(rvest)
library(ggwordcloud)
library(MetBrewer)

data <- read_csv("data/reviews.csv")

titles <- map_chr(1:nrow(data), function(i) {
  d <- data[[i,2]]
  read_html(d) %>%
    html_element(".title") %>%
    html_text()
})

ratings <- map_dbl(1:nrow(data), function(i) {
  d <- data[[i,2]]
  read_html(d) %>%
    html_element(".ipl-ratings-bar") %>%
    html_text() %>%
    str_remove_all("\n") %>%
    str_remove_all("/10") %>%
    as.numeric()
})

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

all <- tibble(
  id = 1:length(reviews),
  review_title = titles,
  reviewer_rating = ratings,
  review = reviews
)

word_freq <- all %>%
  #filter(reviewer_rating < 5) %>%
  unnest_tokens(word, review) %>%
  anti_join(get_stopwords()) %>%
  filter(!word %in% c("jurassic", "world", "dominion", "movie", "film")) %>%
  group_by(word) %>%
  tally() %>%
  mutate(ceil = ifelse(n > 800, 800, n))

c <- met.brewer("Homer1")
cc <- grDevices::colorRampPalette(c[4:5])(max(word_freq$n))

cdf <- tibble(
  id = 1:max(word_freq$n),
  cc = cc
)

word_freqc <- word_freq %>%
  left_join(cdf, by = c("n" = "id")) %>%
  arrange(desc(n))

word_freq %>%
  #mutate(freq = log(n)) %>%
  select(word, freq = n) %>%
  arrange(desc(freq)) %>%
  wordcloud2(figPath = "trex.png", size = .7, 
             minRotation = -1, maxRotation = 1,
             widgetsize = c(1200,1200), gridSize = 5, ellipticity = 1,
             #fontFamily = "Ravi Prakash", 
             color = word_freqc$cc, backgroundColor = "black")



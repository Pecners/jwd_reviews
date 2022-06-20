library(tidyverse)
library(tidytext)
library(wordcloud2)
library(MetBrewer)

# Get word frequency while removing stopwords and movie/title words

word_freq <- all %>%
  #filter(reviewer_rating < 5) %>%
  unnest_tokens(word, review) %>%
  anti_join(get_stopwords()) %>%
  filter(!word %in% c("jurassic", "world", "dominion", "movie", "film")) %>%
  group_by(word) %>%
  tally() 

# I'm not using the full palette here, but but used it as a starting point
# NOTE: The reason I'm selecting these colors from the palette is because
# they show good contrast against the black background.
# https://webaim.org/articles/contrast/

c <- met.brewer("Homer1")
cc <- grDevices::colorRampPalette(c[4:5])(max(word_freq$n))

# There's probably a better way to do this, but this is how I'm manually
# assigning the color scale. With ggplot, I would do this with `scale_color_*()`,
# but to do it manually, I'm creating the palette, indexing it, and joining the
# index with the frequency value.

cdf <- tibble(
  id = 1:max(word_freq$n),
  cc = cc
)

word_freqc <- word_freq %>%
  left_join(cdf, by = c("n" = "id")) %>%
  arrange(desc(n))

# Create the word cloud. I really had to finesse this one because the T-Rex
# mask is so constricted, i.e. the words won't find a location with each 
# random placement. So, I experimented with sizing, and I refreshed several
# times until the largest words ("dinosaur", "character") showed up.

word_freq %>%
  #mutate(freq = log(n)) %>%
  select(word, freq = n) %>%
  arrange(desc(freq)) %>%
  wordcloud2(figPath = "img/trex.png", size = .7, 
             minRotation = -1, maxRotation = 1,
             widgetsize = c(1200,1200), gridSize = 5, ellipticity = 1,
             #fontFamily = "Ravi Prakash", 
             color = word_freqc$cc, backgroundColor = "black")



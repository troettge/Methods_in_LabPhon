library(tidyverse)
library(lubridate)

df <- read_csv("data/hyperlinks_reviewed.csv")

subsample <- df %>% 
  filter(type == "data/scripts/tutorials/software")

dir.create("articles/PDF_subsample", showWarnings = FALSE)

for (article in unique(subsample$title)) {
  file.copy(
    from = paste0(
      "articles/PDF/",
      article,
      " (",
      unique(year(subsample$date[subsample$title == article])),
      ")",
      ".pdf"
    ),
    to = paste0("articles/PDF_subsample/", article, ".pdf")
  )
}

# Write csv: a copy of hyperlinks_reviewed called subsample
# Add columns to it
# Make it into Numbers doc with a sheet for each nerd




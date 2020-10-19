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

write_csv(subsample, "data/subsample.csv")
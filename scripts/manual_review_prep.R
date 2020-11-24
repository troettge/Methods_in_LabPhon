library(tidyverse)
library(lubridate)

# Load subsample (that's already checked) & all articles
subsample <- read_csv("data/subsample.csv")
load(file = "data/articles.RData")

# Filter out all articles that appeared in the subsample
manual_review <- anti_join(articles, subsample, by = "title")

# # Append directory structure
# dir.create("articles/PDF_manual_review", showWarnings = FALSE)
# dir.create("articles/PDF_manual_review/Timo", showWarnings = FALSE)
# dir.create("articles/PDF_manual_review/Mathias", showWarnings = FALSE)
# 
# # Copy PDF files to respective directories
# # First half of all remaining articles goes to Mathias
# for (article in manual_review$title[1:38]) {
#   file.copy(
#     from = paste0("articles/PDF/",
#                   article,
#                   " (",
#                   unique(year(
#                     manual_review$date[manual_review$title == article]
#                   )),
#                   ")",
#                   ".pdf"),
#     to = paste0("articles/PDF_manual_review/Mathias/", article, ".pdf")
#   )
# }
# 
# # Second half of all remaining articles goes to Timo
# for (article in manual_review$title[39:76]) {
#   file.copy(
#     from = paste0("articles/PDF/",
#                   article,
#                   " (",
#                   unique(year(
#                     manual_review$date[manual_review$title == article]
#                   )),
#                   ")",
#                   ".pdf"),
#     to = paste0("articles/PDF_manual_review/Timo/", article, ".pdf")
#   )
# }

# Write titles to disk (will be processed in Numbers)
write_csv(manual_review %>% select(title), "data/manual_review.csv")

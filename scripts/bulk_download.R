library(xml2)
library(rvest)
library(httr)
library(stringr)
library(pdftools)
library(lubridate)

# scrape together all links to LabPhon articles
# the parameters "?f=1" already exclude the two non-article types: "editorial" & "correction"
# also note the trailing '200', this currently ensures that all LabPhon articles will be retrieved (September 2020: There are 101 accessible articles)
scrape_this <- "https://www.journal-labphon.org/articles/?f=1&order=section&app=200"
base_URL <- "https://www.journal-labphon.org"
page <- read_html(scrape_this)
links <- html_attr(html_nodes(page, "a"), "href")

# minor string cleanup
articles <- links[str_ends(links, "download/")] %>%
  str_squish()

# construct URLs
download_URLS <- paste0(base_URL, articles)

# prepare directory structure
dir.create("articles", showWarnings = FALSE)
dir.create("articles/XML", showWarnings = FALSE)
dir.create("articles/PDF", showWarnings = FALSE)

# get files, store in temp, get OG filenames, rename & sort into folders
# remove the head() to actually retrieve all articles, this just gets the first six
for (url in head(download_URLS)) {
  file <- GET(url, write_disk("articles/temp.file"))
  filename <- str_remove(headers(file)$`content-disposition`, "attachment; filename=")
  ifelse(endsWith(filename, ".xml"),
         file.rename("articles/temp.file", paste0("articles/XML/", filename)),
         file.rename("articles/temp.file", paste0("articles/PDF/", filename))
         )
}

# rename PDFs with authors & year (non-standard for now)
for (PDF in list.files("articles/PDF", full.names = TRUE)) {
  authors <- pdf_info(PDF)$keys$Author
  year <- pdf_info(PDF)$created %>% year() %>% as.character()
  file.rename(PDF, paste0("articles/PDF/", year, " ", authors, ".pdf"))
}


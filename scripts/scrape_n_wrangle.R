# Load packages -----------------------------------------------------------

library(xml2)
library(rvest)
library(httr)
library(stringr)
library(readr)
library(pdftools)
library(lubridate)
library(tibble)
library(statcheck)


# Scrape LabPhon site -----------------------------------------------------

# gather all links to LabPhon articles
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
dir.create("articles/HTML", showWarnings = FALSE)

# get files, store in temp, get OG filenames, rename & sort into folders
for (url in download_URLS) {
  file <- GET(url, write_disk("articles/temp.file"))
  filename <- str_remove(headers(file)$`content-disposition`, "attachment; filename=")
  ifelse(endsWith(filename, ".xml"),
         file.rename("articles/temp.file", paste0("articles/XML/", filename)),
         file.rename("articles/temp.file", paste0("articles/PDF/", filename))
         )
}

# Rename & convert --------------------------------------------------------

# rename PDFs with article title (so that that corresponding XMLs and PDFs can share a name)
for (PDF in list.files("articles/PDF", full.names = TRUE)) {
  title <- pdf_info(PDF)$keys$Title %>% str_remove_all("[/]")
  year <- pdf_info(PDF)$created %>% year() %>% as.character()
  file.rename(PDF, paste0("articles/PDF/", title, " (", year, ").pdf"))
}

# rename XMLs with article title & write an HTML copy (for use with statcheck)
for (XML in list.files("articles/XML", full.names = TRUE)) {
  xfile <- read_xml(XML)
  title <- xml_find_all(xfile, 
                        "/article/front/article-meta/title-group/article-title") %>% 
    xml_text() %>% 
    str_remove_all("[/]")
  date <- xml_find_all(xfile, "/article/front/article-meta/pub-date/year") %>% xml_text()
  file.rename(XML, paste0("articles/XML/", title, " (", year, ").xml"))
  write_html(xfile, paste0("articles/HTML/", title, " (", year, ").html"))
}

# Condense article information --------------------------------------------

# construct initial tibble 'articles'
articles <- tibble(
  title = character(),
  type = character(),
  date = character(),
  names = list(),
  abstract = character(),
  text = character(),
  links = list(),
  keywords = list()
)

# gather all desired pieces of information in the tibble 'articles'
for (XML in list.files("articles/XML/", full.names = TRUE)) {
  # read file
  xfile <- read_xml(XML)
  # get article type (just to make sure there's no editorials etc. that made their way into the downloaded files)
  type <- xml_find_first(xfile, "@article-type") %>% xml_text()
  # get publication date
  date <-
    xml_find_first(xfile, "/article/front/article-meta/pub-date") %>% xml_attr("iso-8601-date")
  # get title
  title <-
    xml_find_first(xfile,
                 "/article/front/article-meta/title-group/article-title") %>% xml_text()
  # get author surname(s)
  names <- xml_find_all(xfile,
                        "/article/front/article-meta/contrib-group/contrib/name/surname") %>%
    xml_text()
  # get abstract
  abstract <- xml_find_first(xfile, "//abstract") %>% xml_text()
  # get and concatenate all running text (all paragraphs)
  # this excludes section titles, figures, tables etc.
  text <- xml_find_all(xfile, "/article/body/sec/p") %>%
    xml_text(trim = TRUE) %>%
    str_c(sep = "", collapse = " ")
  # get hyperlinks
  links <- xml_find_all(xfile, "//ext-link") %>% xml_attr("href")
  # get keywords
  keywords <- xml_find_all(xfile, "//kwd") %>% xml_text()
  
  # put together a new row for 'articles'
  article <- tibble(
    title,
    type,
    date,
    names = list(names),
    abstract,
    text,
    links = list(links),
    keywords = list(keywords)
  )
  # add the new row to 'articles'
  if (article$type == "research-article") {
    articles <- articles %>% add_row(article)
  }
}

# Statcheck ---------------------------------------------------------------

# run statcheck
statcheck_out <- checkdir("articles/HTML/")


# Write output ------------------------------------------------------------

dir.create("data", showWarnings = FALSE)
save(articles, file = "data/articles.RData")
write_csv(statcheck_out, "data/statcheck_out.csv")

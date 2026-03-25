library(xml2)
library(purrr)
library(tibble)
library(yaml12)
library(stringi)

feed_url <- "https://clisp.fr/feed/"
output_dir <- here::here("blog", "newsletter")

rss <- tryCatch(read_xml(feed_url), error = \(e) {
  message("Could not fetch RSS feed: ", e$message)
  NULL
})

if (is.null(rss)) quit(save = "no", status = 0)

ns <- xml_ns(rss)

old_locale <- Sys.getlocale("LC_TIME")
Sys.setlocale("LC_TIME", "C")
on.exit(Sys.setlocale("LC_TIME", old_locale))

parse_description <- \(desc_html) {
  doc <- tryCatch(read_html(paste0("<body>", desc_html, "</body>")), error = \(e) NULL)
  if (is.null(doc)) return(list(text = desc_html, image_url = NA_character_))
  img <- xml_find_first(doc, ".//img[@src]")
  image_url <- if (is.na(img)) NA_character_ else xml_attr(img, "src")
  image_url <- sub("\\?.*$", "", image_url)
  text <- trimws(gsub("\\s+", " ", xml_text(doc)))
  list(text = text, image_url = image_url)
}

slugify <- \(title) {
  title |>
    stri_trans_general("Latin-ASCII") |>
    tolower() |>
    gsub("[^a-z0-9]+", "-", x = _) |>
    gsub("^-|-$", "", x = _)
}

items <- xml_find_all(rss, "//item")

newsletters <- items |>
  keep(\(item) "Newsletters" %in% xml_text(xml_find_all(item, "category"))) |>
  map(\(item) {
    desc_raw <- xml_text(xml_find_first(item, "description"))
    parsed <- parse_description(desc_raw)
    tibble(
      title = xml_text(xml_find_first(item, "title")),
      link = xml_text(xml_find_first(item, "link")),
      date = as.Date(xml_text(xml_find_first(item, "pubDate")), format = "%a, %d %b %Y %H:%M:%S"),
      author = xml_text(xml_find_first(item, "dc:creator", ns)),
      description = substr(parsed$text, 1, 300),
      image_url = parsed$image_url
    )
  }) |>
  list_rbind() |>
  (\(df) {
    df$slug <- slugify(df$title)
    df
  })()

if (!dir.exists(output_dir)) dir.create(output_dir, recursive = TRUE)
existing <- list.dirs(output_dir, full.names = FALSE, recursive = FALSE)
to_create <- newsletters[!newsletters$slug %in% existing, ]

write_newsletter <- \(row) {
  post_dir <- file.path(output_dir, row$slug)
  dir.create(post_dir, recursive = TRUE, showWarnings = FALSE)

  img_file <- NULL
  if (!is.na(row$image_url)) {
    img_ext <- tools::file_ext(sub("\\?.*$", "", row$image_url))
    if (img_ext == "") img_ext <- "png"
    img_file <- paste0("image.", img_ext)
    tryCatch(
      download.file(row$image_url, file.path(post_dir, img_file), mode = "wb", quiet = TRUE),
      error = \(e) {
        message("Failed to download image for: ", row$title)
        img_file <<- NULL
      }
    )
  }

  frontmatter <- list(
    title = row$title,
    date = format(row$date),
    author = row$author,
    categories = list("newsletter"),
    description = row$description,
    source_link = row$link
  )
  if (!is.null(img_file)) frontmatter$image <- img_file

  body <- sprintf("[Lire sur le site du CLiSP](%s){.btn .btn-primary}", row$link)
  content <- paste0("---\n", format_yaml(frontmatter), "\n---\n\n", body, "\n")
  writeLines(content, file.path(post_dir, "index.qmd"))
}

pwalk(to_create, \(...) write_newsletter(list(...)))

message(sprintf(
  "Newsletter sync done: %d found, %d new, output in %s",
  nrow(newsletters), nrow(to_create), output_dir
))

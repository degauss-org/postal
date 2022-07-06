#!/usr/local/bin/Rscript

dht::greeting()

doc <- "
      Usage:
      entrypoint.R <filename>
      "

opt <- docopt::docopt(doc)

## for interactive testing
## opt <- docopt::docopt(doc, args = 'address.csv')

d <- readr::read_csv(opt$filename, show_col_types = FALSE)
cli::cli_alert_success("imported data from {opt$filename}")
if (!"address" %in% names(d)) cli::cli_alert_("no column called address found in the input file", call. = FALSE)

## normalized addresses
d$address_clean <- dht::clean_address(d$address)
cli::cli_alert_info("expanding addresses...")
d$normalized_addresses <-
  system2("/code/libpostal/src/libpostal", "--json", input = d$address_clean, stdout = TRUE) |>
  purrr::map(jsonlite::fromJSON) |>
  purrr::map("expansions")

if (TRUE) { # to take the first result for each set of expansions
  d$normalized_address <- purrr::map_chr(d$normalized_addresses, 1)
  d$normalized_addresses <- NULL
}

if (FALSE) { # how/when to return all expansions?
  d |>
    dplyr::select(-normalized_address) |>
    tidyr::unnest(normalized_addresses)
  }

dht::write_geomarker_file(d, filename = opt$filename)

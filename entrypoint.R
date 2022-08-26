#!/usr/local/bin/Rscript

dht::greeting()

doc <- "
      Usage:
      entrypoint.R <filename>
      "

opt <- docopt::docopt(doc)

## for interactive testing
## opt <- docopt::docopt(doc, args = 'address.csv')

d_in <- readr::read_csv(opt$filename, show_col_types = FALSE)
cli::cli_alert_success("imported data from {opt$filename}")
if (!"address" %in% names(d_in)) cli::cli_alert_("no column called address found in the input file", call. = FALSE)

d <-
  d_in |>
  dplyr::select(input_address = address) |>
  dplyr::distinct()

d$cleaned_address <- dht::clean_address(d$input_address)

#### /code/libpostal/src/address_parser
cli::cli_alert_info("parsing addresses...")
parser_output <- system2("/code/libpostal/src/address_parser", input = d$cleaned_address, stdout = TRUE)

d$parsed_address_components <-
  parser_output[-c(1:11)] |>
  paste(collapse = " ") |>
  strsplit("Result:", fixed = TRUE) |>
  purrr::transpose() |>
  purrr::modify(unlist) |>
  purrr::modify(jsonlite::fromJSON)

# x must be a parsed_address_components_list
# components is character vector of components to paste together
make_parsed_address <- function(x, components = c("house_number", "road", "city", "state", "postcode")) {
  components |>
    purrr::map(~ purrr::pluck(x, .x)) |>
    purrr::compact() |>
    paste(collapse = " ")
}

d <- d |>
  dplyr::rowwise(input_address) |>
  dplyr::mutate(parsed_address = make_parsed_address(parsed_address_components)) |>
  dplyr::mutate(hashing_address = make_parsed_address(
    parsed_address_components,
    components = c("house_number", "road", "postcode")
  ))

#### make hashdresses
cli::cli_alert_info("expanding addresses...")
d$expanded_addresses <-
  system2("/code/libpostal/src/libpostal", "--json", input = d$hashing_address, stdout = TRUE) |>
  purrr::map(jsonlite::fromJSON) |>
  purrr::map("expansions")

cli::cli_alert_info("hashing addresses...")
d <- d |>
  dplyr::mutate(hashdresses = list(purrr::map_chr(expanded_addresses, digest::digest, algo = "spookyhash")))

d_out <-
  dplyr::left_join(
    d_in,
    dplyr::select(d, input_address, parsed_address, expanded_addresses, hashdresses),
    by = c("address" = "input_address")
  ) |>
  tidyr::unnest(cols = c(expanded_addresses, hashdresses)) |>
  dplyr::rename(hashdress = hashdresses)

dht::write_geomarker_file(d_out, filename = opt$filename)
saveRDS(d, "example_postal_output.rds")

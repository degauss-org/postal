#!/usr/local/bin/Rscript

dht::greeting()

dht::check_ram(4)

doc <- "
      Usage:
      entrypoint.R <filename> [<expand>]
      "

opt <- docopt::docopt(doc)

## for interactive testing
## opt <- docopt::docopt(doc, args = "address.csv")
## opt <- docopt::docopt(doc, args = c("address.csv", "expand"))
## opt <- docopt::docopt(doc, args = c("address_stub.csv", "expand"))

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

parsed_address_components <-
  parser_output[-c(1:11)] |>
  paste(collapse = " ") |>
  strsplit("Result:", fixed = TRUE) |>
  purrr::transpose() |>
  purrr::modify(unlist) |>
  purrr::modify(jsonlite::fromJSON) |>
  purrr::modify(tibble::as_tibble, .name_repair = "unique") |>
  dplyr::bind_rows() |>
  dplyr::select(-contains("...")) |>
  dplyr::rename_with(~ paste("parsed", .x, sep = ".")) |>
  suppressMessages()

d <- dplyr::bind_cols(d, parsed_address_components)

if (!is.null(d$parsed.postcode)) {
  d$parsed.postcode_five <- substr(d$parsed.postcode, 1, 5)
}

d <- tidyr::unite(d,
                  col = "parsed_address",
                  tidyselect::any_of(paste0("parsed.", c("house_number", "road", "city", "state", "postcode_five"))),
                  sep = " ", na.rm = TRUE, remove = FALSE)

## expanding addresses
if (!is.null(opt$expand)) {
  cli::cli_alert_info("the {.field expand} argument is set to {.val {opt$expand}}; expanding the parsed addresses...")
  cli::cli_alert_warning("more than one address row will likely be returned for each input address row")

  d$expanded_addresses <-
    system2("/code/libpostal/src/libpostal", "--json", input = d$parsed_address, stdout = TRUE) |>
    purrr::map(jsonlite::fromJSON) |>
    purrr::map("expansions")

  d <- d |> tidyr::unnest(cols = c(expanded_addresses))
}

d_out <- dplyr::left_join(d_in, d, by = c("address" = "input_address"))

dht::write_geomarker_file(d_out, filename = opt$filename, argument = opt$expand)

# postal <a href='https://degauss.org'><img src='https://github.com/degauss-org/degauss_hex_logo/raw/main/PNG/degauss_hex.png' align='right' height='138.5' /></a>

[![](https://img.shields.io/github/v/release/degauss-org/postal?color=469FC2&label=version&sort=semver)](https://github.com/degauss-org/postal/releases)
[![container build status](https://github.com/degauss-org/postal/workflows/build-deploy-release/badge.svg)](https://github.com/degauss-org/postal/actions/workflows/build-deploy-release.yaml)

## Using

If `my_address_file.csv` is a file in the current working directory with an address column named `address`, then the [DeGAUSS command](https://degauss.org/using_degauss.html#DeGAUSS_Commands):

```sh
docker run --rm -v $PWD:/tmp ghcr.io/degauss-org/postal:0.1.3 my_address_file.csv
```

will produce `my_address_file_postal_0.1.3.csv` with added columns:

- **`cleaned_address`**: `address` with non-alphanumeric characterics and excess whitespace removed (with `dht::clean_address()`)
- **`parsed.{address_component}`**: multiple columns, one for each [parsed address component](https://github.com/openvenues/libpostal#parser-labels) (e.g., `parsed.road`, `parsed.state`, `parsed.house_number`)
- **`parsed_address`**: a "parsed" address created by pasting together available `parsed.house_number`, `parsed.road`, `parsed.city`, `parsed.state`, `parsed.postcode` address components

### Optional Argument

After parsing, the parsed addresses can be expanded into [several possible normalized addresses](https://github.com/openvenues/libpostal#examples-of-normalization) using `libpostal`.  This can be useful for matching of these addresses with other messy, real world addresses.

If any value is provided as an argument (e.g., "expand"), then the [DeGAUSS command](https://degauss.org/using_degauss.html#DeGAUSS_Commands):

```sh
docker run --rm -v $PWD:/tmp ghcr.io/degauss-org/postal:0.1.3 my_address_file.csv expand
```

will produce `my_address_file_postal_0.1.3_expand.csv` with the above columns *plus*:

- **`expanded_addresses`**: the expanded addresses for `parsed_address`

Because each `parsed_address` will likely result in more than one `expanded_addresses`, each input row is duplicated to accomodate several `expanded_addresses`. This means that when expanding addresses, the input CSV file is "expanded" too by duplicating the input rows.

## Geomarker Methods

Input addresses are parsed/normalized using [`libpostal`](https://github.com/openvenues/libpostal) by:

1. removing non-alphanumeric characters (except `-`) and excess whitespace (with `dht::clean_address()`)
2. [parsing addresses into components](https://github.com/openvenues/libpostal#examples-of-parsing) using `libpostal/scr/address_parser` (a machine learning model trained on OpenStreetMap and OpenAddresses)
3. (with an optional argument) expanding the parsed address into [several possible normalized addresses](https://github.com/openvenues/libpostal#examples-of-normalization)

## DeGAUSS Details

For detailed documentation on DeGAUSS, including general usage and installation, please see the [DeGAUSS homepage](https://degauss.org).

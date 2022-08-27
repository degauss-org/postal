# postal <a href='https://degauss.org'><img src='https://github.com/degauss-org/degauss_hex_logo/raw/main/PNG/degauss_hex.png' align='right' height='138.5' /></a>

[![](https://img.shields.io/github/v/release/degauss-org/postal?color=469FC2&label=version&sort=semver)](https://github.com/degauss-org/postal/releases)
[![container build status](https://github.com/degauss-org/postal/workflows/build-deploy-release/badge.svg)](https://github.com/degauss-org/postal/actions/workflows/build-deploy-release.yaml)

## Using

If `my_address_file.csv` is a file in the current working directory with an address column named `address`, then the [DeGAUSS command](https://degauss.org/using_degauss.html#DeGAUSS_Commands):

```sh
docker run --rm -v $PWD:/tmp ghcr.io/degauss-org/postal:0.1.0 my_address_file.csv
```

will produce `my_address_file_postal_0.1.0.csv` with added columns:

- **`cleaned_address`**: `address` with non-alphanumeric characterics and excess whitespace removed (with `dht::clean_address()`)
- **`parsed.{address component}`**: multiple columns, one for each [parsed address component](https://github.com/openvenues/libpostal#parser-labels) (e.g., `parsed.road`, `parsed.state`, `parsed.house_number`)
- `**parsed_address**`: a "parsed" address created by pasting together available `parsed.house_number`, `parsed.road`, `parsed.city`, `parsed.state`, `parsed.postcode` address components
- **`normalized_address`**: `address_clean` normalized using libpostal

### Optional Argument

`libpostal`

- If this DeGAUSS container takes an optional argument, describe its usage and effects here.
- Be sure to also update the example output file name with the argument value.

## Geomarker Methods

Input addresses are parsed/normalized using [`libpostal`](https://github.com/openvenues/libpostal) by:

1. removing non-alphanumeric characters (except `-`) and excess whitespace (with `dht::clean_address()`)
2. [parsing addresses into components](https://github.com/openvenues/libpostal#examples-of-parsing) using `libpostal/scr/address_parser` (a machine learning model trained on OpenStreetMap and OpenAddresses)
3. 

- Address data must be in one column called `address`.
- Other columns may be present, but it is recommended to only include `address` and an optional identifier column (e.g., `id`). Fewer columns will increase geocoding speed.

## Geomarker Data

- List how geomarker was created, ideally including any scripts within the repo used to do so or linking to an external repository
- If applicable, list where geomarker data is stored in S3 using a hyperlink like: [`s3://path/to/postal.rds`](https://geomarker.s3.us-east-2.amazonaws.com/path/to/postal.rds)

## DeGAUSS Details

For detailed documentation on DeGAUSS, including general usage and installation, please see the [DeGAUSS homepage](https://degauss.org).

FROM rocker/r-ver:4.1.3

# DeGAUSS container metadata
ENV degauss_name="postal"
ENV degauss_version="0.1.2"
ENV degauss_description="normalized and parsed addresses"
ENV degauss_argument="expand [default: '']"

# add OCI labels based on environment variables too
LABEL "org.degauss.name"="${degauss_name}"
LABEL "org.degauss.version"="${degauss_version}"
LABEL "org.degauss.description"="${degauss_description}"
LABEL "org.degauss.argument"="${degauss_argument}"

ARG DEBIAN_FRONTEND="noninteractive"
RUN apt-get update \
        && apt-get install -yqq --no-install-recommends \
        autoconf \
        automake \
        libtool \
        curl \
        pkg-config \
        git \
        make \
        && apt-get clean

RUN git clone https://github.com/openvenues/libpostal /code/libpostal
WORKDIR /code/libpostal
RUN git checkout a97717f2b9f8fba03d25442f2bd88c15e86ec81b
RUN ./bootstrap.sh
RUN mkdir -p /opt/libpostal_data
RUN ./configure --datadir=/opt/libpostal_data
RUN make -j4
RUN make install
RUN ldconfig -v
RUN pkg-config --cflags libpostal

WORKDIR /app
RUN R --quiet -e "install.packages('remotes', repos = c(CRAN = 'https://packagemanager.rstudio.com/all/__linux__/focal/latest'))"
RUN R --quiet -e "remotes::install_github('rstudio/renv@0.15.4')"
COPY renv.lock .
RUN R --quiet -e "renv::restore(repos = c(CRAN = 'https://packagemanager.rstudio.com/all/__linux__/focal/latest'))"
COPY entrypoint.R .
WORKDIR /tmp
ENTRYPOINT ["/app/entrypoint.R"]



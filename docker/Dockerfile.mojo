FROM perl:5.36.0-slim

RUN cpanm Carton \
    && mkdir -p /easy_mojo

WORKDIR /easy_mojo
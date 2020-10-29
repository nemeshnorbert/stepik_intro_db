FROM ubuntu:20.04

ARG home

LABEL description="Image for stepik Introduction to databases course" \
      maintainer="Norbert Nemesh <norbertnemesh@gmail.com>"

WORKDIR $home

# Install all the things!
RUN apt-get update && \
    # give access to sudo
    apt-get install -y sudo && \
    # notorious text editor
    apt-get install -y vim && \
    # code version control
    apt-get install -y git && \
    # MySQL database server (metapackage depending on the latest version)
    apt-get install -y mysql-server && \
    # Ensure that excessive files are deleted
    # https://github.com/tianon/docker-brew-ubuntu-core/issues/122#issuecomment-495332014
    rm -r /var/lib/apt/lists/*

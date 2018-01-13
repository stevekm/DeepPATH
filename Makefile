# makefile to build the Docker image
SHELL:=/bin/bash

none:

# build the Docker container
build:
	docker build -t stevekm/deeppath .

# enter the container
enter:
	docker run --rm -ti stevekm/deeppath /bin/bash

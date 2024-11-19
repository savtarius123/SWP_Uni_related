#!/bin/bash

podman run --rm -ti --name swp_backend -p8080:8080 -p8025:8025 -p1025:1025 swp_backend

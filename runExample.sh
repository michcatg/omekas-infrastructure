#!/bin/bash

########## new
# prod
docker compose -f compose.yml -f compose_prod.yml --env-file=.env.prod up -d
docker compose -f compose.yml -f compose_prod.yml --env-file=.env.prod down
# dev
docker compose -f compose.yml -f compose_dev.yml --env-file=.env.dev up -d
docker compose -f compose.yml -f compose_dev.yml --env-file=.env.dev down

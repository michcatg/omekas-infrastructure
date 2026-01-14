#!/bin/sh
envsubst '${DEPLOY_DOMAIN} ${FRONT_DOMAIN} ${STRAPI_DOMAIN}' < /etc/nginx/conf.d/nginx.conf.template > /etc/nginx/conf.d/nginx.conf
nginx -g 'daemon off;'
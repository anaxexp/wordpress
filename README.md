# Vanilla WordPress Docker Container Image

[![Build Status](https://travis-ci.org/anaxexp/wordpress.svg?branch=master)](https://travis-ci.org/anaxexp/wordpress)
[![Docker Pulls](https://img.shields.io/docker/pulls/anaxexp/wordpress.svg)](https://hub.docker.com/r/anaxexp/wordpress)
[![Docker Stars](https://img.shields.io/docker/stars/anaxexp/wordpress.svg)](https://hub.docker.com/r/anaxexp/wordpress)
[![Docker Layers](https://images.microbadger.com/badges/image/anaxexp/wordpress.svg)](https://microbadger.com/images/anaxexp/wordpress)

## Docker Images

❗For better reliability we release images with stability tags (`anaxexp/wordpress:4-X.X.X`) which correspond to [git tags](https://github.com/anaxexp/wordpress/releases). We strongly recommend using images only with stability tags. 

Overview:

* All images are based on Alpine Linux
* Base image: [anaxexp/wordpress-php](https://github.com/anaxexp/wordpress-php)
* [Travis CI builds](https://travis-ci.org/anaxexp/wordpress) 
* [Docker Hub](https://hub.docker.com/r/anaxexp/wordpress)

[_(Dockerfile)_]: https://github.com/anaxexp/wordpress/tree/master/4/Dockerfile

| Supported tags and respective `Dockerfile` links | WordPress | PHP |
| ------------------------------------------------ | --------- | --- |
| `4-7.2`, `4`, `latest` [_(Dockerfile)_]          | 4         | 7.2 |
| `4-7.1` [_(Dockerfile)_]                         | 4         | 7.1 |
| `4-7.0` [_(Dockerfile)_]                         | 4         | 7.0 |
| `4-5.6` [_(Dockerfile)_]                         | 4         | 5.6 |

## Environment Variables

See [anaxexp/wordpress-php](https://github.com/anaxexp/wordpress-php) for all variables.

## Orchestration Actions

See [anaxexp/wordpress-php](https://github.com/anaxexp/wordpress-php) for all actions.

## Complete WordPress Stack

See [WordPress4Docker](https://github.com/anaxexp/wordpress4docker).
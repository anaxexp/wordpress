ARG BASE_IMAGE_TAG

FROM anaxexp/wordpress-php:${BASE_IMAGE_TAG}

ARG WP_VER
ARG WP_SHA1
ARG WP_MD5

ENV WP_VER="${WP_VER}" \
    WP_SHA1="${WP_SHA1}" \
    WP_MD5="${WP_MD5}" \
    APP_NAME="WordPress 4"

USER root

RUN set -ex; \
    \
    mv /usr/local/bin/actions.mk /usr/local/bin/wordpress-php.mk; \
    mkdir -p /usr/src/wordpress/; \
	    chown -R anaxexp:anaxexp /usr/src/wordpress/; \
	    \
	    cd /tmp; \
	    wget -O wp.tar.gz "https://wordpress.org/wordpress-${WP_VER}.tar.gz"; \
	    echo "$WP_SHA1 *wp.tar.gz" | sha1sum -c -; \
	    echo "$WP_MD5 *wp.tar.gz" | md5sum -c -; \
    su-exec anaxexp tar zxf /tmp/wp.tar.gz --no-same-owner --strip-components=1 -C /usr/src/wordpress; \
    rm -rf /tmp/wp.tar.gz; \
    \
    cd /usr/src/wordpress; \
	   su-exec anaxexp mkdir -p wp-content/uploads; \
	   \
	   chown :www-data \
        wp-content/ \
        wp-content/uploads \
        wp-content/plugins \
        wp-content/themes; \
    \
	   chmod 775 \
	       wp-content/ \
	       wp-content/uploads \
	       wp-content/plugins \
	       wp-content/themes; \
	   \
	   find wp-content/plugins -type d -exec chown -R :www-data {} \; -exec chmod -R 775 {} \;; \
	   find wp-content/themes -type d -exec chown -R :www-data {} \; -exec chmod -R 775 {} \;; \
	   \
    if [[ -z "${PHP_DEV}" ]]; then \
	       echo "$(cat /etc/sudoers.d/anaxexp), /usr/local/bin/init" > /etc/sudoers.d/anaxexp; \
	   fi

# Install wp-cli, http://wp-cli.org
ENV WP_CLI_CONFIG_PATH /var/www/html/wp-cli.yml
RUN set -ex \
    && curl --retry 7 --fail -Ls -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x wp-cli.phar \
    && mv wp-cli.phar /usr/local/bin/wp \
    && wp --info --allow-root

# Copy the WordPress skeleton from this repo into the container
# This includes any themes and/or plugins we've added to the content/themes and content/plugins directories.
COPY /var/www/html /var/www/html
RUN chown -R www-data:www-data /var/www/html/*

# Install WordPress via wp-cli & move the default themes to our content dir
# Releases at https://core.svn.wordpress.org/tags/ and https://wordpress.org/news/category/releases/
ENV WORDPRESS_VERSION 4.9.8
RUN set -ex \
    && wp --allow-root core download --version=${WORDPRESS_VERSION} \
    && mv /var/www/html/wordpress/wp-content/themes/* /var/www/html/content/themes/

# Install HyperDB, https://wordpress.org/plugins/hyperdb
# Releases at https://wordpress.org/plugins/hyperdb/developers/ , though no SHA1 fingerprints are published
RUN set -ex \
    && export HYPERDB_VERSION=1.1 \
    && curl --retry 7 --fail -Ls -o /var/www/html/hyperdb.zip https://downloads.wordpress.org/plugin/hyperdb.${HYPERDB_VERSION}.zip \
    && unzip hyperdb.zip \
    && chown -R www-data:www-data /var/www/html/hyperdb \
    && mv hyperdb/db.php /var/www/html/content/. \
    && rm -rf /var/www/html/hyperdb.zip /var/www/html/hyperdb \
    && touch /var/www/html/content/db-config.php

# Install ztollman's object-cache.php or object caching to memcached
RUN set -ex \
    && curl --retry 7 --fail -Ls -o /var/www/html/content/object-cache.php https://raw.githubusercontent.com/tollmanz/wordpress-pecl-memcached-object-cache/master/object-cache.php


USER anaxexp

COPY init /docker-entrypoint-init.d/
COPY bin /usr/local/bin/
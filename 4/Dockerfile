ARG BASE_IMAGE_TAG

FROM anaxexp/wordpress-php:${BASE_IMAGE_TAG}

ARG WP_VER
ARG WP_SHA1
ARG WP_MD5

ENV WP_VER="${WP_VER}" \
    WP_SHA1="${WP_SHA1}" \
    WP_MD5="${WP_MD5}" \
    APP_NAME="WordPress 4" \
    HYPERDB_VERSION=1.1 \
    WP_CLI_CONFIG_PATH=/var/www/html/wp-cli.yml

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
       # Install WordPress via wp-cli & move the default themes to our content dir
       # Releases at https://core.svn.wordpress.org/tags/ and https://wordpress.org/news/category/releases/
       #    && wp --allow-root core download --version=${WP_VER} \
      su-exec anaxexp mkdir -p content/uploads; \
      su-exec anaxexp mkdir -p content/cache; \
      su-exec anaxexp mkdir -p content/languages; \
      su-exec anaxexp mkdir -p content/mu-plugins; \
      su-exec anaxexp mv /usr/src/wordpress/wp-content/themes/* /usr/src/wordpress/content/themes/; \
	  && curl --retry 7 --fail -Ls -o /usr/src/hyperdb.zip https://downloads.wordpress.org/plugin/hyperdb.${HYPERDB_VERSION}.zip \
      && cd /usr/src \
      && unzip hyperdb.zip \
      && chown -R www-data:www-data /usr/src/hyperdb; \
      && mv hyperdb/db.php /usr/src/wordpress/content/.; \
      && rm -rf /usr/src/hyperdb.zip /usr/src/hyperdb; \
      && touch /usr/src/wordpress/content/db-config.php; \
      && su-exec anaxexp curl --retry 7 --fail -Ls -o /usr/src/wordpress/content/object-cache.php https://raw.githubusercontent.com/tollmanz/wordpress-pecl-memcached-object-cache/master/object-cache.php; \
       \
    cd /usr/src/wordpress; \   
	   chown :www-data \
        content/ \
        content/uploads \
        content/plugins \
        content/themes; \
        content/cache; \
        content/languages; \
        content/mu-plugins; \
    \
	   chmod 775 \
	       content/ \
	       content/uploads \
	       content/plugins \
	       content/themes; \
           content/cache; \
           content/languages; \
           content/mu-plugins; \
	   \
	   find content/plugins -type d -exec chown -R :www-data {} \; -exec chmod -R 775 {} \;; \
	   find content/themes -type d -exec chown -R :www-data {} \; -exec chmod -R 775 {} \;; \
	   \
    if [[ -z "${PHP_DEV}" ]]; then \
	       echo "$(cat /etc/sudoers.d/anaxexp), /usr/local/bin/init" > /etc/sudoers.d/anaxexp; \
	   fi

# Install wp-cli, http://wp-cli.org
#ENV WP_CLI_CONFIG_PATH /var/www/html/wp-cli.yml
RUN set -ex \
    && curl --retry 7 --fail -Ls -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x wp-cli.phar \
    && mv wp-cli.phar /usr/local/bin/wp \
    && wp --info --allow-root

# Copy the WordPress skeleton from this repo into the container
# This includes any themes and/or plugins we've added to the content/themes and content/plugins directories.
COPY /usr/src/wordpress /usr/src/wordpress
RUN chown -R www-data:www-data /usr/src/wordpress/*

USER anaxexp

COPY init /docker-entrypoint-init.d/
COPY bin /usr/local/bin/
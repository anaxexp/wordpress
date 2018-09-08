ARG BASE_IMAGE_TAG

FROM anaxexp/wordpress-php:${BASE_IMAGE_TAG}

ARG WP_VER
ARG WP_SHA1
ARG WP_MD5
ARG APP_NAME
ARG WP_CLI_CONFIG_PATH
ARG HYPERDB_VERSION

ENV WP_VER="${WP_VER}" \
    WP_SHA1="${WP_SHA1}" \
    WP_MD5="${WP_MD5}" \
    APP_NAME="WordPress 4" \
    WP_CLI_CONFIG_PATH="${WP_CLI_CONFIG_PATH}" \
    HYPERDB_VERSION="${HYPERDB_VERSION}"

USER root



# Add Containerpilot and its configuration
# Releases at https://github.com/joyent/containerpilot/releases
ENV CONTAINERPILOT_VER 2.7.3
ENV CONTAINERPILOT file:///etc/containerpilot.json

RUN set -ex \
    && export CONTAINERPILOT_CHECKSUM=eed3237d11e31d6f903bca58381679f693e21dd2 \
    && curl --retry 7 --fail -Lso /tmp/containerpilot.tar.gz \
         "https://github.com/anaxexp/containerpilot/archive/${CONTAINERPILOT_VER}.tar.gz" \
    && echo "${CONTAINERPILOT_CHECKSUM}  /tmp/containerpilot.tar.gz" | sha1sum -c \
    && tar zxf /tmp/containerpilot.tar.gz -C /usr/local/bin \
    && rm /tmp/containerpilot.tar.gz

# Install Consul
# Releases at https://releases.hashicorp.com/consul
RUN set -ex \
    && export CONSUL_VERSION=0.7.5 \
    && export CONSUL_CHECKSUM=40ce7175535551882ecdff21fdd276cef6eaab96be8a8260e0599fadb6f1f5b8 \
    && curl --retry 7 --fail -vo /tmp/consul.zip "https://releases.hashicorp.com/consul/${CONSUL_VERSION}/consul_${CONSUL_VERSION}_linux_amd64.zip" \
    && echo "${CONSUL_CHECKSUM}  /tmp/consul.zip" | sha256sum -c \
    && unzip /tmp/consul -d /usr/local/bin \
    && rm /tmp/consul.zip \
    && mkdir /config

# Install Consul template
# Releases at https://releases.hashicorp.com/consul-template/
RUN set -ex \
    && export CONSUL_TEMPLATE_VERSION=0.18.3 \
    && export CONSUL_TEMPLATE_CHECKSUM=caf6018d7489d97d6cc2a1ac5f1cbd574c6db4cd61ed04b22b8db7b4bde64542 \
    && curl --retry 7 --fail -Lso /tmp/consul-template.zip "https://releases.hashicorp.com/consul-template/${CONSUL_TEMPLATE_VERSION}/consul-template_${CONSUL_TEMPLATE_VERSION}_linux_amd64.zip" \
    && echo "${CONSUL_TEMPLATE_CHECKSUM}  /tmp/consul-template.zip" | sha256sum -c \
    && unzip /tmp/consul-template.zip -d /usr/local/bin \
    && rm /tmp/consul-template.zip

# Install wp-cli, http://wp-cli.org
#ENV WP_CLI_CONFIG_PATH /usr/src/wordpress/wp-cli.yml
RUN set -ex \
    && curl --retry 7 --fail -Ls -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x wp-cli.phar \
    && mv wp-cli.phar /usr/local/bin/wp \
    && wp --info --allow-root

# Copy the WordPress skeleton from this repo into the container
# This includes any themes and/or plugins we've added to the content/themes and content/plugins directories.
RUN set -ex; \
    mv /usr/local/bin/actions.mk /usr/local/bin/wordpress-php.mk; \
    mkdir -p /usr/src/wordpress/; \
    \
      chown -R anaxexp:anaxexp /usr/src/wordpress/; \
    \  
	    cd /tmp; \
	    wget -O wp.tar.gz "https://wordpress.org/wordpress-${WP_VER}.tar.gz"; \
	    echo "$WP_SHA1 *wp.tar.gz" | sha1sum -c -; \
	    echo "$WP_MD5 *wp.tar.gz" | md5sum -c -; \
    su-exec anaxexp tar zxf /tmp/wp.tar.gz --no-same-owner --strip-components=1 -C /usr/src/wordpress; \
    rm -rf /tmp/wp.tar.gz; \
      #su-exec anaxexp mkdir -p web; \
      su-exec anaxexp mkdir -p /home/anaxexp/.composer; \
      su-exec anaxexp mkdir -p wp; \
      su-exec anaxexp mkdir -p content/uploads; \
     
      #su-exec anaxexp mkdir -p content/cache; \
      #su-exec anaxexp mkdir -p content/languages; \
      su-exec anaxexp mkdir -p content/plugins; \
      #su-exec anaxexp mkdir -p content/mu-plugins; \
      su-exec anaxexp mkdir -p content/themes; \
      #su-exec anaxexp cp -R /usr/src/wordpress/wp-content/themes/* /usr/src/wordpress/content/themes/; \
      \   
	   chown :www-data \
        /home/anaxexp/.composer \
        wp \
        content/ \
        content/uploads \
        content/plugins \
        content/themes; \
        #content/cache; \
        #content/languages; \
        #content/mu-plugins; \
    \
	   chmod 775 \
           /home/anaxexp/.composer \
           wp \
	       content/ \
	       content/uploads \
	       content/plugins \
	       content/themes; \
           #content/cache; \
           #content/languages; \
           #content/mu-plugins; \
	   \
	   find content/plugins -type d -exec chown -R :www-data {} \; -exec chmod -R 775 {} \;; \
	   find content/themes -type d -exec chown -R :www-data {} \; -exec chmod -R 775 {} \;; \
	   \
    \
    #  cd /usr/src/wordpress/; \
    #  su-exec anaxexp composer install; \
    \   
    if [[ -z "${PHP_DEV}" ]]; then \
	       echo "$(cat /etc/sudoers.d/anaxexp), /usr/local/bin/init" > /etc/sudoers.d/anaxexp; \
	   fi

COPY www /var/www
#
RUN chown -R anaxexp:www-data /var/www/; \
    su-exec anaxexp composer install -d /var/www;
# Install HyperDB, https://wordpress.org/plugins/hyperdb
# Releases at https://wordpress.org/plugins/hyperdb/developers/ , though no SHA1 fingerprints are published
#ENV HYPERDB_VERSION=1.1
RUN set -ex \
    #&& curl --retry 7 --fail -Ls -o /usr/src/hyperdb.zip https://downloads.wordpress.org/plugin/hyperdb.${HYPERDB_VERSION}.zip \
    && curl --retry 7 --fail -Ls -O https://downloads.wordpress.org/plugin/hyperdb.${HYPERDB_VERSION}.zip \
    #&& cd /usr/src \
    && unzip hyperdb.${HYPERDB_VERSION}.zip \
    && chown -R anaxexp:www-data hyperdb \
    && mv hyperdb/db.php content/. \
    && rm -rf hyperdb.${HYPERDB_VERSION}.zip hyperdb \
    && touch content/db-config.php

# Install ztollman's object-cache.php or object caching to memcached
RUN set -ex \
    && su-exec anaxexp curl --retry 7 --fail -Ls -o content/object-cache.php https://raw.githubusercontent.com/tollmanz/wordpress-pecl-memcached-object-cache/master/object-cache.php



USER anaxexp

COPY init /docker-entrypoint-init.d/
COPY bin /usr/local/bin/

# The volume is defined after we install everything
VOLUME /var/www
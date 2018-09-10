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
    mkdir -p /usr/src/wordpress/html/wp/; \
    mkdir -p /home/anaxexp/.composer/;

COPY www /usr/src/wordpress

RUN set -ex; \ 
        chown -R anaxexp:anaxexp /usr/src/wordpress/; \
        chown -R anaxexp:anaxexp /home/anaxexp/.composer; \
	    cd /tmp; \
	    wget -O wp.tar.gz "https://wordpress.org/wordpress-${WP_VER}.tar.gz"; \
	    echo "$WP_SHA1 *wp.tar.gz" | sha1sum -c -; \
	    echo "$WP_MD5 *wp.tar.gz" | md5sum -c -; \
    su-exec anaxexp tar zxf /tmp/wp.tar.gz --no-same-owner --strip-components=1 -C /usr/src/wordpress/html/wp; \
    rm -rf /tmp/wp.tar.gz; \
    \
    cd /usr/src/wordpress; \
    #\
    #su-exec anaxexp mv /usr/src/wordpress/html/wp/wp-content/themes/* /usr/src/wordpress/html/content/themes/; \
    #su-exec anaxexp mkdir -p web; \
    \  
      #su-exec anaxexp mkdir -p backup; \
      #/usr/src/wordpress mkdir -p /var/www/bin; \
      #mkdir -p /usr/src/wordpress/scripts; \
      su-exec anaxexp mkdir -p vendor; \
      #mkdir -p /var/www/html/wp; \
      #chown -R anaxexp:anaxexp /var/www/html/wp; \
      #chown -R anaxexp:www-data /var/www/backup; \
      #chown -R anaxexp:www-data /var/www/bin; \
      #chown -R anaxexp:www-data /var/www/conf; \
      #chown -R anaxexp:www-data /var/www/scripts; \
      #su-exec anaxexp mkdir -p wp; \
      su-exec anaxexp mkdir -p html/content/uploads; \
      su-exec anaxexp mkdir -p html/content/cache; \
      su-exec anaxexp mkdir -p html/content/languages; \
      su-exec anaxexp mkdir -p html/content/plugins; \
      su-exec anaxexp mkdir -p html/content/mu-plugins; \
      su-exec anaxexp mkdir -p html/content/themes; \
      \
	   chown :www-data \
        #wp \
        html/ \
        html/content \
        html/content/uploads \
        html/content/plugins \
        html/content/themes \
        html/content/cache \
        html/content/languages \
        html/content/mu-plugins; \
        #vendor; \
    \
	   chmod 775 \
           #wp \
	       html/content/ \
	       html/content/uploads \
	       html/content/plugins \
	       html/content/themes \
           html/content/cache \
           html/content/languages \
           html/content/mu-plugins; \
           #vendor; \
	   \
	   find html/content/plugins -type d -exec chown -R :www-data {} \; -exec chmod -R 775 {} \;; \
	   find html/content/themes -type d -exec chown -R :www-data {} \; -exec chmod -R 775 {} \;; \
       find html/content/mu-plugins -type d -exec chown -R :www-data {} \; -exec chmod -R 775 {} \;; \
       #find vendor -type d -exec chown -R :www-data {} \; -exec chmod -R 775 {} \;; \
	   \
       # Install HyperDB, https://wordpress.org/plugins/hyperdb
       # Releases at https://wordpress.org/plugins/hyperdb/developers/ , though no SHA1 fingerprints are published
       #ENV HYPERDB_VERSION=1.1
       export HYPERDB_VERSION=1.1; \
       curl --retry 7 --fail -Ls -o hyperdb.zip https://downloads.wordpress.org/plugin/hyperdb.${HYPERDB_VERSION}.zip; \
       unzip hyperdb.zip; \
       chown -R anaxexp:www-data hyperdb; \
       mv hyperdb/db.php /usr/src/wordpress/html/content/.; \
       rm -rf hyperdb.zip hyperdb; \
       touch /usr/src/wordpress/html/content/db-config.php; \
       \
       # Install ztollman's object-cache.php or object caching to memcached
       curl --retry 7 --fail -Ls -o /usr/src/wordpress/html/content/object-cache.php https://raw.githubusercontent.com/tollmanz/wordpress-pecl-memcached-object-cache/master/object-cache.php; \
       \
    \  
    su-exec anaxexp composer install -d /usr/src/wordpress; \
    \
    if [[ -z "${PHP_DEV}" ]]; then \
	       echo "$(cat /etc/sudoers.d/anaxexp), /usr/local/bin/init" > /etc/sudoers.d/anaxexp; \
	   fi



USER anaxexp

COPY init /docker-entrypoint-init.d/
COPY bin /usr/local/bin/

#RUN su-exec anaxexp composer install -d /usr/src/wordpress;
# The volume is defined after we install everything
#VOLUME /var/www/html
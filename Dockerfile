FROM debian:jessie

LABEL maintainer="Jason Raimondi <jason@raimondi.us>"

WORKDIR /usr/local/src

ENV PHP_VERSION=7.1.7
ENV PHP_URL="https://secure.php.net/get/php-$PHP_VERSION.tar.gz/from/this/mirror" \
    PHP_MD5="cf99ac30e8f989612ed6431d16ff8a76" \
    PHP_CFLAGS="-fstack-protector-strong -fpic -fpie -O2" \
    PHP_CPPFLAGS="$PHP_CFLAGS" \
    PHP_LDFLAGS="-Wl,-O1 -Wl,--hash-style=both -pie" \
    PHP_EXTRA_CONFIGURE_ARGS="--enable-fpm --with-fpm-user=www-data --with-fpm-group=www-data" \
    PHP_INI_DIR="/usr/local/etc/php"  \
    BUILD_DEPENDENCIES="\
        wget \
        \
        autoconf \
		dpkg-dev \
		file \
		g++ \
		gcc \
		libc-dev \
		libpcre3-dev \
		make \
		pkg-config \
		re2c \
		\
		ca-certificates \
        curl \
        libedit2 \
        libsqlite3-0 \
        libxml2 \
        xz-utils \
        \
        libfcgi-dev \
        libfcgi0ldbl \
        libjpeg62-turbo-dbg \
        libmcrypt-dev \
        libssl-dev \
        libc-client2007e \
        libc-client2007e-dev \
        libxml2-dev \
        libbz2-dev \
        libcurl4-openssl-dev \
        libjpeg-dev \
        libpng12-dev \
        libfreetype6-dev \
        libkrb5-dev \
        libpq-dev \
        libxml2-dev \
        libxslt1-dev \
        libedit-dev"

RUN apt-get update \
    && apt-get install -y --no-install-recommends $BUILD_DEPENDENCIES \
    \
    && wget -q $PHP_URL -O php.tgz \
    && set -xe; \
    \
    if [ -n "$PHP_MD5" ]; then \
        echo "$PHP_MD5 *php.tgz" | md5sum -c -; \
    fi; \
    \
    export CFLAGS="$PHP_CFLAGS" \
        CPPFLAGS="$PHP_CPPFLAGS" \
        LDFLAGS="$PHP_LDFLAGS" \
    && mkdir -p $PHP_INI_DIR/conf.d \
    && mkdir -p /usr/local/src/php \
    && tar zxf php.tgz -C /usr/local/src/php --strip-components=1 \
    && ( \
        cd /usr/local/src/php \
        && ./configure \
            --with-config-file-path="$PHP_INI_DIR" \
            --with-config-file-scan-dir="$PHP_INI_DIR/conf.d" \
            --disable-cgi \
            --disable-rpath \
            --enable-mbstring \
            --enable-mysqlnd \
            --enable-zip \
            --enable-exif \
            --with-curl \
            --with-gettext \
            --with-libedit \
            --with-openssl \
            --with-zlib \
            --with-gd \
            --with-jpeg-dir \
            --with-pdo-mysql=mysqlnd \
            --with-png-dir \
            --with-freetype-dir \
            $PHP_EXTRA_CONFIGURE_ARGS \
        && make -j "$(nproc)" \
        && make install \
        && { find /usr/local/bin /usr/local/sbin -type f -executable -exec strip --strip-all '{}' + || true; } \
        && make clean \
    ) \
    && rm /usr/local/src/php.tgz \
    && rm -rf /usr/local/src/php \
    \
    && apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false $BUILD_DEPENDENCIES \
    && apt-get clean \
# https://github.com/docker-library/php/issues/443
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    && rm -rf /var/www/html \
    \
    && mkdir -p /var/log/php-fpm \
    && chown www-data.www-data /var/log/php-fpm

COPY ./php-fpm.conf /usr/local/etc/php-fpm.conf
COPY ./php-fpm.d/ /usr/local/etc/php-fpm.d

EXPOSE 9000

USER www-data

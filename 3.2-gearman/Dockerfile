FROM digitalcanvasdesign/php-fpm-gearman:latest

LABEL maintainer="Jason Raimondi <jason@raimondi.us>"

WORKDIR /usr/local/src

ENV PHALCON_VERSION="v3.2.2"

ENV PHALCON_URL="https://github.com/phalcon/cphalcon/archive/$PHALCON_VERSION.tar.gz" \
    RE2C_URL="https://github.com/skvadrik/re2c/releases/download/0.16/re2c-0.16.tar.gz" \
    BUILD_DEPENDENCIES="\
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
        libsqlite3-0 \
        xz-utils \
        wget \
        git"

USER root

RUN apt-get update \
    && apt-get install -y --no-install-recommends $BUILD_DEPENDENCIES \

    \
    && wget -q $RE2C_URL -O re2c.tgz \
    && mkdir /usr/local/src/re2c \
    && tar zxf re2c.tgz -C /usr/local/src/re2c --strip-components=1 \
    && ( \
        cd /usr/local/src/re2c \
        && ./configure \
        && make \
        && make install \
    ) \
    && rm re2c.tgz \
    && wget -q $PHALCON_URL -O phalcon.tgz \
    && mkdir /usr/local/src/phalcon \
    && tar zxf phalcon.tgz -C /usr/local/src/phalcon --strip-components=1 \
    && ( \
        cd /usr/local/src/phalcon/build \
        && ./install \
    ) \
    && rm phalcon.tgz \
    && apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false $BUILD_DEPENDENCIES \
    && apt-get clean

COPY ./phalcon.ini /usr/local/etc/php/conf.d/phalcon.ini

EXPOSE 9000

CMD ["php-fpm"]

USER www-data

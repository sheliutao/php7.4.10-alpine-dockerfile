FROM php:7.4.10-zts-alpine3.12

LABEL maintainer="sheletao <sheletao@sina.cn>" version="2.0"

# --build-arg timezone=Asia/Shanghai
ARG timezone
# app env: prod pre test dev
ARG app_env=test
# default use www-data user
ARG work_user=www-data

# default APP_ENV = test
ENV APP_ENV=${app_env:-"test"} \
    TIMEZONE=${timezone:-"Asia/Shanghai"} \
    PHPREDIS_VERSION=5.3.1 \
    SWOOLE_VERSION=4.5.5 \
    UUID_VERSION=1.1.0 \
    IGBINARY_VERSION=3.1.5 \
    COMPOSER_ALLOW_SUPERUSER=1

# Libs -y --no-install-recommends
RUN set -ex \
    && sed -i 's/dl-cdn.alpinelinux.org/mirrors.tuna.tsinghua.edu.cn/g' /etc/apk/repositories \
    && apk update \
    && apk add --no-cache \
     curl wget zip unzip less procps lsof tcpdump gcc g++ pkgconf util-linux make libpng \
     openssl net-tools icu icu-dev zlib zlib-dev libpng-dev libuuid util-linux-dev \
     postgresql postgresql-dev oniguruma oniguruma-dev libzip libzip-dev m4 autoconf \
    && echo "#!/bin/sh" > /usr/local/bin/ll \
    && echo "ls -l \$*" >> /usr/local/bin/ll \
    && chmod +x -R /usr/local/bin \
# Install PHP extensions
    && docker-php-ext-install \
       bcmath gd mysqli pdo_pgsql pgsql pdo_mysql mbstring sockets zip sysvmsg sysvsem sysvshm \
# Install composer
    && curl -sS https://getcomposer.org/installer | php \
    && mv composer.phar /usr/local/bin/composer \
    && composer self-update --clean-backups \
# Install igbinary extension
    && wget https://pecl.php.net/get/igbinary-${IGBINARY_VERSION}.tgz -O igbinary.tgz \
    && mkdir -p igbinary \
    && tar -xf igbinary.tgz -C igbinary --strip-components=1 \
    && rm igbinary.tgz \
    && ( \
        cd igbinary \
        && phpize \
        && ./configure \
        && make -j$(nproc) \
        && make install \
        ) \
    && rm -r igbinary \
    && docker-php-ext-enable igbinary \
# Install redis extension
    && wget http://pecl.php.net/get/redis-${PHPREDIS_VERSION}.tgz -O redis.tgz \
    && mkdir -p redis \
    && tar -xf redis.tgz -C redis --strip-components=1 \
    && rm redis.tgz \
    && ( \
        cd redis \
        && phpize \
        && ./configure \
        && make -j$(nproc) \
        && make install \
        ) \
    && rm -r redis \
    && docker-php-ext-enable redis \
# Install uuid extension
    && wget https://pecl.php.net/get/uuid-${UUID_VERSION}.tgz -O uuid.tgz \
    && mkdir -p uuid \
    && tar -xf uuid.tgz -C uuid --strip-components=1 \
    && rm uuid.tgz \
    && ( \
        cd uuid \
        && phpize \
        && ./configure \
        && make -j$(nproc) \
        && make install \
        ) \
    && rm -r uuid \
    && docker-php-ext-enable uuid \
# Install swoole extension
    && wget https://github.com/swoole/swoole-src/archive/v${SWOOLE_VERSION}.tar.gz -O swoole.tar.gz \
    && mkdir -p swoole \
    && tar -xf swoole.tar.gz -C swoole --strip-components=1 \
    && rm swoole.tar.gz \
    && ( \
        cd swoole \
        && phpize \
        && ./configure --enable-mysqlnd --enable-sockets --enable-openssl --enable-http2 \
        && make -j$(nproc) \
        && make install \
    ) \
    && rm -r swoole \
    && docker-php-ext-enable swoole \
# Timezone
    && ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && echo "${TIMEZONE}" > /etc/timezone \
    && echo "[Date]\ndate.timezone=${TIMEZONE}" > /usr/local/etc/php/conf.d/timezone.ini \
# Clear dev deps
    && apk del \
       wget zip unzip less procps lsof tcpdump gcc g++ \
       net-tools icu zlib libpng make libuuid vim pkgconf \
       postgresql oniguruma libzip m4 autoconf util-linux \
    && rm -rf /var/cache/apk/* /tmp/* /usr/share/man \
    && echo -e "\033[42;37m Build Completed :).\033[0m\n"



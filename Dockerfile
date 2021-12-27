#FROM 命令
#ベースイメージを指定
FROM php:8.1-fpm-buster

#SHELL 命令
#デフォルトのシェルコマンドを指定
SHELL ["/bin/bash", "-oeux", "pipefail", "-c"]


# timezone 環境
ENV TZ=UTC \
    # locale
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8 \
    # composer 環境
    COMPOSER_ALLOW_SUPERUSER=1 \
    COMPOSER_HOME=/composer

#デフォルトをcomposer2系で
COPY --from=composer:2.0 /usr/bin/composer /usr/bin/composer

#Laravelの実行に必要なライブラリのインストール
#OSの言語設定
#PHP拡張ライブラリのインストールをやっているそう
RUN apt-get update && \
    apt-get -y install git libicu-dev libonig-dev libzip-dev unzip locales && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    locale-gen en_US.UTF-8 && \
    localedef -f UTF-8 -i en_US en_US.UTF-8 && \
    mkdir /var/run/php-fpm && \
    docker-php-ext-install intl pdo_mysql zip bcmath && \
    composer config -g process-timeout 3600 && \
    composer config -g repos.packagist composer https://packagist.org

# node command
COPY --from=node /usr/local/bin /usr/local/bin
# npm command
COPY --from=node /usr/local/lib /usr/local/lib
# yarn command
COPY --from=node /opt /opt
# nginx config file
COPY ./docker/nginx/*.conf /etc/nginx/conf.d/


COPY ./docker/php/php.ini /usr/local/etc/php/php.ini


WORKDIR /work

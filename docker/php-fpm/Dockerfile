FROM php:7.3-fpm-alpine

RUN apk --no-cache --update add tzdata
RUN apk --no-cache --update add php7-bcmath libxml2-dev libzip-dev
RUN docker-php-ext-install bcmath ctype json mbstring pdo_mysql mysqli tokenizer xml zip
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer
ENV COMPOSER_ALLOW_SUPERUSER 1
RUN mkdir -p /var/log/fpm \
    && ln -fns /dev/stdout /var/log/fpm/access.log \
    && ln -fns /dev/stderr /var/log/fpm/access.log
CMD [ "php-fpm", "-F", "-O" ]

COPY ./docker/php-fpm/php.ini   /usr/local/php/php.ini
COPY ./docker/php-fpm/php-fpm.d /usr/local/etc/php-fpm.d
COPY ./src                      /var/www/html

FROM php:8.2-fpm-buster
# php:8.1-fpm-buster
RUN docker-php-ext-install bcmath pdo_mysql

RUN apt-get update
RUN apt-get install -y git zip unzip vim

# install imagick
RUN apt-get install -y libmagickwand-dev --no-install-recommends \
    && pecl install imagick \
   && docker-php-ext-enable imagick

# node & npm
RUN apt-get install curl -y
RUN curl -sL https://deb.nodesource.com/setup_18.x | bash -
RUN apt-get install -y nodejs

COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# RUN composer install --no-interaction --optimize-autoloader --no-dev

# Configure LDAP.
RUN apt-get update \
 && apt-get install libldap2-dev -y \
 && rm -rf /var/lib/apt/lists/* \
 && docker-php-ext-configure ldap --with-libdir=lib/x86_64-linux-gnu/ \
 && docker-php-ext-install ldap

# php mongodb ext
RUN pecl install mongodb \
 &&  echo "extension=mongodb.so" > $PHP_INI_DIR/conf.d/mongo.ini

# php gd ext
ADD https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/
RUN chmod +x /usr/local/bin/install-php-extensions && sync && \
 install-php-extensions gd xdebug

# Solve Permission Denied error
RUN addgroup --gid 1000 laravel
RUN adduser --ingroup laravel --shell /bin/sh laravel
USER laravel

# RUN echo 'memory_limit = 2048M' >> /usr/local/etc/php/conf.d/docker-php-memlimit.ini;

EXPOSE 9000

# increase memory limit
# RUN sed -i 's/memory_limit = .*/memory_limit = 1024/' $PHP_INI_DIR/php.ini-development
# RUN sed -i 's/memory_limit = .*/memory_limit = 1024/' $PHP_INI_DIR/php.ini-production
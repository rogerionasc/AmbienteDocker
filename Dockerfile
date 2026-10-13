FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC

RUN apt-get update && \
    apt-get install -y tzdata software-properties-common curl git unzip && \
    add-apt-repository -y ppa:ondrej/php && \
    curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && \
    apt-get update && \
    apt-get install -y \
        apache2 \
        libapache2-mod-php8.1 \
        php8.1 \
        php8.1-cli \
        php8.1-common \
        php8.1-pgsql \
        php8.1-xml \
        php8.1-mbstring \
        php8.1-curl \
        php8.1-zip \
        php8.1-bcmath \
        php8.1-xdebug \
        nodejs && \
    phpdismod xdebug && \
    a2enmod rewrite && \
    php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" && \
    php composer-setup.php && \
    php -r "unlink('composer-setup.php');" && \
    mv composer.phar /usr/local/bin/composer && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

COPY ./000-default.conf /etc/apache2/sites-available/000-default.conf

WORKDIR /var/www/html/appWeb

COPY ./appWeb /var/www/html/appWeb/

EXPOSE 80 5432

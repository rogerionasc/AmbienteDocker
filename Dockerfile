# Imagem oficial do PHP 8.1 com Apache (Debian Slim oficial)
FROM php:8.1-apache

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC

# 1. Dependências do sistema e bibliotecas para extensões do PHP
RUN apt-get update && apt-get install -y --no-install-recommends \
    libpq-dev \
    libzip-dev \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libicu-dev \
    libxml2-dev \
    zip \
    unzip \
    git \
    curl \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) \
        pdo \
        pdo_pgsql \
        pgsql \
        bcmath \
        zip \
        gd \
        intl \
        opcache \
    && a2enmod rewrite \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# 2. Node.js 18 para compilação de assets do Vite / frontend
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - \
    && apt-get install -y --no-install-recommends nodejs \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# 3. Composer oficial
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# 4. Configuração do VirtualHost do Apache
COPY ./000-default.conf /etc/apache2/sites-available/000-default.conf

# 5. Otimizações de configuração do PHP e OPcache para Laravel
RUN { \
    echo 'opcache.enable=1'; \
    echo 'opcache.memory_consumption=128'; \
    echo 'opcache.interned_strings_buffer=8'; \
    echo 'opcache.max_accelerated_files=10000'; \
    echo 'opcache.revalidate_freq=2'; \
    echo 'opcache.save_comments=1'; \
} > /usr/local/etc/php/conf.d/opcache-recommended.ini

WORKDIR /var/www/html/appWeb

EXPOSE 80

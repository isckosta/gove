# Base image
FROM ubuntu:latest

# Definir variável de ambiente para evitar a seleção da área geográfica
ENV DEBIAN_FRONTEND=noninteractive

# Instalação de dependências do sistema
RUN apt-get update && apt-get install -y \
    software-properties-common \
    nano \
    cron \
    xclip \
    curl \
    git \
    unzip \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    libzip-dev \
    zip \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Instalação do Node.js 18
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash -

# Instalação do NPM, Yarn e o Supervisor
RUN apt-get update && apt-get install -y \
    nodejs \
    yarn \
    supervisor \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Instalação do PHP e extensões
RUN add-apt-repository ppa:ondrej/php
RUN apt-get update && apt-get install -y \
    php8.2 \
    php8.2-cli \
    php8.2-fpm \
    php8.2-mysql \
    php8.2-pgsql \
    php8.2-sqlite3 \
    php8.2-mbstring \
    php8.2-xml \
    php8.2-curl \
    php8.2-zip \
    php8.2-gd \
    php8.2-redis \
    php8.2-bcmath \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Instalação do Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Instalação do Apache
RUN apt-get update && apt-get install -y apache2
RUN apt-get install libapache2-mod-php8.2
RUN a2enmod rewrite

# Configuração do PHP
RUN echo "date.timezone = UTC" >> /etc/php/8.2/cli/php.ini
RUN echo "date.timezone = UTC" >> /etc/php/8.2/fpm/php.ini

# Criação do diretório de trabalho e cópia dos arquivos do Laravel
WORKDIR /var/www/html
COPY . .

# Instalação das dependências do Laravel
# RUN composer install

# Configuração de permissões
RUN chown -R www-data:www-data \
    /var/www/html/storage \
    /var/www/html/bootstrap/cache

# Configuração do Apache
COPY docker/apache/sites-available/000-default.conf /etc/apache2/sites-available/000-default.conf
COPY docker/apache/conf-available/custom-apache2.conf /etc/apache2/conf-available/custom-apache2.conf

# Habilita o arquivo de configuração do Apache
RUN a2enconf custom-apache2

# Definição do diretório de trabalho
WORKDIR /var/www/html

# Exposição da porta do servidor
EXPOSE 80

# Comando de execução do Apache
CMD apachectl -D FOREGROUND

FROM debian:stable-slim
ARG PHP_VERSION=5.6
ARG PHP_FULL_VERSION=5.6.20

LABEL org.opencontainers.image.title="PHP with FPM on Debian"
LABEL org.opencontainers.image.description="PHP with FPM on Debian"
LABEL org.opencontainers.image.author="Jery Thomas <me@jerrythomas.name>"
LABEL org.opencontainers.image.source="https://github.com/jerrythomas/docker-php-fpm"
LABEL org.opencontainers.image.license="MIT"
LABEL repository="https://github.com/jerrythomas/docker-php-fpm"
LABEL maintainer="jerrythomas"

ENV NVM_DIR /root/.nvm

# Install dependencies
RUN apt-get update \
 && apt-get install -y \
    curl \
    wget \
    apt-transport-https \
    lsb-release \
    ca-certificates \
	build-essential \
	g++ git zip zlib1g-dev bzip2 \
    libxml2-dev libssl-dev libpng-dev libjpeg-dev libgif-dev libxslt-dev

# Add the PHP repository
RUN wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg
RUN echo "deb https://packages.sury.org/php/ bullseye main" > /etc/apt/sources.list.d/php.list

# Install NVM
RUN curl https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh | bash

RUN mkdir -p /usr/local/bin \
    && mkdir -p /usr/src/php \
    && mkdir -p /run/php \
    && mkdir -p /usr/local/etc/php/conf.d/
COPY ./utils/* /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-php* \
    && echo "export PATH=$PATH:/usr/local/bin" >> /etc/profile \
    && echo "export PATH=$PATH:/root/.nvm" >> /etc/profile \
    && echo ". nvm.sh" >> /etc/profile

# Install PHP and PHP-FPM
RUN apt-get update \
 && apt-get install -y \
    php${PHP_VERSION}-fpm \
    php${PHP_VERSION}-cli \
    php${PHP_VERSION}-common \
    php${PHP_VERSION}-curl \
    php${PHP_VERSION}-mbstring \
    php${PHP_VERSION}-mysql \
    php${PHP_VERSION}-xml \
    php${PHP_VERSION}-dev \
    php${PHP_VERSION}-stomp \
    php${PHP_VERSION}-imagick \
    php${PHP_VERSION}-memcache \
    php${PHP_VERSION}-bcmath \
    php${PHP_VERSION}-zip
# Download PHP source code
RUN curl -SL "https://www.php.net/distributions/php-${PHP_FULL_VERSION}.tar.xz" -o php.tar.xz \
    && tar -xof php.tar.xz -C /usr/src/php --strip-components=1 \
    && rm php.tar.xz

# Configure PHP-FPM
ENV PHP_VERSION ${PHP_VERSION}
RUN sed -i 's/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g' /etc/php/${PHP_VERSION}/fpm/php.ini \
   && sed -i 's/;daemonize = yes/daemonize = no/g' /etc/php/${PHP_VERSION}/fpm/php-fpm.conf \
   && ln -s /usr/sbin/php-fpm${PHP_VERSION} /usr/sbin/php-fpm

# Expose the port php-fpm is reachable on
EXPOSE 9000
# Start php-fpm server
CMD ["/usr/sbin/php-fpm", "-O"]

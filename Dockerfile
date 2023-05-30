FROM debian:stable-slim
ARG PHP_VERSION=5.6.20
# Extract major.minor version from full version
RUN PHP_MM_VERSION=$(echo "${PHP_VERSION}" | cut -d. -f1-2)

LABEL org.opencontainers.image.title="PHP with FPM on Debian"
LABEL org.opencontainers.image.description="PHP with FPM on Debian"
LABEL org.opencontainers.image.author="Jery Thomas <me@jerrythomas.name>"
LABEL org.opencontainers.image.source="https://github.com/jerrythomas/docker-php-fpm"
LABEL org.opencontainers.image.license="MIT"
LABEL repository="https://github.com/jerrythomas/docker-php-fpm"
LABEL maintainer="jerrythomas"
# Install dependencies
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    apt-transport-https \
    lsb-release \
    ca-certificates \
		build-essential \
		g++ git zip zlib1g-dev bzip2 \
    libxml2-dev libssl-dev libpng-dev libjpeg-dev libgif-dev libxslt-dev

RUN mkdir -p /usr/local/bin \
    && mkdir -p /usr/src/php \
    && mkdir -p /usr/local/etc/php/conf.d/ \
COPY ./utils/* /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-php* \
    && echo "export PATH=$PATH:/usr/local/bin" >> /etc/profile
# Add the PHP repository
RUN wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg
RUN echo "deb https://packages.sury.org/php/ bullseye main" > /etc/apt/sources.list.d/php.list

# Install PHP and PHP-FPM
RUN apt-get update && apt-get install -y \
    php${PHP_MM_VERSION}-fpm \
    php${PHP_MM_VERSION}-cli \
    php${PHP_MM_VERSION}-common \
    php${PHP_MM_VERSION}-curl \
    php${PHP_MM_VERSION}-mbstring \
    php${PHP_MM_VERSION}-mysql \
    php${PHP_MM_VERSION}-xml \
    php${PHP_MM_VERSION}-dev

# Download PHP source code
RUN curl -SL "https://www.php.net/distributions/php-${PHP_VERSION}.tar.xz" -o php.tar.xz \
    && tar -xof php.tar.xz -C /usr/src/php --strip-components=1 \
    && rm php.tar.xz

# Configure PHP-FPM
RUN sed -i 's/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g' /etc/php/${PHP_MM_VERSION}/fpm/php.ini
RUN sed -i 's/;daemonize = yes/daemonize = no/g' /etc/php/${PHP_MM_VERSION}/fpm/php-fpm.conf

# Expose the port php-fpm is reachable on
EXPOSE 9000

# Start php-fpm server
CMD ["/usr/sbin/php-fpm${PHP_MM_VERSION}", "-O"]

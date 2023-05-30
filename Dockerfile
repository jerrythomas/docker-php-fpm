FROM debian:stable-slim

LABEL org.opencontainers.image.title="PHP 5.6.20 with FPM on Debian 11"
LABEL org.opencontainers.image.description="PHP 5.6.20 with FPM on Debian 11"
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

# Add the PHP repository
RUN wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg
RUN echo "deb https://packages.sury.org/php/ bullseye main" > /etc/apt/sources.list.d/php.list

# Install PHP and PHP-FPM
RUN apt-get update && apt-get install -y \
    php5.6-fpm \
    php5.6-cli \
    php5.6-common \
    php5.6-curl \
    php5.6-mbstring \
    php5.6-mysql \
    php5.6-xml

# Configure PHP-FPM
RUN sed -i 's/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g' /etc/php/5.6/fpm/php.ini
RUN sed -i 's/;daemonize = yes/daemonize = no/g' /etc/php/5.6/fpm/php-fpm.conf

# Expose the port php-fpm is reachable on
EXPOSE 9000

# Start php-fpm server
CMD ["/usr/sbin/php-fpm5.6", "-O"]

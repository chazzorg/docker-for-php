FROM hyperf/hyperf:7.4-alpine-v3.11-swoole
LABEL maintainer="Hyperf Developers <group@hyperf.io>" version="1.0" license="MIT"

##
# ---------- env settings ----------
##
# --build-arg timezone=Asia/Shanghai
ARG timezone
ARG APP_CODE_PATH_CONTAINER

ENV TIMEZONE=${timezone:-"Asia/Shanghai"} \
    COMPOSER_VERSION=1.8.6 

# update
RUN set -ex \
    && apk update \
    # install composer
    && wget -nv -O /usr/local/bin/composer https://github.com/composer/composer/releases/download/${COMPOSER_VERSION}/composer.phar \
    && chmod u+x /usr/local/bin/composer \
    # show php version and extensions
    && php -v \
    && php -m \
    #  ---------- some config ----------
    && cd /etc/php7 \
    # - config PHP
    && { \
        echo "upload_max_filesize=100M"; \
        echo "post_max_size=108M"; \
        echo "memory_limit=1024M"; \
        echo "date.timezone=${TIMEZONE}"; \
    } | tee conf.d/99-overrides.ini \
    # - config timezone
    && ln -sf /usr/share/zoneinfo/${TIMEZONE} /etc/localtime \
    && echo "${TIMEZONE}" > /etc/timezone \
    # ---------- clear works ----------
    && rm -rf /var/cache/apk/* /tmp/* /usr/share/man \
    && echo -e "\033[42;37m Build Completed :).\033[0m\n" \
    && mkdir -p ${APP_CODE_PATH_CONTAINER}

ADD ./startup.sh /opt/startup.sh
ADD ./wait.php /opt/wait.php

WORKDIR ${APP_CODE_PATH_CONTAINER}

CMD ["/bin/bash", "/opt/startup.sh"]
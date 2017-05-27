FROM rasputinlabs/server-full:0.3
MAINTAINER David Ramsington <grokbot.dwr@gmail.com>

# Set some Environment variables
ENV DEBIAN_FRONTEND noninteractive
ENV APP_HOST blackmail.local
ENV DB_PASS secret

COPY ./src /var/www/html/app
WORKDIR /var/www/html/app
RUN php artisan up && chown -R www-data:www-data .

COPY ./conf/supervisord-dev.conf /tmp/supervisord-dev.conf

COPY ./scripts/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/bin/bash", "/entrypoint.sh"]
CMD ["start"]
#!/bin/bash
set -e
CMD=$1

echo "$CMD"

case "$CMD" in
  
  "start" )
    echo "=======> Starting MySQL server to set password of spark user & run artisan migrate"
    /usr/sbin/mysqld --user mysql &
    echo "=======> Allowing MySQL server to startup for 10s"
    PID=$!
    sleep 10s
    echo "=======> Setting password..."
    echo "SET PASSWORD FOR 'spark'@'%' = PASSWORD('${DB_PASS}');" | mysql -u root -p$DB_ROOT_PASS
    echo "=======> Running php artisan migrate"
    php artisan migrate
    echo "=======> Shutting down MySQL server"
    kill -INT $PID
    echo "=======> Replacing APP_HOST Environment Variable in nginx virtual host"
    envsubst \$APP_HOST < /tmp/nginx/vhost.conf > /etc/nginx/conf.d/vhost.conf
    npm run production
    echo "=======> Starting Supervisor"
    exec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf
    ;;

  "dev" )
    echo "=======> Starting MySQL server to set password of spark user & run artisan migrate"
    /usr/sbin/mysqld --user mysql &
    echo "=======> Allowing MySQL server to startup for 10s"
    PID=$!
    sleep 10s
    echo "=======> Setting password..."
    echo "SET PASSWORD FOR 'spark'@'%' = PASSWORD('${DB_PASS}');" | mysql -u root -p$DB_ROOT_PASS
    echo "=======> Running php artisan migrate"
    php artisan migrate
    echo "=======> Shutting down MySQL server"
    kill -INT $PID
    echo "=======> Replacing APP_HOST Environment Variable in nginx virtual host"
    envsubst \$APP_HOST < /tmp/nginx/vhost.conf > /etc/nginx/conf.d/vhost.conf
    npm run dev
    echo "=======> Starting Supervisor"
    exec /usr/bin/supervisord -c /tmp/supervisord-dev.conf
    ;;    

  * )
    exec $CMD ${@:2}
    ;;

esac
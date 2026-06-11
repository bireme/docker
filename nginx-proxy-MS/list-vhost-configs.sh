docker compose exec nginx-proxy sh -c 'ls -la /etc/nginx/vhost.d && for f in /etc/nginx/vhost.d/*; do echo "---- $f"; cat "$f"; done'

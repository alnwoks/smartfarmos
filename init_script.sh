#!/bin/bash

echo "Generating certificate with mkcert..."
mkdir devcerts && mkcert -key-file devcerts/key.pem -cert-file devcerts/cert.pem farmos.local *.farmos.local

echo "Starting up containers..."
docker-compose up -d

echo "Add fake domain to /etc/hosts"
echo "127.0.0.1 farmos.local" >> /etc/hosts

echo "Finalizing conatiner setup with drush..."
alias drush="docker-compose exec www drush"
drush site-install farm --locale=us --db-url=mysql://farm:farm@db/farm --site-name=Test0 --account-name=root --account-pass=test install_configure_form.update_status_module='array(FALSE,FALSE)'

echo ""
sudo sh -c "printf \"\n\n\\\$conf['reverse_proxy'] = TRUE;\n\\\$conf['reverse_proxy_addresses'] = [@\\\$_SERVER['REMOTE_ADDR']];\n\\\$base_url = \\\$_SERVER['HTTP_X_FORWARDED_PROTO'] . '://' . \\\$_SERVER['SERVER_NAME'];\n\" >> www/sites/default/settings.php"
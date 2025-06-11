### 安裝 php composer
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" && \
echo "$(groups):$(whoami)" && \
mkdir -p /var/www/composer && \
php composer-setup.php --install-dir=/var/www/composer --filename=composer && \
php -r "unlink('composer-setup.php');" && \
chmod +x /var/www/composer/composer && \
echo 'export PATH="/var/www/composer:$PATH"' >> ~/.bashrc && \
source ~/.bashrc && \
composer --version

### 初始化 composer(設定composer.json) => 注意 在ubuntu 需要使用apt安裝jq，以下指定在非ubuntu系統可能會無法執行
composer init --no-interaction --name="$(basename $(dirname "$PWD"))/power-updater" && \
apt update && \
apt install -y jq && \
jq '.extra."installer-paths" = {"src/plugins/current/{$name}/": ["type:wordpress-plugin"]}' composer.json > tmp.json && mv tmp.json composer.json

### 安裝 wpackagist
composer self-update && \
composer config repositories.wpackagist composer https://wpackagist.org && \
composer config --no-plugins allow-plugins.composer/installers true

### 取得所有wordpress 外掛名稱後，使用wpackagist 逐一安裝最新版，再一口氣替換換掉整個 ./wp-content/plugins
mkdir -p ./src/plugins/current && \
basename -a ./wp-content/plugins/*/ | xargs -I {} composer require wpackagist-plugin/{} && \
mv ./wp-content/plugins ./wp-content/plugins_bak && \
mv ./src/plugins/current ./wp-content/plugins && \
rm -rf ./wp-content/plugins_bak

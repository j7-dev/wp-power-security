### 安裝 php composer
# echo "$(groups):$(whoami)" && \
SHELL_DIR=$(pwd)
echo "🚧 開始安裝 composer SHELL_DIR: ${SHELL_DIR}" && \
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" && \
php composer-setup.php --install-dir=${SHELL_DIR} --filename=composer && \
php -r "unlink('composer-setup.php');" && \
chmod +x ${SHELL_DIR}/composer && \
${SHELL_DIR}/composer --version
echo "✅ Composer 安裝完成"

### 初始化 composer(設定composer.json) => 注意 在ubuntu 需要使用apt安裝jq，以下指定在非ubuntu系統可能會無法執行
echo "🚧 開始設定 composer.json"
${SHELL_DIR}/composer init --no-interaction --name="$(basename $(dirname "$PWD"))/power-updater" && \
apt update && \
apt install -y jq && \
jq '.extra."installer-paths" = {"src/plugins/current/{$name}/": ["type:wordpress-plugin"]}' composer.json > tmp.json && mv tmp.json composer.json
echo "✅ 設定 composer.json 完成"

### 安裝 wpackagist
echo "🚧 開始安裝 wpackagist"
${SHELL_DIR}/composer self-update && \
${SHELL_DIR}/composer config repositories.wpackagist composer https://wpackagist.org && \
${SHELL_DIR}/composer config --no-plugins allow-plugins.composer/installers true
echo "✅ 安裝 wpackagist 完成"

### 取得所有wordpress 外掛名稱後，使用wpackagist 逐一安裝最新版，再一口氣替換換掉整個 ./wp-content/plugins
echo "🚧 開始 取得所有wordpress 外掛名稱後，使用wpackagist 逐一安裝最新版，再一口氣替換換掉整個目錄"
mkdir -p ./src/plugins/current && \
basename -a ./wp-content/plugins/*/ | xargs -I {} ${SHELL_DIR}/composer require wpackagist-plugin/{} && \
mv ./wp-content/plugins ./wp-content/plugins_bak && \
mv ./src/plugins/current ./wp-content/plugins && \
rm -rf ./wp-content/plugins_bak
echo "✅ 外掛更新完成"

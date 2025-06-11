### 重新創建composer.json(因為用戶可能把 wordpress plugin 新增或是刪除，所以重新創建composer.json是最能匹配當前wordpress plugins list的)
SHELL_DIR=$(pwd)
echo "🚧 開始重新創建composer.json"
rm -rf composer.json composer.lock && \
${SHELL_DIR}/composer init --no-interaction --name="$(basename $(dirname "$PWD"))/power-updater" && \
jq '.extra."installer-paths" = {"src/plugins/current/{$name}/": ["type:wordpress-plugin"]}' composer.json > tmp.json && mv tmp.json composer.json && \
echo "✅ 重新創建 composer.json 完成"

### 安裝 wpackagist
echo "🚧 開始安裝 wpackagist"
${SHELL_DIR}/composer self-update && \
${SHELL_DIR}/composer config repositories.wpackagist ${SHELL_DIR}/composer https://wpackagist.org && \
${SHELL_DIR}/composer config --no-plugins allow-plugins.composer/installers true && \
echo "✅ 安裝 wpackagist 完成"

### 取得所有wordpress 外掛名稱後，使用wpackagist 逐一安裝最新版，再一口氣替換換掉整個 ./wp-content/plugins
echo "🚧 開始 取得所有wordpress 外掛名稱後，使用wpackagist 逐一安裝最新版，再一口氣替換換掉整個目錄"
mkdir -p ./src/plugins/current && \
basename -a ./wp-content/plugins/*/ | xargs -I {} ${SHELL_DIR}/composer require wpackagist-plugin/{} && \
mv ./wp-content/plugins ./wp-content/plugins_bak && \
mv ./src/plugins/current ./wp-content/plugins && \
rm -rf ./wp-content/plugins_bak
echo "✅ 外掛更新完成"
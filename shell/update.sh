### 重新創建composer.json(因為用戶可能把 wordpress plugin 新增或是刪除，所以重新創建composer.json是最能匹配當前wordpress plugins list的)
rm -rf composer.json composer.lock && \
composer init --no-interaction --name="$(basename $(dirname "$PWD"))/power-updater" && \
jq '.extra."installer-paths" = {"src/plugins/current/{$name}/": ["type:wordpress-plugin"]}' composer.json > tmp.json && mv tmp.json composer.json && \

### 安裝 wpackagist
composer self-update && \
composer config repositories.wpackagist composer https://wpackagist.org && \
composer config --no-plugins allow-plugins.composer/installers true && \

### 取得所有wordpress 外掛名稱後，使用wpackagist 逐一安裝最新版，再一口氣替換換掉整個 ./wp-content/plugins
mkdir -p ./src/plugins/current && \
basename -a ./wp-content/plugins/*/ | xargs -I {} composer require wpackagist-plugin/{} && \
mv ./wp-content/plugins ./wp-content/plugins_bak && \
mv ./src/plugins/current ./wp-content/plugins && \
rm -rf ./wp-content/plugins_bak
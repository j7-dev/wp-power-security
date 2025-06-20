### 安裝 php composer
# echo "$(groups):$(whoami)" && \
# 獲取腳本所在目錄的絕對路徑
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PLUGIN_DIR="$(dirname $(dirname "$SCRIPT_DIR"))"
SITE_DIR="$(dirname $(dirname "$PLUGIN_DIR"))"

echo "🚧 開始安裝 composer SCRIPT_DIR: ${SCRIPT_DIR} SITE_DIR: ${SITE_DIR}"
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" && \
php composer-setup.php --install-dir=${SCRIPT_DIR} --filename=composer && \
php -r "unlink('composer-setup.php');" && \
chmod +x ${SCRIPT_DIR}/composer && \
${SCRIPT_DIR}/composer --version
echo "✅ Composer 安裝完成"

### 初始化 composer(設定composer.json) => 注意 在ubuntu 需要使用apt安裝jq，以下指定在非ubuntu系統可能會無法執行
echo "🚧 開始設定 composer.json"
${SCRIPT_DIR}/composer init --no-interaction --name="$(basename $(dirname "$PWD"))/power-updater" && \
php ${SCRIPT_DIR}/Setup.php
echo "✅ 設定 composer.json 完成"

### 安裝 wpackagist
echo "🚧 開始安裝 wpackagist"
${SCRIPT_DIR}/composer self-update && \
${SCRIPT_DIR}/composer config repositories.wpackagist composer https://wpackagist.org && \
${SCRIPT_DIR}/composer config --no-plugins allow-plugins.composer/installers true
echo "✅ 安裝 wpackagist 完成"

### 取得所有wordpress 外掛名稱後，使用wpackagist 逐一安裝最新版，再一口氣替換換掉整個 ./wp-content/plugins
echo "🚧 開始 取得所有wordpress 外掛名稱後，使用wpackagist 逐一安裝最新版，再一口氣替換換掉整個目錄"

# 創建臨時目錄
mkdir -p ./src/plugins/current

# 獲取所有插件名稱並存儲在數組中
PLUGINS=($(basename -a ${SITE_DIR}/wp-content/plugins/*/))

# 檢查是否找到任何插件
if [ ${#PLUGINS[@]} -eq 0 ]; then
    echo "❌ 錯誤：在 ${SITE_DIR}/wp-content/plugins 中沒有找到任何插件"
    exit 1
fi

INSTALL_SUCCESS=true

# 遍歷並安裝每個插件
for plugin in "${PLUGINS[@]}"; do
    echo "📦 正在安裝插件: $plugin"

    # 先搜尋套件是否存在
    SEARCH_RESULT=$(${SCRIPT_DIR}/composer search --only-name wpackagist-plugin/$plugin)

    if ! ${SCRIPT_DIR}/composer require wpackagist-plugin/$plugin; then
        # 如果安裝失敗，檢查是否是因為套件不存在
        if [ -z "$SEARCH_RESULT" ]; then
            echo "⚠️ 插件 $plugin 在 wpackagist 中不存在，跳過安裝"
            continue
        else
            echo "❌ 安裝插件 $plugin 失敗"
            INSTALL_SUCCESS=false
            break
        fi
    fi
done

# 只有在所有插件都安裝成功的情況下才進行目錄替換
if [ "$INSTALL_SUCCESS" = true ]; then
    echo "✅ 所有插件安裝成功，開始替換目錄"
    mv ./wp-content/plugins ./wp-content/plugins_bak && \
    mv ./src/plugins/current ./wp-content/plugins && \
    rm -rf ./wp-content/plugins_bak
    echo "✅ 外掛更新完成"
else
    echo "❌ 由於部分插件安裝失敗，已取消目錄替換"
    echo "請檢查錯誤日誌並手動處理"
    exit 1
fi

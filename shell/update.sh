### 重新創建composer.json(因為用戶可能把 wordpress plugin 新增或是刪除，所以重新創建composer.json是最能匹配當前wordpress plugins list的)
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PLUGIN_DIR="$(dirname $(dirname "$SCRIPT_DIR"))"
SITE_DIR="$(dirname $(dirname "$PLUGIN_DIR"))"

echo "🚧 開始重新創建composer.json SITE_DIR: ${SITE_DIR}"
rm -rf composer.json composer.lock && \
${SCRIPT_DIR}/composer init --no-interaction --name="$(basename $(dirname "$PWD"))/power-updater" && \
php ${SCRIPT_DIR}/Setup.php
echo "✅ 重新創建 composer.json 完成"

### 安裝 wpackagist
echo "🚧 開始安裝 wpackagist"
${SCRIPT_DIR}/composer self-update && \
${SCRIPT_DIR}/composer config repositories.wpackagist ${SCRIPT_DIR}/composer https://wpackagist.org && \
${SCRIPT_DIR}/composer config --no-plugins allow-plugins.composer/installers true
echo "✅ 安裝 wpackagist 完成"

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

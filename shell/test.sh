echo 'test'

# 獲取腳本所在目錄的絕對路徑
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PLUGIN_DIR="$(dirname $(dirname "$SCRIPT_DIR"))"
SITE_DIR="$(dirname $(dirname "$PLUGIN_DIR"))"

echo "SCRIPT_DIR: ${SCRIPT_DIR}"
echo "PLUGIN_DIR: ${PLUGIN_DIR}"
echo "SITE_DIR: ${SITE_DIR}"

# 獲取所有插件名稱並存儲在數組中
PLUGINS=($(basename -a ${SITE_DIR}/wp-content/plugins/*/))

# 遍歷並安裝每個插件
for plugin in "${PLUGINS[@]}"; do
    echo "📦 正在安裝插件: $plugin"

    # 先搜尋套件是否存在
    SEARCH_RESULT=$(${SCRIPT_DIR}/composer search --only-name wpackagist-plugin/$plugin)

    if [ -z "$SEARCH_RESULT" ]; then
        echo "⚠️ 插件 $plugin 在 wpackagist 中不存在，跳過安裝"
    else
        echo "✅ 插件 $plugin 在 wpackagist 中存在"
    fi
done
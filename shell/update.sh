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

# 創建臨時目錄
mkdir -p ./src/plugins/current

# 獲取所有插件名稱並存儲在數組中
PLUGINS=($(basename -a ./wp-content/plugins/*/))
INSTALL_SUCCESS=true

# 遍歷並安裝每個插件
for plugin in "${PLUGINS[@]}"; do
    echo "📦 正在安裝插件: $plugin"

    # 先搜尋套件是否存在
    SEARCH_RESULT=$(${SHELL_DIR}/composer search --only-name wpackagist-plugin/$plugin)

    if ! ${SHELL_DIR}/composer require wpackagist-plugin/$plugin; then
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

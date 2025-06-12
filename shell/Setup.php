<?php

declare (strict_types = 1);

namespace J7\PowerSecurity\Shell;

/**
 * Setup class for handling plugin setup operations
 */
class Setup {

	/**
	 * Constructor
	 *
	 * @throws \Exception When composer.json is not found
	 */
	public function __construct() {
		$this->set_installer_paths();
	}

	/**
	 * 設定 composer.json 的 installer-paths
	 *
	 * @return bool 是否成功設定
	 * @throws \Exception 當 JSON 操作失敗時
	 */
	public function set_installer_paths(): bool {
		$composer_json = __DIR__ . '/composer.json';

		// 讀取 composer.json
		$json_content = file_get_contents($composer_json);
		if ($json_content === false) {
			throw new \Exception('無法讀取 composer.json');
		}

		// 解析 JSON
		$composer_data = json_decode($json_content, true);
		if (json_last_error() !== JSON_ERROR_NONE) {
			throw new \Exception('composer.json 格式錯誤: ' . json_last_error_msg());
		}

		// 設定 installer-paths
		$composer_data['extra']['installer-paths'] = [
			'src/plugins/current/{$name}/' => [ 'type:wordpress-plugin' ],
		];
		$composer_data['require']                  = (object) [];

		// 將修改後的內容寫入臨時檔案
		$tmp_file = __DIR__ . '/composer.json.tmp';
		$result   = file_put_contents(
			$tmp_file,
			json_encode($composer_data, JSON_PRETTY_PRINT | JSON_UNESCAPED_SLASHES)
			);

		if ($result === false) {
			throw new \Exception('無法寫入臨時檔案');
		}

		// 將臨時檔案移動回原檔案
		if (!rename($tmp_file, $composer_json)) {
			unlink($tmp_file); // 清理臨時檔案
			throw new \Exception('無法更新 composer.json');
		}

		return true;
	}
}

new Setup();

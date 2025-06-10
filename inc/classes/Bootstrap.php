<?php

declare (strict_types = 1);

namespace J7\PowerSecurity;

use J7\PowerSecurity\Plugin;

/** Class Bootstrap */
final class Bootstrap {
	use \J7\WpUtils\Traits\SingletonTrait;

	/** @var string Shell dir */
	private string $shell_dir;

	/** Constructor */
	public function __construct() {
		$this->shell_dir = Plugin::$dir . '/shell';

		// TEST ----- ▼ 測試特定 hook 記得刪除 ----- //
		\add_action(
			'init',
			function () {
				$this->run_command();
			}
			);
		// TEST ---------- END ---------- //
	}

	/** Run command */
	public function run_command(): void {
		$filename = 'test.sh';
		// 執行 /shell 目錄裡面的 test.sh
		$shell_path = "{$this->shell_dir}/{$filename}";
		try {
			\exec("bash {$shell_path}", $output, $return_code); // phpcs:ignore
			$level = $return_code === 0 ? 'debug' : 'error';
			Plugin::logger(
				"執行 {$filename} 結果 return_code: {$return_code}",
				$level,
				[
					'shell_path' => $shell_path,
					'output'     => $output,
				]
				);
		} catch (\Throwable $th) {
			Plugin::logger(
				"執行 {$filename} 結果 return_code: {$return_code}",
				'critical',
				[
					'shell_path'    => $shell_path,
					'error_message' => $th->getMessage(),
				]
				);
		}
	}
}

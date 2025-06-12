<?php
/**
 * Plugin Name:       Power Security | 用更安全、智慧的方式更新外掛
 * Plugin URI:        https://github.com/j7-dev/wp-power-security
 * Description:       用更安全、智慧的方式更新外掛
 * Version:           0.0.4
 * Requires at least: 5.7
 * Requires PHP:      8.0
 * Author:            J7
 * Author URI:        https://github.com/j7-dev
 * License:           GPL v2 or later
 * License URI:       https://www.gnu.org/licenses/gpl-2.0.html
 * Text Domain:       power_security
 * Domain Path:       /languages
 * Tags: security, update, updater
 */

declare (strict_types = 1);

namespace J7\PowerSecurity;

if ( \class_exists( 'J7\PowerSecurity\Plugin' ) ) {
	return;
}
require_once __DIR__ . '/vendor/autoload.php';

/**
	* Class Plugin
	*/
final class Plugin {
	use \J7\WpUtils\Traits\PluginTrait;
	use \J7\WpUtils\Traits\SingletonTrait;

	/**
	 * Constructor
	 */
	public function __construct() {

		// $this->required_plugins = array(
		// array(
		// 'name'     => 'WooCommerce',
		// 'slug'     => 'woocommerce',
		// 'required' => true,
		// 'version'  => '7.6.0',
		// ),
		// array(
		// 'name'     => 'WP Toolkit',
		// 'slug'     => 'wp-toolkit',
		// 'source'   => 'Author URL/wp-toolkit/releases/latest/download/wp-toolkit.zip',
		// 'required' => true,
		// ),
		// );

		$this->init(
			[
				'app_name'     => 'Power Security',
				'github_repo'  => 'https://github.com/j7-dev/wp-power-security',
				'callback'     => [ Bootstrap::class, 'instance' ],
				'lc'           => 'ZmFsc2',
				'hide_submenu' => true,
			]
		);
	}

	/**
	 * Logger
	 *
	 * @param string       $message Message
	 * @param string       $level   Level
	 * @param array<mixed> $context Context
	 */
	public static function logger( $message, $level = 'info', $context = [] ): void {
		\J7\WpUtils\Classes\WC::logger( $message, $level, $context, 'power_security', 0 );
	}
}

Plugin::instance();

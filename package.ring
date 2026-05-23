aPackageInfo = [
	:name = "Bolt",
	:description = "Blazing-fast web framework for the Ring Programming Language.",
	:folder = "bolt",
	:developer = "ysdragon",
	:email = "youssefelkholey@gmail.com",
	:license = "MIT",
	:version = "1.0.0",
	:ringversion = "1.27",
	:versions = 	[
		[
			:version = "1.0.0",
			:branch = "master"
		]
	],
	:libs = 	[
		[
			:name = "",
			:version = "",
			:providerusername = ""
		]
	],
	:files = 	[
		// Root
		"lib.ring",
		"main.ring",
		"package.ring",
		"README.md",
		"LICENSE",

		// Docs
		"docs/API.md",
		"docs/USAGE.md",

		// Assets
		"assets/logo.png",

		// Source
		"src/bolt.ring",
		"src/constants.ring",

		// Utils
		"src/utils/color.ring",
		"src/utils/install.ring",
		"src/utils/uninstall.ring",

		// Examples - Basic
		"examples/basic/01_hello.ring",
		"examples/basic/02_http_methods.ring",
		"examples/basic/03_route_params.ring",
		"examples/basic/04_request_response.ring",
		"examples/basic/05_json_api.ring",
		"examples/basic/06_static_files.ring",
		"examples/basic/static/index.html",

		// Examples - Intermediate
		"examples/intermediate/07_cookies_sessions.ring",
		"examples/intermediate/08_middleware.ring",
		"examples/intermediate/09_file_upload.ring",
		"examples/intermediate/10_templates.ring",
		"examples/intermediate/11_form_handling.ring",
		"examples/intermediate/12_error_handling.ring",
		"examples/intermediate/13_signed_cookies_flash.ring",
		"examples/intermediate/14_route_grouping.ring",
		"examples/intermediate/15_per_route_middleware.ring",
		"examples/intermediate/16_openapi_docs.ring",
		"examples/intermediate/17_logging.ring",
		"examples/intermediate/18_validate_sanitize.ring",
		"examples/intermediate/19_env.ring",
		"examples/intermediate/templates/base.html",
		"examples/intermediate/templates/home.html",
		"examples/intermediate/templates/about.html",
		"examples/intermediate/templates/team.html",
		"examples/intermediate/templates/contact.html",
		"examples/intermediate/templates/form_contact.html",
		"examples/intermediate/templates/form_success.html",
		"examples/intermediate/templates/upload_form.html",
		"examples/intermediate/templates/upload_success.html",

		// Examples - Advanced
		"examples/advanced/20_websocket.ring",
		"examples/advanced/21_sse.ring",
		"examples/advanced/22_auth_jwt.ring",
		"examples/advanced/23_cors_security.ring",
		"examples/advanced/24_route_constraints.ring",
		"examples/advanced/25_compression_cache.ring",
		"examples/advanced/26_websocket_rooms.ring",
		"examples/advanced/27_csrf.ring",
		"examples/advanced/28_tls_ip_filter.ring",
		"examples/advanced/29_json_schema.ring",
		"examples/advanced/30_hash_crypto.ring",
		"examples/advanced/31_datetime.ring",
		"examples/advanced/32_advanced_response.ring",
		"examples/advanced/33_api_showcase.ring",
		"examples/advanced/34_server_config_limits.ring",
		"examples/advanced/35_sse_advanced.ring",
		"examples/advanced/36_session_security.ring",
		"examples/advanced/37_request_context.ring",
		"examples/advanced/38_error_responses.ring",
		"examples/advanced/39_csrf_advanced.ring",
		"examples/advanced/40_websocket_control.ring",
		"examples/advanced/41_sanitize_advanced.ring",
		"examples/advanced/42_tls_https.ring",
		"examples/advanced/43_openapi_custom.ring",
		"examples/advanced/templates/layout.html",

		// Rust - Config
		"src/rust_src/Cargo.toml",
		"src/rust_src/src/lib.rs",

		// Rust - Modules
		"src/rust_src/src/modules/mod.rs",
		"src/rust_src/src/modules/base64.rs",
		"src/rust_src/src/modules/crypto.rs",
		"src/rust_src/src/modules/datetime.rs",
		"src/rust_src/src/modules/env.rs",
		"src/rust_src/src/modules/hash.rs",
		"src/rust_src/src/modules/json.rs",
		"src/rust_src/src/modules/sanitize.rs",
		"src/rust_src/src/modules/validate.rs",

		// Rust - Server
		"src/rust_src/src/server/mod.rs",
		"src/rust_src/src/server/auth.rs",
		"src/rust_src/src/server/cache.rs",
		"src/rust_src/src/server/logging.rs",
		"src/rust_src/src/server/middleware.rs",
		"src/rust_src/src/server/openapi.rs",
		"src/rust_src/src/server/rate_limit.rs",
		"src/rust_src/src/server/response.rs",
		"src/rust_src/src/server/sessions.rs",
		"src/rust_src/src/server/sse.rs",
		"src/rust_src/src/server/templates.rs",
		"src/rust_src/src/server/uploads.rs",
		"src/rust_src/src/server/websocket.rs"
	],
	:ringfolderfiles = 	[

	],
	:windowsfiles = 	[
		"lib/windows/amd64/ring_bolt.dll",
		"lib/windows/i386/ring_bolt.dll",
		"lib/windows/arm64/ring_bolt.dll"
	],
	:linuxfiles = 	[
		"lib/linux/amd64/libring_bolt.so",
		"lib/linux/arm64/libring_bolt.so",
		"lib/linux/musl/amd64/libring_bolt.so",
		"lib/linux/musl/arm64/libring_bolt.so"
	],
	:ubuntufiles = 	[

	],
	:fedorafiles = 	[

	],
	:macosfiles = 	[
		"lib/macos/amd64/libring_bolt.dylib",
		"lib/macos/arm64/libring_bolt.dylib"
	],
	:freebsdfiles = 	[
		"lib/freebsd/amd64/libring_bolt.so"
	],
	:windowsringfolderfiles = 	[

	],
	:linuxringfolderfiles = 	[

	],
	:ubunturingfolderfiles = 	[

	],
	:fedoraringfolderfiles = 	[

	],
	:freebsdringfolderfiles = 	[

	],
	:macosringfolderfiles = 	[

	],
	:run = "ring main.ring",
	:windowsrun = "",
	:linuxrun = "",
	:macosrun = "",
	:ubunturun = "",
	:fedorarun = "",
	:setup = "ring src/utils/install.ring",
	:windowssetup = "",
	:linuxsetup = "",
	:macossetup = "",
	:ubuntusetup = "",
	:fedorasetup = "",
	:remove = "ring src/utils/uninstall.ring",
	:windowsremove = "",
	:linuxremove = "",
	:macosremove = "",
	:ubunturemove = "",
	:fedoraremove = "",
    :remotefolder = "bolt",
    :branch = "master",
    :providerusername = "ysdragon",
    :providerwebsite = "github.com"
]

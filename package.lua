return {
	name = "DannehSC/luvit-reql",
	version = "1.0.8",
	description = "A rethinkdb driver for Luvit, please send me a message if you need any assistance or extra features not currently present.",
	tags = { "luvit", "rethinkdb", "database", "driver" },
	license = "MIT",
	author = {name = "DannehSC"},
	homepage = "https://github.com/DannehSC/luvit-reql",
	dependencies = {
		'creationix/coro-net'
	},
	files = {
		"**.lua",
		"!test*"
	}
}
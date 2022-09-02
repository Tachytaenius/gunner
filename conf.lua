local consts = require("consts")

function love.conf(t)
	t.window.width = consts.gameWidth
	t.window.height = consts.gameHeight
	t.window.title = consts.title
	t.identity = consts.identity
	t.version = consts.loveVersion
	t.appendidentity = true
end

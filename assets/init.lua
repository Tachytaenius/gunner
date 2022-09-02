local assets = {}

local function img(path)
	return love.graphics.newImage("assets/" .. path .. ".png")
end

assets.ui = {
	aimer = img("ui/aimer")
}

assets.actors = {
	Player = img("actors/player")
}

assets.corpses = {
	PlayerCorpse = img("corpses/player")
}

assets.items = {
	Pistol = img("items/pistol")
}

return assets

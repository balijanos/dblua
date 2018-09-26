local VCL,mainImages,mainMenu = VCL,mainImages,mainMenu

module "DemoPlugin"

pluginInfo={
	name="DemoPlugin", 
	type="Plugin",
	version="1.1",
	VCLedversion="0.1.3",
	pluginMenuId="demoplg01"
}

local iconFileName="plugins/demo.v1.1/goto_line.png"
local menuId="mmplugins"

function onDemopPluginClick()
	VCL.ShowMessage("Demo plugin works!")
end

function Init()
	local ii = mainImages:LoadFromFile(iconFileName)
	local plug1 = mainMenu:Find(menuId):Add(pluginInfo.pluginMenuId)
	plug1._ = {caption = pluginInfo.name, imageindex=ii, onclick="DemoPlugin.onDemopPluginClick"}
end

function Stop()
	mainMenu:Find(pluginInfo.pluginMenuId):Remove()
end

return pluginInfo


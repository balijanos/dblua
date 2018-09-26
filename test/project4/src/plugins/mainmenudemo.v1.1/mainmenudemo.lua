require "vcl"

local VCL,mainImages,mainMenu,mainActions = VCL,mainImages,mainMenu,mainActions

module "MainMenuDemoPlugin"

pluginInfo={
	name="MainMenuDemoPlugin", 
	type="Main",
	version="1.1",
	VCLedversion="0.1.3",
	pluginMenuId="mainmenudemoplg01",
}

local mmenuId="mmmainmenudemo" -- mainmenu item
local mmenuIdx=3 -- mainmenu index if need to be inserted

function onMainMenuDemoClick()
	VCL.ShowMessage("MainMenuDemo plugin works!")
end

function Init()
	local ii = 0 -- mainImages:LoadFromFile(pluginInfo.fileName)
	local mSD = mainMenu:Find(mmenuId)
	if not mSD then
		mSD = mainMenu:Insert(mmenuIdx,mmenuId)
		mSD._={caption="MainMenuDemo"}
	end
	-- do not duplicate event
	mainActions:LoadFromTable({{name="mainmenudemoPluginAction", shortcut="Ctrl+Shift+5", caption="MainMenuDemo menuitem", imageindex=ii, onexecute="MainMenuDemoPlugin.onMainMenuDemoClick"}})
	local plug1 = mSD:Add(pluginInfo.pluginMenuId)
	plug1._ = {name=pluginInfo.pluginMenuId, action=mainActions:Get("mainmenudemoPluginAction")}
end

function Stop()	
	mainActions:Get("mainmenudemoPluginAction"):Free()
	mainMenu:Find(pluginInfo.pluginMenuId):Remove()
	mainMenu:Find(mmenuId):Remove()
end

return pluginInfo


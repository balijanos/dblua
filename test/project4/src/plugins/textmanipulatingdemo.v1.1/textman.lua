require "vcl"

local VCL,Editors,SynEdit,mainImages,mainMenu,table = VCL,Editors,SynEdit,mainImages,mainMenu,table

module "TextManDemoPlugin"

pluginInfo={
	name="TextManDemoPlugin", 
	type="Plugin",
	version="1.1",
	VCLedversion="0.1.3",
	pluginMenuId="textmandemoplg01"
}

local iconFileName="plugins/textmanipulatingdemo.v1.1/textman.png"
local menuId="mmplugins"

function onTextManDemoPluginClick()
	local n = Editors.GetEditor()
	if not n or Editors.openedPages[n].Type~="SynEdit" then return end
	local e = Editors.openedPages[n].Editor
	local t = e:GetText()
	table.insert(t,1,"#!/usr/local/bin/lua5.1")
	e:SetText(t)
	SynEdit.onEditorChange(e)
end

-- Plugin initialization
function Init()
	local ii = mainImages:LoadFromFile(iconFileName)
	local plug1 = mainMenu:Find(menuId):Add(pluginInfo.pluginMenuId)
	plug1._ = {caption = "Text Manipulation Demo", imageindex=ii, onclick="TextManDemoPlugin.onTextManDemoPluginClick"}
end

function Stop()
	mainMenu:Find(pluginInfo.pluginMenuId):Remove()
end

return pluginInfo


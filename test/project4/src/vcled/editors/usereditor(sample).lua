require "vcl"
require "vcled.editors.installededitors"

local VCL,InstalledEditors = VCL,InstalledEditors

module "UserEdit"

-- Editor Registration 
InstalledEditors.Register("UserEdit","*.useredit","UserEdit Files")

function New(n, filename)
	-- add a new UserEditor to the sheet
	local parent = Editors.openedPages[n].Sheet
	local usered = VCL.UserEdit(parent)
	Editors.openedPages[n].Editor = usered
	Editors.openedPages[n].Type = "UserEdit"
	Editors.openedPages[n].FileName = filename
	Editors.UID = Editors.UID + 1
	usered._ = {	
			-- set the editor properties here
			tag = Editors.UID,
	}
end

function onInfo(e)
end

function ProcessCommand(e,cmd)
	-- Process commands like ecCopy,ecCut,ecPaste,ecUndo,ecRedo
end

function onSave(e,filename)
end

function onFind(e)
end

function onFindNext(e)
end

function onFindPrev(e)
end

function onReplace(e)
end

function onGotoLine(e)
end

function onPrint(e)
end
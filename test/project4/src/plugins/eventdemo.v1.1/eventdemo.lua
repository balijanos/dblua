local mainActions = mainActions

local VCL,getfenv=VCL,getfenv	

module "EventDemoPlugin"

pluginInfo={
	name="EventDemoPlugin", 
	type="Event",
	version="1.0",
	VCLedversion="0.1.2",
	pluginMenuId="eventdemoplg01",
}

-- event must be global
function onEventDemoClick(s)
	VCL.ShowMessage("EventDemo plugin works!")
	-- call the original event
	getfenv(0)["Edit"].GotoLine()
end

function Init()
	-- hook event
	mainActions:Get("editGotoLineAction").onexecute="EventDemoPlugin.onEventDemoClick"	
end

function Stop()	
	-- unhook event
	mainActions:Get("editGotoLineAction").onexecute=origEvent
end

return pluginInfo


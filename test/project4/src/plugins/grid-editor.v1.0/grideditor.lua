-- Generated with VCLua FormDesigner
require "vcl"
require "vcled.font"
-- globals to see
local string,table,type,pairs,ipairs,tostring,tonumber = string,table,type,pairs,ipairs,tostring,tonumber
local VCL,mainMenu,mainActions,mainImages,Font= VCL,mainMenu,mainActions,mainImages,Font
local print=print

-- ************************************************************************
module "GridDesignerPlugin"

pluginInfo={
	name="GridDesignerPlugin",
	type="Main",
	version="1.0",
	VCLedversion="0.1.3",
	pluginMenuId="griddesignerplg01"
}

GridDesignerForm = nil

local iconFileName="plugins/grid-editor.v1.0/stringgrid.png"
local cdPic="plugins/grid-editor.v1.0/colordialog.png"
local fdPic="plugins/grid-editor.v1.0/fontdialog.png"

function createForm()

   GridDesignerForm = VCL.Form("GridDesignerForm")
   
   GridDesignerForm._ = {
    Width=640,
    Height=480,
    Position="poMainFormCenter",
	borderstyle="bsdialog"
   }   
   
   Page = VCL.PageControl(GridDesignerForm)
   Page._ = {Align="alClient",}
   Page["sheet1"] = VCL.TabSheet(Page)
   Page["sheet1"]._ = {caption="Colums editor"}
   Page["sheet2"] = VCL.TabSheet(Page)
   Page["sheet2"]._ = {caption="Properties"}
   Page["sheet3"] = VCL.TabSheet(Page)
   Page["sheet3"]._ = {caption="Preview", onshow="GridDesignerPlugin.onPreview"}
   
   local Panel = VCL.Panel(GridDesignerForm)
   Panel._ = {Caption="",Align="alBottom",BevelOuter="bvNone",Height=40,}
   VCL.Button(Panel)._ = {Caption="Open in editor",Left=10, Top=10,Width=100,onClick="GridDesignerPlugin.onOpenInEditorClick"}
   VCL.Button(Panel)._ = {Caption="Close", Anchors="[akTop,akRight]", Left=85, Top=10,onClick="GridDesignerPlugin.onGridCloseClick"}

   DesignerGrid = VCL.StringGrid(Page["sheet1"])
   DesignerGrid._ = {
    Align="alClient",
    ScrollBars="ssAutoVertical",
	FixedCols=0,
	ColCount=7,
	RowCount=1,
	MouseWheelOption="mwCursor",
    Options="[goFixedVertLine,goFixedHorzLine,goVertLine,goEditing,goTabs,goAlwaysShowEditor,goHorzLine,goSmoothScroll,goHeaderPushedLook]",
	onEditButtonClick="GridDesignerPlugin.onGridDesignerClick",
    onKeyDown="GridDesignerPlugin.onGridDesignerKeyDown",
   }

   -- Grid header
   DesignerGrid:SetColParams({
    {width=160, title={caption="Title"}},
    {width=120, title={caption="Editor"},buttonstyle="cbsPickList",
       picklist="cbsAuto\ncbsEllipsis\ncbsNone\ncbsPickList\ncbsCheckboxColumn\ncbsButton",
    },
    {width=40, title={caption="Width",Alignment="taCenter"}},
    {width=40, title={caption="Sort",Alignment="taCenter"},buttonstyle="cbsCheckboxColumn",},
    {width=80, title={caption="Color",Alignment="taCenter"},buttonstyle="cbsButton",},
    {width=170, title={caption="Font"},buttonstyle="cbsButton",},
   })  	
   DesignerGrid:LoadRowFromTable(DesignerGrid:AddRow(),{"","cbsAuto","100","0","",""})
   
   local top=40
   VCL.Label(Page["sheet2"])._={caption="Left",left=100,top=12}
   PLeftEdit = VCL.SpinEdit(Page["sheet2"])
   PLeftEdit._={left=125,top=10,value=10,maxvalue=2000}
   VCL.Label(Page["sheet2"])._={caption="Top",left=200,top=12}
   PTopEdit = VCL.SpinEdit(Page["sheet2"])
   PTopEdit._={left=225,top=10,value=10,maxvalue=2000}
   VCL.Label(Page["sheet2"])._={caption="Width",left=300,top=12}
   PWidthEdit = VCL.SpinEdit(Page["sheet2"])
   PWidthEdit._={left=332,top=10,maxvalue=2000,value=300}
   VCL.Label(Page["sheet2"])._={caption="Height",left=400,top=12}
   PHeightEdit = VCL.SpinEdit(Page["sheet2"])
   PHeightEdit._={left=435,top=10,maxvalue=2000,value=300}
   
   VCL.Bevel(Page["sheet2"])._={top=40,left=100,width=390,shape="bsTopLine"}
   
   VCL.Label(Page["sheet2"])._={caption="Align",left=10,top=top+10}
   AlEdit = VCL.ComboBox(Page["sheet2"])
   AlEdit._={left=100,top=top+10,text="alClient",items="alNone\nalTop\nalBottom\nalLeft\nalRight\nalClient\nalCustom"}
   VCL.Label(Page["sheet2"])._={caption="BorderStyle",left=10,top=top+40}
   BsEdit = VCL.ComboBox(Page["sheet2"])
   BsEdit._={left=100,top=top+40,text="bsSingle",items="bsNone\nbsSingle"}
   VCL.Label(Page["sheet2"])._={caption="Color",left=10,top=top+70}
   ColEdit = VCL.EditButton(Page["sheet2"],"colorSelectButton")
   ColEdit._={text="Sample Text",left=100,top=top+70,width=150,image=cdPic,onbuttonclick="GridDesignerPlugin.onGridPropertyClick"}
   VCL.Label(Page["sheet2"])._={caption="FixedRows",left=10,top=top+100}
   FrEdit = VCL.SpinEdit(Page["sheet2"])
   FrEdit._={left=100,top=top+100,value=1}
   VCL.Label(Page["sheet2"])._={caption="FixedCols",left=10,top=top+130}
   FcEdit = VCL.SpinEdit(Page["sheet2"])
   FcEdit._={left=100,top=top+130}
   VCL.Label(Page["sheet2"])._={caption="Font",left=10,top=top+160}
   FntEdit = VCL.EditButton(Page["sheet2"],"fontSelectButton")
   FntEdit._={text="Sample Text",left=100,top=top+160,width=150,autosize=false,image=fdPic,onbuttonclick="GridDesignerPlugin.onGridPropertyClick"}
   VCL.Label(Page["sheet2"])._={caption="GridLineWidth",left=10,top=top+190}
   GlEdit = VCL.SpinEdit(Page["sheet2"])
   GlEdit._={left=100,top=top+190,value=1}
   VCL.Label(Page["sheet2"])._={caption="Options",left=10,top=top+220}
   OpEdit = VCL.CheckListBox(Page["sheet2"])
   OpEdit._={left=100,top=top+220,width=150,height=75,
	items="goFixedVertLine\ngoFixedHorzLine\ngoEditing\ngoTabs\ngoVertLine\ngoHorzLine\ngoSmoothScroll\ngoHeaderPushedLook\ngoRowSizing\ngoColSizing\n"
   }
   for i=0,OpEdit:Count()-1 do OpEdit:Toggle(i) end
   VCL.Label(Page["sheet2"])._={caption="ScrollBars",left=10,top=top+300}
   SbEdit = VCL.ComboBox(Page["sheet2"])
   SbEdit._={left=100,top=top+300,text="ssAutoBoth",items="ssNone\nssHorizontal\nssVertical\nssBoth\nssAutoHorizontal\nssAutoVertical\nssAutoBoth"}
   VCL.Label(Page["sheet2"])._={caption="OnKeyDown",left=10,top=top+330}
   OnKeyEventEdit = VCL.CheckBox(Page["sheet2"])
   OnKeyEventEdit._={left=100,top=top+330,caption="",checked=true}
   VCL.Label(Page["sheet2"])._={caption="OnHeaderClick",left=150,top=top+330}
   OnHeaderEventEdit = VCL.CheckBox(Page["sheet2"])
   OnHeaderEventEdit._={left=230,top=top+330,caption="",checked=true}
   
   PreviewGrid = VCL.StringGrid(Page["sheet3"])   
   -- do not define resizeevent too early
   OnResize="GridDesignerPlugin.onGridDesignerFormResize"
end

function showGridForm()
	if not GridDesignerForm then createForm() end
	GridDesignerForm:ShowModal()
end

function onGridCloseClick()
    GridDesignerForm:Close()
end

function onGridDesignerClick(s)
	if not DesignerGrid then return end
	local c,r=DesignerGrid:SelectedCell()
	if c==5 then
		local colFont=VCL.FontDlg() 
		if colFont:Execute() then
			DesignerGrid:SetCell(c,r,Font.totablestring(colFont.font))
		end
		colFont:Free()
	elseif c==4 then
		local colColor=VCL.ColorDlg() 
		if colColor:Execute() then
			DesignerGrid:SetCell(c,r,colColor.color)
		end                                       
		colColor:Free()
	end
     GridDesignerForm:ShowOnTop()
end

function onGridDesignerKeyDown(s,k,shift)
	if not DesignerGrid then return end
	local c,r=DesignerGrid:SelectedCell()
	-- insert row - Ctrl + Down
	if shift=="[ssCtrl]" and k==40 and r==DesignerGrid.rowcount-1 then
		DesignerGrid:LoadRowFromTable(DesignerGrid:AddRow(),{"","cbsAuto","100","0","",""})
	-- delete last row - Ctrl + Backspace
	elseif shift=="[ssCtrl]" and k==8 and r==DesignerGrid.rowcount-1 and r>1 then
		DesignerGrid:DeleteColRow(false,r)
		return 0	-- ignore last key (k)
	end                                         
end

function onGridPropertyClick(s)	
	if s.name=="fontSelectButton" then
		local colFont=VCL.FontDlg() 
		if colFont:Execute() then
			FntEdit.font=Font.totable(colFont.font)
		end
		colFont:Free()
	elseif s.name=="colorSelectButton" then
		local colColor=VCL.ColorDlg() 
		if colColor:Execute() then
			ColEdit.color = colColor.color
		end                                       
		colColor:Free()
	end
    GridDesignerForm:ShowOnTop()
end

function onGridDesignerFormResize()
	DesignerGrid:SetColParams(5,{width=Page.width-528})
end

function onPreview()

	PreviewGrid._ = {
		left=PLeftEdit.value,
		top=PTopEdit.value,
		width=PWidthEdit.value,
		height=PHeightEdit.value,
		align=AlEdit.Text,
		borderstyle=BsEdit.Text,
		color=ColEdit.Color,
		fixedrows=FrEdit.value,
		fixedcols=FcEdit.value,
		font=Font.totable(FntEdit.font),
		gridlinewidth=GlEdit.value,
		options="["..table.concat(OpEdit:GetChecked(),",").."]", 
		scrollbars=SbEdit.text,
	} 

	PreviewSortCol = {}
	
	for i=0,PreviewGrid.ColCount-1 do
		PreviewGrid:DeleteColRow(true,0)
	end
	
	for i=1,DesignerGrid.RowCount-1 do
		table.insert(PreviewSortCol, tonumber(DesignerGrid:GetCell(3,i))) 
		PreviewGrid:AddCol({			
			title={caption=DesignerGrid:GetCell(0,i)},
			buttonstyle=DesignerGrid:GetCell(1,i),
			width=tonumber(DesignerGrid:GetCell(2,i)), 
			color=tonumber(DesignerGrid:GetCell(4,i)), 
			font=DesignerGrid:GetCell(5,i)
		})
	end
	
	if OnKeyEventEdit.checked then
		PreviewGrid.onKeyDown = "GridDesignerPlugin.onPreviewGridKeyDown"
	else
		PreviewGrid.onKeyDown = nil
	end
	if OnHeaderEventEdit.checked then
		PreviewGrid.onHeaderClick = "GridDesignerPlugin.onPreviewGridHeaderClick"
	else
		PreviewGrid.onHeaderClick = nil
	end
end

function onPreviewGridKeyDown(s,k,shift)
	if not PreviewGrid then return end
	local c,r=PreviewGrid:SelectedCell()
	-- insert row - Ctrl + Down
	if shift=="[ssCtrl]" and k==40 and r==PreviewGrid.rowcount-1 then
		PreviewGrid:LoadRowFromTable(PreviewGrid:AddRow(),{""})
	-- delete last row - Ctrl + Backspace
	elseif shift=="[ssCtrl]" and k==8 and r==PreviewGrid.rowcount-1 and r>1 then
		PreviewGrid:DeleteColRow(false,r)
		return 0	-- ignore last key (k)
	end                                         
end

function onPreviewGridHeaderClick(s,isCol,idx)
	if not PreviewGrid then return end
	if isCol and PreviewSortCol[idx+1]==1 then
		PreviewGrid:SortColRow(isCol,idx)
	end
end

function onOpenInEditorClick()

end

-- ********************************
-- Plugin initialization
-- ********************************
local mmenuId="mmluagriddesigner"     -- mainmenu item
local mmenuIdx=3

function Init()
	local ii = mainImages:LoadFromFile(iconFileName)
	local mTool = mainMenu:Find(mmenuId)
	if not mTool then
		mTool = mainMenu:Insert(mmenuIdx,mmenuId)
		mTool._={caption="&Tools"}
	end                                                                                     
	-- do not duplicate
	mainActions:LoadFromTable({{name="gridDesignerPluginAction", caption="Grid Designer", imageindex=ii, onexecute="GridDesignerPlugin.showGridForm"}})
	local plug = mTool:Add(pluginInfo.pluginMenuId)
	plug._ = {name=pluginInfo.pluginMenuId, action=mainActions:Get("gridDesignerPluginAction")}
end

function Stop()
	if GridDesignerForm then GridDesignerForm:Free() end
	GridDesignerForm = nil
	mainActions:Get("gridDesignerPluginAction"):Free()
	mainMenu:Find(pluginInfo.pluginMenuId):Remove()
end

return pluginInfo

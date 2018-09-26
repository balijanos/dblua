------------------------------------------------------------------------
--
-- DBLua build utilities v1.0
--
-- (C) 2018 Hi-Project Ltd.
--
-- Author: Janos Bali
--
------------------------------------------------------------------------

local dblua = require "dblua"
lfs = require "lfs"
json = require "dkjson"

function getopt( arg, options )
  local tab = {}
  for k, v in ipairs(arg) do
    if string.sub( v, 1, 2) == "--" then
      local x = string.find( v, "=", 1, true )
      if x then tab[ string.sub( v, 3, x-1 ) ] = string.sub( v, x+1 )
      else      tab[ string.sub( v, 3 ) ] = true
      end
    elseif string.sub( v, 1, 1 ) == "-" then
      local y = 2
      local l = string.len(v)
      local jopt
      while ( y <= l ) do
        jopt = string.sub( v, y, y )
        if string.find( options, jopt, 1, true ) then
          if y < l then
            tab[ jopt ] = string.sub( v, y+1 )
            y = l
          else
            tab[ jopt ] = arg[ k + 1 ]
          end
        else
          tab[ jopt ] = true
        end
        y = y + 1
      end
    end
  end
  return tab
end

local m = {}
m.verbose = nil

local pid = 0
local sqlScripts = {}
local sqlSrc = {}

local function addFile(name, path, src)
  path = path or ""
  local mdata = string.format(
      "(%d, '%s','%s', '%s');\n",
      pid,
      name,
      path,
      dblua.b64(src)
    )
    return [[REPLACE INTO module( projectid, name, path, source ) VALUES]]..mdata
end

local function addResource(name, path, data)
  local mdata = string.format(
        "(%d,'%s','%s','%s');\n",
        pid,
        name,
        path,
        dblua.b64(data)
      )
  return [[REPLACE INTO resource( projectid, name, path, data ) VALUES]]..mdata
end

local function recursiveBuild(path,relPath)
    relPath = relPath or ""
	local inf = "DEBUG"
	if m.verbose then inf = "INFO" end
    for file in lfs.dir(path) do
        if file ~= "." and file ~= ".." then
            local f = path..'/'..file
            local attr = lfs.attributes (f)
            assert (type(attr) == "table")
            
            if attr.mode == "file" and string.sub(file, -4)==".lua" then
              
              local src = m.readLocalFile(f)
              local nameSpace = relPath:gsub("/","%.")
              local name = nameSpace..file:match("(.+)%..+")
              sqlSrc[name] = addFile(name, relPath, src)
              table.insert(sqlScripts, name)
			  
              cLog(string.format("+ module added: %s %s", name, path),inf)
            
            elseif attr.mode == "file" and string.sub(file, -4)~=".lua" and  string.sub(file, -4)~=".sql" then
            
              local data = m.readLocalFile(f,"rb") 
              local name = relPath..file
              sqlSrc[name] = addResource(name, relPath, data) 
              table.insert(sqlScripts, name)
              cLog(string.format("+ resource added: %s %s", name, path),inf)
              
            end
        end
    end
    
    for file in lfs.dir(path) do
        if file ~= "." and file ~= ".." then
            local f = path..'/'..file
            local attr = lfs.attributes (f)
            assert (type(attr) == "table")
            if attr.mode == "directory" then
              recursiveBuild (f, relPath..file.."/")
            end
        end
    end
    
end

function m.addFiles(path)
  sqlScripts = {}
  sqlSrc = {}
  local dbScript = ""
  recursiveBuild(path) 
  for _,name in pairs(sqlScripts) do 
    dbScript = dbScript .. sqlSrc[name]
  end
  return dbScript
end

function m.buildProject(buildConfig, dbScript)
  pid = buildConfig.id
  local path = buildConfig.source
  local name = buildConfig.name
  local inf = "DEBUG"
  if m.verbose then inf = "INFO" end
  -- path = system.pathForFile(path)
  dbScript = dbScript or ""
  local pdata = string.format(
      "(%d,'%s','%s','%s');\n",
      buildConfig.id,
      buildConfig.name,
      buildConfig.description,
      buildConfig.version
  )
  dbScript = dbScript .. [[REPLACE INTO project ( id, name, description, version ) VALUES]]..pdata
  cLog(string.format("* application created: %s", buildConfig.description),inf)
  recursiveBuild(path) 
  for _,name in pairs(sqlScripts) do 
    dbScript = dbScript .. sqlSrc[name]
  end
  return dbScript
end

-- file management
function m.table_load( filename, path )
    -- Open the file handle
    local file, errorString = io.open( path.."/"..filename, "r" )
 
    if not file then
        -- Error occurred; output the cause
        cLog( string.format("%s %s %s ", "table.load", tostring(path), errorString) ,"WARN")
    else
        -- Read data from file
        local contents = file:read( "*a" )
        -- Decode JSON data into Lua table
        local t = json.decode( contents )
        -- Close the file handle
        io.close( file )
        -- Return table
        return t
    end
end

function m.table_save( t, filename, path )
    -- Open the file handle
    local file, errorString = io.open( path.."/"..filename, "w" )
 
    if not file then
        -- Error occurred; output the cause
        cLog( string.format("%s %s %s ", "table.save", filename, errorString) ,"WARN")
        return false
    else
        -- Write encoded JSON data to file
        file:write( json.encode( t ) )
        -- Close the file handle
        io.close( file )
        return true
    end
end

function m.readLocalFile(fileName, mode)
  local file, errorString = io.open( fileName, mode or "r" )
  if not file then
	cLog( string.format("%s %s %s ", "readLocalFile", tostring(filename), errorString) ,"ERROR")
  else
      local contents = file:read( "*a" )
      io.close( file )
      return contents
  end
  return ""
end

function m.saveLocalFile(fileName, content, mode)
  local file, errorString = io.open( fileName, mode or "w" )
  if not file then
	  cLog( string.format("%s %s %s ", "saveLocalFile", tostring(filename), errorString) ,"ERROR")
	  return false
  else
      -- Write data to file
      file:write( content )
      -- Close the file handle
      io.close( file )
  end
  file = nil
  return true
end

return m
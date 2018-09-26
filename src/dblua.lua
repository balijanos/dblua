------------------------------------------------------------------------
--
-- DBLua core module v1.0
--
-- (C) 2018 Hi-Project Ltd.
--
-- Author: Janos Bali
--
------------------------------------------------------------------------
package.path=package.path..";./lua;./lib/?.lua;"
package.cpath=package.cpath..";./dll;./*.so;./lib/?.so;./lib/?.dll;"

-- ********************************************
-- Require patch
-- *******************************************

local dbModules = {}
local dbModulesSource = {}

local __require = require

function require(moduleName)
  if dbModules[moduleName] then
	if dbModulesSource[moduleName] == nil then
		dbModulesSource[moduleName] = assert(loadstring(dbModules[moduleName]))()
	end
	return dbModulesSource[moduleName]
  else
    return __require(moduleName)
  end
end

function cLog(msg, level)
  level = level or "DEBUG"
  if _logLevel == "ERROR" and level ~= "ERROR" then
    return
  elseif _logLevel == "WARN" and (level == "DEBUG" or level == "INFO") then
    return
  end
  if _logLevel == "INFO" and level == "DEBUG" then
    return
  end
  print(os.date("%Y-%m-%dT%H:%M:%S"), level, msg)
end

sqlite3 = require "lsqlite3"

local m = {}

m.sqliteDb = nil
m.dbFileName = nil

function m.init(dbFileName)
	sqliteDb = sqlite3.open( dbFileName ) 
	local tablesetup = [[
	CREATE TABLE IF NOT EXISTS project (id INTEGER PRIMARY KEY, name, description, version, modifydate, createdate);
	CREATE TABLE IF NOT EXISTS module (projectid INTEGER NOT NULL, name text NOT NULL, path text NOT NULL, source, modifydate,createdate, UNIQUE(projectid, name));
	CREATE TABLE IF NOT EXISTS resource (projectid INTEGER NOT NULL, name text NOT NULL, path text NOT NULL, data, modifydate,createdate, UNIQUE(projectid, name, path));
	]] 
	m.execSQL( tablesetup )
	m.dbFileName = dbFileName
end

function m.open(dbFileName)
	dbFileName = dbFileName or m.dbFileName
	sqliteDb = sqlite3.open( dbFileName ) 
	if sqliteDb:errcode() ~=0 then
		cLog( string.format("DB open error: %s", sqliteDb:errmsg()) ,"ERROR")
	end
	m.dbFileName = dbFileName
end

function m.close()
	sqliteDb:close()
end

function m.readLocalFile(fileName, mode)
  local file, errorString = io.open( fileName, mode or "r" )
  if not file then
	cLog( string.format("%s %s %s ", "readLocalFile", filename, errorString) ,"ERROR")
  else
      local contents = file:read( "*a" )
      io.close( file )
      return contents
  end
  return ""
end

function m.execSQL(sql)
    sqliteDb:exec(sql)
	if sqliteDb:errcode() ~=0 then
		cLog( string.format("ExecSQL %s at\n%s", sqliteDb:errmsg(),sql) ,"ERROR")
	end
end

function m.getProject(pid)
  local sqlq = "SELECT * FROM project where id="..(pid or 0)
  local r = {}
  for row in sqliteDb:nrows(sqlq) do
    table.insert(r,row)
  end
  return r
end

function m.getProjectByName(name)
  local sqlq = "SELECT * FROM project where name='"..name.."'"
  local r = {}
  for row in sqliteDb:nrows(sqlq) do
    table.insert(r,row)
	break
  end
  return r
end

function m.projectExists(pid)
  local sqlq = "SELECT * FROM project where id="..(pid or 0)
  local r = {}
  for row in sqliteDb:nrows(sqlq) do
    table.insert(r,row)
  end
  return (#r>0)
end

function m.getModules(pid)
  local sqlq = "SELECT * FROM module where projectid="..(pid or 0)
  local r = {}
  for row in sqliteDb:nrows(sqlq) do
    table.insert(r,row)
  end
  return r
end

function m.getResources(pid)
  local sqlq = "SELECT * FROM resource where projectid="..(pid or 0)
  local r = {}
  for row in sqliteDb:nrows(sqlq) do
    table.insert(r,row)
  end
  return r
end

function m.getResourceData(pid, rName)
  m.open()
  local sqlq = "SELECT * FROM resource where projectid="..pid.." AND name='"..rName.."'"
  local r = {}
  for row in sqliteDb:nrows(sqlq) do
	r = row
	r.data = m.unb64(r.data)
	break
  end
  m.close()
  return r.data, r.name
end

local function readModules(pid)
  local scripts = {}
  local modules = m.getModules(pid)
  if #modules==0 then
	return nil
  end
  for i,s in pairs(modules) do
	local src = m.unb64(s.source)
	scripts[s.name] = src
  end
  return scripts
end

function m.load(name, dbFileName)
  local pid
  if type(name)=="string" then
	dbf = dbFileName or name..".db"
	m.open(dbf)
	local p = m.getProjectByName(name)
	if p and p[1] and p[1].id then
		pid = p[1].id
	else
		cLog( string.format("Project not found %s", tostring(name)) ,"ERROR")
		return nil
	end
	dbModules = readModules(pid)
	local project = m.getProject(pid)
	m.close()
	return project[1]
  end
  return nil
end

-- Original version:
-- Lua 5.1+ base64 v3.0 (c) 2009 by Alex Kloss <alexthkloss@web.de>
-- licensed under the terms of the LGPL2
local b='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'

-- decoding
function m.unb64(data)
    data = string.gsub(data, '[^'..b..'=]', '')
    return (data:gsub('.', function(x)
        if (x == '=') then return '' end
        local r,f='',(b:find(x)-1)
        for i=6,1,-1 do r=r..(f%2^i-f%2^(i-1)>0 and '1' or '0') end
        return r;
    end):gsub('%d%d%d?%d?%d?%d?%d?%d?', function(x)
        if (#x ~= 8) then return '' end
        local c=0
        for i=1,8 do c=c+(x:sub(i,i)=='1' and 2^(8-i) or 0) end
        return string.char(c)
    end))
end

-- encoding
function m.b64(data)
    return ((data:gsub('.', function(x) 
        local r,b='',x:byte()
        for i=8,1,-1 do r=r..(b%2^i-b%2^(i-1)>0 and '1' or '0') end
        return r;
    end)..'0000'):gsub('%d%d%d?%d?%d?%d?', function(x)
        if (#x < 6) then return '' end
        local c=0
        for i=1,6 do c=c+(x:sub(i,i)=='1' and 2^(6-i) or 0) end
        return b:sub(c+1,c+1)
    end)..({ '', '==', '=' })[#data%3+1])
end

return m
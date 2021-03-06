------------------------------------------------------------------------
--
-- DBLua make utility v1.0
--
-- (C) 2018 Hi-Project Ltd.
--
-- Author: Janos Bali
--
------------------------------------------------------------------------
package.path=package.path..";./lua;./lib/?.lua;"
package.cpath=package.cpath..";./dll;./*.so;./lib/?.so;./lib/?.dll;"

bt = require "buildtools"
lfs = require "lfs"
dblua = require "dblua"

function print_usage()
	print("Options:")
	print("\t-f makefile","-- makefile name with path")
	print("\t-b","","-- build only, do not deploy")
	print("\t-c","","-- clean")
	print("\t-v","","-- verbose")
	print("\t-h","","-- show this help")
	print("\n\texample: ","make -f test/project4/makefile.lua -v")
end

function clean(options)
	local mkfile = options.makefile or "makefile.lua"
	cLog(string.format("Makefile: %s", mkfile),"INFO")
	mkfile = loadstring(bt.readLocalFile(mkfile))()

	if buildconfig then
		cLog("Clean started.","INFO")
		local app = buildconfig
		local build_info = bt.table_load("build.json", app.target) or {Version=app.version, Build=0}
		local version = build_info.Version
		local build = tonumber(build_info.Build)
		local buildName = string.format("%s/%s-%sb%s.sql", app.target, app.name, version, build)
		cLog(string.format("Removing build: %s", buildName),"INFO")
		local resultOK, errorMsg = os.remove(buildName)
		if (resultOK) then
			if options.verbose then
				cLog(string.format("Removed: %s", buildName),"INFO")
			end
			-- try to remove 'latest' build
			buildName = string.format("%s/%s.sql", app.target, app.name)
			os.remove(buildName)
		else
			cLog(string.format("Removing: %s", errorMsg),"WARN")
		end
		if app.deploy then
			local dbName = app.deploy.."/"..app.name..".db"
			cLog(string.format("Removing deployment: %s", dbName),"INFO")
			resultOK, errorMsg = os.remove(dbName)
			if (resultOK) then
				if options.verbose then
					cLog(string.format("Removed: %s", dbName),"INFO")
				end
			else
				cLog(string.format("Removing: %s", errorMsg),"WARN")
			end
		end
		cLog("Clean finished.","INFO")
	end
end

function make(options)

	local mkfile = options.makefile or "makefile.lua"
	cLog(string.format("Makefile: %s", mkfile),"INFO")
	mkfile = loadstring(bt.readLocalFile(mkfile))()
	
	bt.verbose = options.verbose

	if buildconfig then
		cLog("Build started.","INFO")
		local app = buildconfig
		local build_info = bt.table_load("build.json", app.target) or {Version=app.version, Build=0}
		local version = build_info.Version
		local build = tonumber(build_info.Build)+1
		local maj,min,rel = version:match("(%w+)%.(%w+)%.(%w+)")
		local dbScript = bt.buildProject(app) 
		local buildName = string.format("%s/%s-%sb%s.sql", app.target, app.name, version, build)
		lfs.mkdir(app.target)
		bt.saveLocalFile(buildName, dbScript)
		cLog(string.format("Build saved: %s --> %s", app.description, buildName),"INFO")
		-- save latest version
		buildName = string.format("%s/%s.sql", app.target, app.name)
		bt.saveLocalFile(buildName, dbScript)
		-- deploy
		if app.deploy and not options.buildonly then
			lfs.mkdir(app.deploy)
			local dbName = app.deploy.."/"..app.name..".db"
			cLog(string.format("Deploying: %s", dbName),"INFO")
			dblua.init(dbName)
			dblua.execSQL(dblua.readLocalFile(buildName))
			dblua.close()
		end
		bt.table_save({Name=app.name, Version=version, Build=build}, "build.json", app.target )
		cLog("Build finished.","INFO")
	else
		print_usage()
	end
	
end

-- Main
print("DBLua make utility v1.0")
local build_options = {}
build_options["makefile"] = getopt( arg,"f")["f"]
build_options["buildonly"] = getopt( arg,"")["b"]
build_options["clean"] = getopt( arg,"")["c"]
build_options["verbose"] = getopt( arg,"")["v"]
build_options["help"] = getopt( arg,"")["h"]
if build_options["help"] then
	print_usage()
elseif build_options["clean"] then
	clean(build_options)
else
	make(build_options)
end
	

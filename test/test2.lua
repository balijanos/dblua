dblua = require "lib.dblua"
local prj = dblua.load("project2")

require "test" 

-- resources example
local res = dblua.getResourceData(prj.id, "res/make.cmd")

print("Resource data:",res)
## dblua

This project allows you to run lua scripts directly from database records.

### Requirements
lfs
sqlite3
dkjson

### Creating database records from lua scripts
You'll need create a configuration file to create build.

Example:
~~~
_logLevel = "INFO"

buildconfig = {
	
  -- your project id
	id = 1000,
  
  -- name of your project
	name = "project1",
  
  -- path to source files
	source = "test/project1/src",
  
  -- sql script will created here
	target = "test/project1/build",
  
  -- deploy sqlite db here
	deploy = "test",
  
  -- description of your project
	description = "Sample Project One",
	
  -- version of your project
  version = "1.0.0",
			
}
~~~

Then just make your project with 'make.lua'
~~~
lua lib/make.lua -f myMakeFileName
~~~

### Running lua scripts from database
To run script named 'main.lua' use the require command. 
~~~
dblua = require "lib.dblua"
dblua.load("project1")

require "main" 
~~~

See 'test' directory for more examples.

### make script options
To get the information about the available options use the -h switch
~~~
DBLua make utility v1.0
Options:
        -f makefile     -- makefile name with path
        -b              -- build only, do not deploy
        -c              -- clean
        -v              -- verbose
        -h              -- show this help

        example:        make -f test/project4/makefile.lua -v
~~~

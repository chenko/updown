{print} = require "util"
{spawn} = require "child_process"

coffee = "./node_modules/coffee-script/bin/coffee"

echo = (child) ->
  child.stdout.on "data", (data) -> print data.toString()
  child.stderr.on "data", (data) -> print data.toString()
  child

install = (cb) ->
  console.log "Building..."
  echo child = spawn coffee, ["-c", "-o", "lib", "src"]
  child.on "exit", (status) -> cb?() if status is 0

task "install", "Install, build, and test repo", install
fs = require 'fs'
Path = require 'path'

defs = {}

loadDefs = () ->
  branches = [ 'stable', 'experimental' ]
  for branch in branches
    branchDir = Path.resolve(__dirname, './defs/'+branch)
    dir = fs.readdirSync branchDir
    for fn in dir
      if (m = fn.match(/([^\.]+)\.coffee/))
        name = m[1]
        defs[name] = require Path.join(branchDir,fn)

loadDefs()

console.log defs

Path = require 'path'
fs = require 'fs'
assert = require 'assert'
async = require 'async'

TripParser = require Path.resolve(__dirname, '../lib/tripparser.coffee')
fixturesDir = Path.resolve(__dirname, '../defs/fixtures')

loadFixture = (fn) ->
  fs.readFileSync(fn).toString()

loadResult = (fn) ->
  JSON.parse(loadFixture(fn))


tp = new TripParser
tp.init ->

  defs = []
  for defName, defObj of tp.defs
    defs.push [ defName, defObj ]

  async.each defs, (x, next) ->
    defName = x[0]
    defObj = x[1]

    targets = []
    for targetName, targetObj of defObj.targets
      targets.push [ targetName, targetObj ]

    async.each targets, (y, nextTarget) ->
      targetName = y[0]
      targetObj = y[1]

      describe defName+' ['+targetName+']', ->

        scripts = []
        for fn in fs.readdirSync Path.join(fixturesDir, defName)
          if m = fn.match(new RegExp targetName+"\.(.+)\.mail$")
            scripts.push m[1]

        async.each scripts, (sc, nextScript) ->
          it sc, (done) ->
            fn = Path.join(fixturesDir, defName, targetName+'.'+sc+'.mail')
            result = Path.join(fixturesDir, defName, targetName+'.'+sc+'.json')

            tp.parse loadFixture(fn), (err, data) ->
              assert.deepEqual data, loadResult(result)
              done()

          nextScript()

        , () ->
          nextTarget()
    , ->
      next()



fs = require 'fs'
Path = require 'path'
MailParser = require('mailparser').MailParser
cheerio = require 'cheerio'

class TripParser 

  defs: {}

  init: (callback) ->
    @loadDefs()
    @api =
      cheerio: require 'cheerio'
      moment: require 'moment'

    callback()

  loadDefs: ->
    branches = [ 'stable', 'experimental' ]
    for branch in branches
      branchDir = Path.resolve(__dirname, '../defs/'+branch)
      dir = fs.readdirSync branchDir
      for fn in dir
        if (m = fn.match(/^(.+)\.coffee/))
          name = m[1]
          @defs[name] = require Path.join(branchDir,fn)

  findTarget: (mail, callback) ->
    for defName, defObj of @defs
      for targetName, targetObj of defObj.targets
        # check FROM
        for adr in mail.from
          if adr.address in targetObj.from
            return callback null, [ defName, targetName ]
    
    callback null, false

  parseMail: (mail, callback) ->
    mailparser = new MailParser()
    mailparser.on 'end', (obj) =>
      callback null, obj
    mailparser.write mail
    mailparser.end()

  parse: (mail, callback) ->

    @parseMail mail, (err, obj) =>
      @findTarget obj, (err, target) =>
        if !target
          return callback 'no target'

        #console.log obj.html
        @defs[target[0]].targets[target[1]].scan obj, (err, data) ->
          callback null, data
        , @api


module.exports = TripParser

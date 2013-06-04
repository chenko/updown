request = require 'request'
global.serviceList = {}
util = require 'util'
moment = require 'moment'

Updown = (@name, @data)->
  @interval = @data.interval = @data.interval || 1000 * 60
  serviceList[name] = data
  @init()
  return this


EventEmitter = require("events").EventEmitter
exports = module.exports = Updown
exports.version = "0.0.1"

# Expose app
app = require("./http")
exports.app = app


exports.createService = (name, data)->
  new Updown(name, data)


###
Inherit from `EventEmitter.prototype`.
###
Updown::__proto__ = EventEmitter::

Updown::init = ->
  console.log 'initialize'
  serviceList[this.name].info = {}
  serviceList[this.name].name = this.name.replace ' ', '-'
  this.ping(this)
  setInterval this.ping , @interval, this

Updown::ping = (updown)-> 
  # console.log updown.data.url
  url = updown.data.url
  interval = updown.interval/1000
  console.log 'ping'
  serviceList[updown.name].info.last_run = moment().format('HH:mm:ss')
  serviceList[updown.name].info.next_run = moment().add('seconds', interval).format('HH:mm:ss')

  request url, (err, res, body) ->
    if err?
      updown.isNotOk()
      updown.emit 'down', err
    else
      updown.isOk()
      updown.emit 'up', res, body



Updown::done = (data = null) ->
  serviceList[@name].info.data =  data
  console.log 'on done'

Updown::isOk = (data) ->
  serviceList[@name].info.status = 'UP'

Updown::isNotOk = (data) ->
  serviceList[@name].info.status = 'DOWN'



request = require 'request'
global.serviceList = {}
util = require 'util'
moment = require 'moment'
cronJob = require('cron').CronJob

Updown = (@name, @config) ->
  @config.interval = @config.interval || 1000 * 60 * 5 # 5 minutes
  @service_name = name.toLowerCase()
  if serviceList[@service_name]? 
    throw new Error "Duplicate service name: #{@name}"

  serviceList[@service_name] = @config
  @init()
  return this

EventEmitter = require("events").EventEmitter
exports = module.exports = Updown
exports.version = "0.0.1"

# Expose app
app = require("./http")
exports.app = app

exports.createService = (name, config)->
  new Updown(name, config)

###
Inherit from `EventEmitter.prototype`.
###
Updown::__proto__ = EventEmitter::

Updown::init = ->
  self = this
  console.log 'initialize'
  ## Add empty function to prevent thow error
  @on 'error', -> 
  serviceList[this.service_name].info = {}
  serviceList[this.service_name].name = this.name.replace ' ', '-'
  serviceList[this.service_name].name_origin = this.name
  if this.config.ping? and this.config.ping is true
    this.ping(this)

  #Set Crontime
  try
    new cronJob(
      cronTime: @config.cronTime
      onTick: ->
        # console.log 'runcron'
        self.ping(self)
      start: true
    )
  catch e
    throw new Error 'Cron pattern not valid'


Updown::ping = (updown) ->
  url = updown.config.url
  interval = updown.config.interval/1000
  serviceList[updown.service_name].info.last_run = moment().format('HH:mm:ss')
  serviceList[updown.service_name].info.next_run = moment().add('seconds', interval).format('HH:mm:ss')
  console.log 'pingging....'
  request url, (err, res, body) ->
    if err?
      updown.isNotOk()
      updown.emit 'error', err
    else
      if res.statusCode is 200
        updown.isOk()
        updown.emit 'success', res, body
      else
        updown.emit 'error', body
    # setTimeout updown.ping , updown.config.interval, updown


Updown::process = (fn, self) ->
  updown = self || this
  console.log 'run process'
  updown.process_fn = fn
  interval = updown.config.interval/1000
  serviceList[updown.service_name].info.last_run = moment().format('HH:mm:ss')
  serviceList[updown.service_name].info.next_run = moment().add('seconds', interval).format('HH:mm:ss')
  done = 
    success: (data) ->
      updown.success data
    error: (data) ->
      updown.error data
  fn done

Updown::error = (data) ->
  setTimeout(this.process, this.config.interval, this.process_fn, this)
  this.isNotOk data

Updown::success = (data) ->
  console.log '-------------------------------'
  console.log 'success'
  setTimeout(this.process, this.config.interval, this.process_fn, this)
  this.isOk data

Updown::isOk = (data = null) ->
  serviceList[@service_name].info.data = data
  serviceList[@service_name].info.status = 'UP'

Updown::isNotOk = (data = null) ->
  serviceList[@service_name].info.data = data
  serviceList[@service_name].info.status = 'DOWN'


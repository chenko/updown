request = require 'request'
global.serviceList = {}
util = require 'util'
moment = require 'moment'
cronJob = require('cron').CronJob
timeFormat = 'MMM D YYYY, h:mm:ss a'

Updown = (@name, @config) ->
  @config.cronTime = @config.cronTime ||'00 */1 * * * *' # Run every 5 minutes
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
  # console.log 'initialize'
  ## Add empty function to prevent thow error
  @on 'error', -> 
  @setCronTime('ping')
  serviceList[@.service_name].info = {}
  serviceList[@.service_name].name = @.name.replace ' ', '-'
  serviceList[@.service_name].name_origin = @.name
  serviceList[@service_name].info.interval = @cronTime.cronTime.getTimeout()
  if @.config.ping? and @.config.ping is true
    @.ping(this)

Updown::ping = ->
  self = this
  url = @config.url
  interval = @cronTime._timeout._idleTimeout / 1000
  serviceList[@service_name].info.last_run = moment().format(timeFormat)
  serviceList[@service_name].info.next_run = moment().add('seconds', interval).format(timeFormat)
  # console.log 'pingging....'
  request url, (err, res, body) ->
    if err?
      self.isNotOk()
      self.emit 'error', err
    else
      if res.statusCode is 200
        self.isOk()
        self.emit 'success', res, body
      else
        self.emit 'error', body


Updown::process = (fn) ->
  self = this
  # console.log 'run process'
  @process_fn = fn
  @setCronTime('process')
  interval = @cronTime._timeout._idleTimeout / 1000
  serviceList[@service_name].info.last_run = moment().format(timeFormat)
  serviceList[@service_name].info.next_run = moment().add('seconds', interval).format(timeFormat)

  done = 
    success: (data) ->
      self.success data
    error: (data) ->
      self.error data
  fn done

Updown::setCronTime = (type) ->
  self = this
  try
   @cronTime = new cronJob(
      cronTime: self.config.cronTime
      onTick: ->
        if type is 'ping'
          self.ping()
        else if type is 'process'
          self.process self.process_fn
        else
          thorw new Error 'setCrontime type not valid'

      start: true
    )
    # console.log @cronTime.cronTime.getTimeout()
  catch e
    throw new Error 'Cron pattern not valid'


Updown::error = (data) ->
  this.isNotOk data

Updown::success = (data) ->
  console.log '-------------------------------'
  console.log 'success'
  # setTimeout(this.process, this.config.interval, this.process_fn, this)
  this.isOk data

Updown::isOk = (data = null) ->
  serviceList[@service_name].info.data = data
  serviceList[@service_name].info.status = 'UP'
  serviceList[@service_name].info.interval = @cronTime.cronTime.getTimeout()

Updown::isNotOk = (data = null) ->
  serviceList[@service_name].info.data = data
  serviceList[@service_name].info.status = 'DOWN'
  serviceList[@service_name].info.interval = @cronTime.cronTime.getTimeout()


# new cronJob(
#   cronTime: '00 */1 * * * *'
#   onTick: ->
#     console.log 'cron'
#   start: true
# )

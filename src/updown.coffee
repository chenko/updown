request = require 'request'
global.serviceList = {}
util = require 'util'
moment = require 'moment'
cronJob = require('cron').CronJob
timeFormat = 'MMM D YYYY, h:mm:ss a'
nodemailer = require "nodemailer"
mailer = {}
mailOptions = {}

config =
  startPath: '/dashboard'

Updown = (@name, @config) ->
  @config.cronTime = @config.cronTime || '00 */1 * * * *' # Run every 5 minutes
  @service_name = name.toLowerCase()
  if serviceList[@service_name]? 
    throw new Error "Duplicate service name: #{@name}"

  @init() if @config.ping?
  return this

EventEmitter = require("events").EventEmitter
exports = module.exports = Updown
exports.version = "0.0.1"

exports.createService = (name, config)->
  new Updown(name, config)

exports.setPath = (path) ->
  config.startPath = path

exports.middleware = ->
  # app = require("./http")
  app = require("./http")(config)
  return app

###
Inherit from `EventEmitter.prototype`.
###
Updown::__proto__ = EventEmitter::

Updown::init = ->
  self = this
  # console.log 'initialize'
  ## Add empty function to prevent thow error
  @on 'error', -> 
  serviceList[@service_name] = @config
  @setCronTime('ping')
  serviceList[@.service_name].info = {}
  serviceList[@.service_name].name = @.name.replace /\s/g, '-'
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
  @init()
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
  this.isOk data

Updown::isOk = (data = null) ->
  serviceList[@service_name].info.data = data
  @state = 'UP'
  serviceList[@service_name].info.status = 'UP'
  serviceList[@service_name].info.interval = @cronTime.cronTime.getTimeout()

Updown::isNotOk = (data = null) ->
  #send when state change from up to down
  if @state is 'UP' and @config.sendmail is true
    # console.log 
    @sendMail()

  serviceList[@service_name].info.data = data
  @state = 'DOWN'
  serviceList[@service_name].info.status = 'DOWN'
  serviceList[@service_name].info.interval = @cronTime.cronTime.getTimeout()


Updown::sendMail = ->
  self = @
  mailOptions.subject = "Service [ #{@name} ] is down"
  mailOptions.html = """
  <b>Location</b> : #{@config.url} <br>
  <b>Check Time</b> : #{moment().format('LLL')}
  """

  mailer.sendMail mailOptions, (error, response) ->
    if error
      console.log 'Send email error'
      console.log error
    else
      console.log "Email sent: #{self.name} "

  mailer.close() # shut down the connection pool, no more messages

exports.mailConfig = (config) ->
  # create reusable transport method (opens pool of SMTP connections)
  mailer = nodemailer.createTransport("SMTP",
    service: config.service
    auth:
      user: "bot@jitta.com"
      pass: "1r2o3b4o5t"
  )

  # setup e-mail data
  mailOptions =
    to: config.to # list of receivers





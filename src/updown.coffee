
#
#    Updown Constructor
#
Updown = (opts) ->
  
  # holds website to be Updowned
  @website = ""
  
  # ping intervals in minutes
  @interval = 15
  
  # interval handler
  @handle = null
  
  # initialize the app
  @init opts
  return this

request = require("request")
fs = require("fs")
util = require("util")
EventEmitter = require("events").EventEmitter

#
#    Inherit from EventEmitter
#
util.inherits Updown, EventEmitter

#
#    Methods
#
Updown::init = (opts) ->
  interval = opts.interval or 15
  website = opts.website
  unless website
    @emit "error",
      msg: "You did not specify a website to Updown"

    return
  @website = website
  @interval = opts.interval
  
  # start Updowning
  @start()

Updown::start = ->
  self = this
  time = Date.now()
  console.log "\nUpdowning: " + self.website + "\nTime: " + self.getFormatedDate(time) + "\n"
  
  # create an interval for pings
  self.handle = setInterval(->
    self.ping()
  , self.interval)

Updown::stop = ->
  clearInterval @handle
  @handle = null
  @emit "stop", @website

Updown::ping = ->
  self = this
  currentTime = Date.now()
  console.log 'ping'
  request self.website, (err, res, body) ->
    if res.statusCode is 200
      self.isOk()
    
    else
      console.log 'not ok'
      self.isNotOk res.statusCode
  
  # req.on "error", (err) ->
  #   try
  #     data = self.responseData(404, statusCodes[404 + ""])
  #     self.emit "error", data
  #   catch error
  #     console.log "Uncaught Error Event for " + self.website
  #     console.log "Updown stopped"
  #     self.stop()

  # req.end()

Updown::isOk = ->
  data = @responseData(200, "OK")
  @emit "up", data

Updown::isNotOk = (statusCode) ->
  msg = statusCode
  data = @responseData(statusCode, msg)
  @emit "down", data

Updown::responseData = (statusCode, msg) ->
  data = {}
  time = Date.now()
  data.website = @website
  data.time = time
  data.statusCode = statusCode
  data.statusMessage = msg
  data

Updown::getFormatedDate = (time) ->
  currentDate = new Date(time)
  currentDate = currentDate.toISOString()
  currentDate = currentDate.replace(/T/, " ")
  currentDate = currentDate.replace(/\..+/, "")
  currentDate

module.exports = Updown
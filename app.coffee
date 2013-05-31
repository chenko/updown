
###
Module dependencies.
###
express = require("express")
routes = require("./routes")
user = require("./routes/user")
http = require("http")
path = require("path")
app = express()

updown = require('./updown/')
# service = Updown.createService()

postman = updown.createService 'postman',
  url: 'http://postman:1j2i3t4t5a@postman.jitta.com:3009'
  interval: 5000
  timeout: 1000
# console.log postman

postman.on 'success', (res, body) ->
  # console.log body
  console.log 'on success event'
  this.done 'postman done'

# pushman = updown.createService 'biijo',
#   url: 'http://biijo.jitta.com:3003'
#   interval: 5000
#   timeout: 1000

# updown.process 'postman' , (data, done) ->
  # console.log 'service process'
# service.on 'success', (self, done) ->
#   # console.log self
#   # console.log @data
#   # console.log 'on success event'
#   done { price:1000, symbol:'AAPL' }

# service.create 'biijo',
#   url: 'http://postman:1j2i3t4t5a@postman.jitta.com:3009'
#   interval: 7000
#   timeout: 1000

# service.on 'error', (err) ->
#   console.log 'on error event'

# service.on 'success', (res, body, done) ->
#   console.log 'on success event'
#   done { price:1000, symbol:'AAPL' }

# all environments
app.set "port", process.env.PORT or 3000
app.set "views", __dirname + "/views"
app.set "view engine", "jade"
app.use express.favicon()
app.use express.logger("dev")
app.use express.bodyParser()
app.use express.methodOverride()
# app.use app.router
app.use updown.app
app.use express.static(path.join(__dirname, "public"))

# development only
app.use express.errorHandler()  if "development" is app.get("env")
app.get "/", routes.index
app.get "/users", user.list
http.createServer(app).listen app.get("port"), ->
  console.log "Express server listening on port " + app.get("port")


express = require("express")
app = express()
util = require("util")
module.exports = app

# config
app.set "view options",
  doctype: "html"

app.set "view engine", "jade"
app.set "views", __dirname + "/views"

# middleware
app.use express.favicon()
app.use express.static(__dirname + "/public")

app.get "/service/list", (req, res) ->
  res.json serviceList

app.get '/dashboard', (req, res) ->
  res.render 'dashboard', {services:serviceList}
  # res.render 'dashboard', {serviceList}

app.get "/service/:name/status", (req, res) ->
  name = decodeURI req.param 'name'
  info = serviceList[name].info

  res.json info


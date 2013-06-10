
express = require("express")
app = express()
util = require("util")

module.exports = (config) ->
  app.set "view options",
    doctype: "html"

  app.set "view engine", "jade"
  app.set "views", __dirname + "/views"

  # middleware
  app.use express.favicon()
  app.use express.static(__dirname + "/public")

  app.get "/service/list", (req, res) ->
    res.json serviceList
  app.get config.startPath, (req, res) ->
    res.render 'dashboard', {services:serviceList}

  app.get "/service/:name/status", (req, res) ->
    name = decodeURI req.param 'name'
    return res.send 'Not Found Service', 400 if !serviceList[name]?
    info = serviceList[name].info
    res.json info
    
    
  return app


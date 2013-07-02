/*
Module dependencies.
*/

express = require("express");

http = require("http");

path = require("path");

app = express();

updown = require('../lib/updown');


updown.setPath('/');

google = updown.createService('Google Service', {
  url: 'http://www.google.com',
  ping: true
});

// https website
updown.createService('Paypal Service', {
  url: 'https://www.paypal.com/',
  ping: true
});

// Example service down and custom cronjob time to check every 3 minutes
github = updown.createService('Github 404 Page', {
  url: 'https://github.com/asfdsfewrw',
  cronTime: '00 */3 * * * *',
  ping: true
});

github.on('error', function(){
  //doSomethingWhenServiceDown()
  console.log('github has service down')
})

github.on('success', function(){
  //doSomethingWhenServiceUp()
  console.log('github has service up')
})


// Create process to check service status
database = updown.createService('Backup Database', {
  url: 'Some instance on Amazon EC2',
  cronTime: '00 */5 * * * *'
});

mockupDatabaseData = {
  filename: 'backup20130602',
  size: '599MB',
  createDate: 'Tue Jul 02 2013 23:43:17 GMT+0700 (ICT)'
}
database.process(function(done) {
  //requestToDatabaseServer()
  done.success({
          name: mockupDatabaseData.filename,
          size: mockupDatabaseData.size,
          createDate: mockupDatabaseData.createDate
        });

  // done.error('Not found backup file');
});


app.set("port", process.env.PORT || 3000);

app.set("views", __dirname + "/views");

app.set("view engine", "jade");

app.use(express.favicon());

app.use(express.logger("dev"));

app.use(express.bodyParser());

app.use(express.methodOverride());

app.use(updown.middleware());

app.use(express["static"](path.join(__dirname, "public")));

if ("development" === app.get("env")) {
  app.use(express.errorHandler());
}


http.createServer(app).listen(app.get("port"), function() {
  return console.log("Express server listening on port " + app.get("port"));
});

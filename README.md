

# Updown

Remote monitoring and dashboard for monitor your website.

## User-Interface
  ![updown logo](http://oi39.tinypic.com/301cxg0.jpg "updown interface")

## Installation

    $ npm install updown



## Usage
First create service with `updown.createService()`

You must pass option `ping:true` for simply check service status

```js
google = updown.createService('Google Service', {
  url: 'http://www.google.com',
  ping: true
});
```

### Cronjob
To specify time to check service status, simply pass the `cronTime` option with cron job format

```js
google = updown.createService('Check Google Uptime', {
  url: 'http://www.google.com',
  cronTime: '00 30 11 * * 1-5'
  ping: true
  // Runs every weekday (Monday through Friday)
  // at 11:30:00 AM. It does not run on Saturday sor Sunday.
});
```
### Available Cron patterns

    Asterisk. E.g. *
    Ranges. E.g. 1-3,5
    Steps. E.g. */2
    
### Cron example
    */10 * * * * 1-2  Run every 10 seconds on Monday and Tuesday
    00 */2 * * * *  Run every 2 minutes everyday
    00 30 09-10 * * * Run at 09:30 and 10:30 everyday
    00 30 08 10 06 * Run at 08:30 on 10th June

    * Use 0 for Sunday

[Read more cron patterns here](http://www.thegeekstuff.com/2009/06/15-practical-crontab-examples/).


## Events
  The following events are currently supported:

      - `success` when service has up
      - `error` when service has down

  For example this may look something like the following:

```js
google.on('error', function(){
  doSomethingWhenServiceDown()
  console.log('google has service down')
});

google.on('success', function(){
  doSomethingWhenServiceUp()
  console.log('google has service up')
});
```

## Processing Service
  To processing service. First create service instance and don't pass `ping` option, Updown not use `url` option
to ping service status, so you can pass not only url but also pass string or service name you want.

  we invoke `done.error()` for service has down and `done.success()` when service has up

```js
database = updown.createService('Backup Database', {
  url: 'Some instance on Amazon EC2',
  cronTime: '00 */5 * * * *'
});

database.process(function(done) {
  requestToDatabaseServer(function(err,data){
    if(err){
      done.error()
    }else{
      done.success()
    }
  });
});

```
  You can pass object or string parameter to tell Updown what is response when processing service
to show up on web UI

```js
database.process(function(done) {
  requestToDatabaseServer(function(err,data){
    if(err){
      done.error('Database not found.')
    }else{
      done.success({
        filename: data.databaseName,
        size: data.databaseSize,
        createDate: data.createDate
      })

    }
  });
});

```

  On web interface when you pass data to `done.success(data)` or `done.error(data)`
![updown](http://i.imgur.com/UbIq0fy.png)

## Email Alert
  Calling `updown.mailConfig()` with SMTP config to send mail when service change status from up to down

```js
updown.mailConfig({
  service: "Gmail",
  auth: {
      user: "gmail.user@gmail.com",
      pass: "userpass"
  }
});
```

  Pass the `sendmail` option for service you want to send mail.

```js
google = updown.createService('Check Google Uptime', {
  url: 'http://www.google.com',
  ping: true
  sendmail: true
});
```

## Connect with Express
  Incorporate updown into your express app in just one step.

Add the Middleware to express

```js
express = require("express");
app = express();
app.use(updown.middleware());
app.listen(3000);
```

## Example Application
  There is an example application at [./example](https://github.com/chenko/updown/tree/master/example)
To run it:

    $ cd example
    $ node server.js


## Securing updown
  Add authentication for your app by adding additional middleware like Connect's `basicAuth()`

```js
app.use(express.basicAuth('testUser', 'testPass'));
```


## API

`updown.createService( name, options)`

  * `url` - [REQUIRED] - The service location.
  * `ping` - [OPTIONAL] - Simply ping the url. don't use this option when use `updown.process()`.
  * `cronTime` - [OPTIONAL] - defaults to `00 */1 * * * *` run every 1 minutes.

`updown.setPath(path)`

  Set path to web interface. defaults is root path `'/'`.

## TODO
* Use Socket.io to update service status.
* Display both local and server time
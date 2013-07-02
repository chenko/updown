

# Updown

Remote monitoring and dashboard for your node.js app

## User-Interface
  ![updown logo](http://oi39.tinypic.com/301cxg0.jpg "updown interface")

## Installation

    $ npm install updown



## Usage
First create service with `updown.createService()`

You must pass argument `ping:true` for simple check service status

```js
google = updown.createService('Check Google Uptime', {
  url: 'http://www.google.com',
  ping: true
});
```

### Cronjob
To specify time to check service status, simply pass the `cronTime` argument with cron job format

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
  //doSomethingWhenServiceDown()
  console.log('google has service down')
});

google.on('success', function(){
  //doSomethingWhenServiceUp()
  console.log('google has service up')
});
```

## Processing Service
  To processing service. First create service instance and don't pass `ping` argument, Updown not use `url` argument
to ping service status, so you can pass not only url but also pass string or service name you want.

  we invoke `done.error()` for service down and `done.success` when service up
`done.success()`

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
  You can pass object or string argument to tell Updown what is response when processing service
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


    

Add the Middleware to Express

Routing
==========
    

Example Application
==========





API
==========

Parameter Based

`CronJob`

  * `constructor(cronTime, onTick, onComplete, start, timezone, context)` - Of note, the first parameter here can be a JSON object that has the below names and associated types (see examples above).
    * `cronTime` - [REQUIRED] - The time to fire off your job. This can be in the form of cron syntax or a JS [Date](https://developer.mozilla.org/en/JavaScript/Reference/Global_Objects/Date) object.
    * `onTick` - [REQUIRED] - The function to fire at the specified time.
    * `onComplete` - [OPTIONAL] - A function that will fire when the job is complete, when it is stopped.
    * `start` - [OPTIONAL] - Specifies whether to start the job after just before exiting the constructor.
    * `timeZone` - [OPTIONAL] - Specify the timezone for the execution. This will modify the actual time relative to your timezone.
    * `context` - [OPTIONAL] - The context within which to execute the onTick method. This defaults to the cronjob itself allowing you to call `this.stop()`. However, if you change this you'll have access to the functions and values within your context object.
  * `start` - Runs your job.
  * `stop` - Stops your job.

`CronTime`

  * `constructor(time)`
    * `time` - [REQUIRED] - The time to fire off your job. This can be in the form of cron syntax or a JS [Date](https://developer.mozilla.org/en/JavaScript/Reference/Global_Objects/Date) object.

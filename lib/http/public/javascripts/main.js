(function(){  


  $.get('service/list', function(serviceList) {
    for( service in serviceList){
      data = serviceList[service]
      new Monitor(service, data)
    }
    
  });

  Monitor = function(service, data){
    this.service = service.replace(' ', '-')
    this.name = service
    this.data = data
    this.state = 'warning'
    this.init()
    update = $('table.service .'+ this.service+' td')
    this.$ = {}
    this.$.tr = $('table.service .'+ this.service)
    this.$.last_run = update[3]
    this.$.next_run = update[4]
    this.$.status = update[5]
  }

  Monitor.prototype.init = function() {
    ms = this.data.interval
    self = this
    this.getStatus(this)
    // (function(){
      // console.log('aaaaa')
    setInterval(self.getStatus,ms,self)
      // console.log('bbbbb')
    // })()
  };
  Monitor.prototype.getStatus = function(self) {
    url = 'service/'+encodeURI(self.name)+'/status'
    $.get(url, function(data){
      self.updateStatus(data)
    })

  };

  Monitor.prototype.updateStatus = function(data) {
    this.$.last_run.innerHTML = data.last_run

    this.$.next_run.innerHTML = data.next_run
    this.changeStatus(data.status)
  };

  Monitor.prototype.changeStatus = function(status) {
    this.$.status.innerHTML = status
    className = status == 'UP' ? 'success' : 'error'
    this.$.tr.removeClass(this.state)
    this.$.tr.addClass(className)
    this.state = className
    

  }

})()

  
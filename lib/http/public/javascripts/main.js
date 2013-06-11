(function(){  
  $.get('service/list', function(serviceList) {
    for( service in serviceList){
      data = serviceList[service]
      new Monitor(service, data)
    }
    
  });

  var offset
  updateDatetime = function(){
    if(offset >= 0){
      datetime = moment().utc().add('hours',offset).format('MMMM DD YYYY, h:mm:ss a')
    }else{
      datetime = moment().utc().subtract('hours',offset).format('MMMM DD YYYY, h:mm:ss a')
    }
    $('div.datetime h1').html(datetime);
  }

  $.get('timezone', function(result) {
    offset = result.offset
    updateDatetime()
    setInterval(updateDatetime, 1000);
    
  });


  Monitor = function(service, data){
    this.service = service.replace(/\s/g, '-')
    this.name = service
    this.data = data
    this.state = 'warning'
    update = $('table.service .'+ this.service+' td')
    this.$ = {}
    this.$.tr = $('table.service .'+ this.service)
    this.$.last_run = update[3]
    this.$.next_run = update[4]
    this.$.status_text = update[5].getElementsByClassName('text')[0]
    this.$.status_icon = update[5].getElementsByClassName('status-icon')[0]
    this.$.status_data = update[5]
    this.init()
  }

  Monitor.prototype.init = function() {
    ms = this.data.interval
    self = this
    self.getStatus(self)
  };
  Monitor.prototype.getStatus = function(self) {
    ms = this.data.interval
    url = 'service/'+ encodeURI(self.name)+'/status'
    $.get(url, function(data){
      self.data = data
      self.updateStatus()
      setTimeout(self.getStatus,data.interval,self)
    })

  };

  Monitor.prototype.updateStatus = function() {
    this.$.last_run.innerHTML = this.data.last_run
    this.$.next_run.innerHTML = this.data.next_run
    this.changeData()
    this.changeStatus(this.data.status)
  };

  Monitor.prototype.changeData = function() {
    html = this.JSON2Html(this.data.data)
    if(this.data.data == null){
      this.$.status_icon.style.display = 'none'
      $(this.$.status_data).popover('destroy')
    }else{
      $(this.$.status_data).popover({ placement:'left',trigger:'hover', html:true })
      $(this.$.status_data).attr('data-content', html)
      this.$.status_icon.style.display = 'inline-block'
    }

  }

  Monitor.prototype.JSON2Html = function(data){
    html = []
    html.push('<ul>')
    if(typeof data === 'object'){
      for(key in data){
        item = data[key]
        html.push('<li>'+key+' : '+JSON.stringify(item)+'</li>')
      }
      html.push('</ul>')
    }else{
      html.push(data)
    }
    return html.join('')
  }

  Monitor.prototype.changeStatus = function(status) {
    this.$.status_text.innerHTML = typeof status != 'undefined' ? status : 'Pending....'
    // console.log(status)
    if(status === 'UP'){
      className = 'success'
    }else if(status === 'DOWN'){
      className = 'error'
    }else{
      className = 'warning'
    }
    this.$.tr.removeClass(this.state)
    this.$.tr.addClass(className)
    this.state = className
    

  }

})()

  
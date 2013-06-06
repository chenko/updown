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
    update = $('table.service .'+ this.service+' td')
    this.$ = {}
    this.$.tr = $('table.service .'+ this.service)
    this.$.last_run = update[3]
    this.$.next_run = update[4]
    this.$.status_text = update[5]
    this.$.status_data = update[5]
    $(this.$.status_data).popover({ placement:'left',trigger:'hover', html:true })
    // $(this.$.status_data).popover({ placement:'left', html:true })
    this.init()
    // this.changeData()
  }

  Monitor.prototype.init = function() {
    ms = this.data.interval
    self = this
    // (function(){
      // console.log('aaaaa')
    self.getStatus(self)
    // setInterval(self.getStatus,ms,self)
      // console.log('bbbbb')
    // })()
  };
  Monitor.prototype.getStatus = function(self) {
    ms = this.data.interval
    url = 'service/'+ encodeURI(self.name)+'/status'
    $.get(url, function(data){
      self.updateStatus(data)
      setTimeout(self.getStatus,ms,self)
    })

  };

  Monitor.prototype.updateStatus = function(data) {
    this.$.last_run.innerHTML = data.last_run
    this.$.next_run.innerHTML = data.next_run
    this.changeData(data.data)
    this.changeStatus(data.status)
  };

  Monitor.prototype.changeData = function(data) {
    html = this.JSON2Html(data)
    // console.log(html);
    // decode = JSON.stringify(data).replace('{','/{')
    // console.log(decode)
    $(this.$.status_data).attr('data-content', html)
    // $(this.$.status_data).attr('data-content', 'aaaaaa')
    // $(this.$.status_data).popover('show')

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

  
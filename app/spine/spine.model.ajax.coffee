(($) ->
  getUrl = (object) ->
    return null  unless (object and object.url)
    (if $.isFunction(object.url) then object.url() else object.url)
  
  methodMap = 
    create: "POST"
    update: "PUT"
    destroy: "DELETE"
    read: "GET"
  
  urlError = ->
    throw new Error("A 'url' property or function must be specified")
  
  ajaxSync = (e, method, record) ->
    params = 
      type: methodMap[method]
      contentType: "application/json"
      dataType: "json"
      processData: false
    
    params.url = getUrl(record)
    throw ("Invalid URL")  unless params.url
    params.data = JSON.stringify(record)  if method == "create" or method == "update"
    if method == "read"
      params.success = (data) ->
        (record.populate or record.load) data
    params.error = (e) ->
      record.trigger "error", e
    
    $.ajax params
  
  Spine.Model.Ajax = extended: ->
    @sync ajaxSync
    @fetch @proxy((e) ->
      ajaxSync e, "read", this
    )
  
  Spine.Model.extend url: ->
    "/" + @name.toLowerCase() + "s"
  
  Spine.Model.include url: ->
    base = getUrl(@parent)
    base += (if base.charAt(base.length - 1) == "/" then "" else "/")
    base += encodeURIComponent(@id)
    base
) jQuery

Spine.Model.Local = 
  extended: ->
    @sync @proxy(@saveLocal)
    @fetch @proxy(@loadLocal)
  
  saveLocal: ->
    result = JSON.stringify(this)
    localStorage[@name] = result
  
  loadLocal: ->
    result = localStorage[@name]
    return  unless result
    result = JSON.parse(result)
    @refresh result

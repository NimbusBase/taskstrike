(->
  if typeof exports != "undefined"
    Spine = exports
  else
    Spine = @Spine = {}
  Spine.version = "0.0.4"
  $ = Spine.$ = @jQuery or @Zepto or ->
    arguments[0]
  
  makeArray = Spine.makeArray = (args) ->
    Array::slice.call args, 0
  
  isArray = Spine.isArray = (value) ->
    Object::toString.call(value) == "[object Array]"
  
  if typeof Array::indexOf == "undefined"
    Array::indexOf = (value) ->
      i = 0
      
      while i < @length
        return i  if this[i] == value
        i++
      -1
  Events = Spine.Events = 
    bind: (ev, callback) ->
      evs = ev.split(" ")
      calls = @_callbacks or (@_callbacks = {})
      i = 0
      
      while i < evs.length
        (@_callbacks[evs[i]] or (@_callbacks[evs[i]] = [])).push callback
        i++
      this
    
    trigger: ->
      args = makeArray(arguments)
      ev = args.shift()
      
      return false  unless (calls = @_callbacks)
      return false  unless (list = @_callbacks[ev])
      i = 0
      l = list.length
      
      while i < l
        return false  if list[i].apply(this, args) == false
        i++
      true
    
    unbind: (ev, callback) ->
      unless ev
        @_callbacks = {}
        return this
      
      return this  unless (calls = @_callbacks)
      return this  unless (list = calls[ev])
      unless callback
        delete @_callbacks[ev]
        
        return this
      i = 0
      l = list.length
      
      while i < l
        if callback == list[i]
          list = list.slice()
          list.splice i, 1
          calls[ev] = list
          break
        i++
      this
  
  Log = Spine.Log = 
    trace: true
    logPrefix: "(App)"
    log: ->
      return  unless @trace
      return  if typeof console == "undefined"
      args = makeArray(arguments)
      args.unshift @logPrefix  if @logPrefix
      console.log.apply console, args
      this
  
  if typeof Object.create != "function"
    Object.create = (o) ->
      F = ->
      F:: = o
      new F()
  moduleKeywords = [ "included", "extended" ]
  Class = Spine.Class = 
    inherited: ->
    
    created: ->
    
    prototype: 
      initialize: ->
      
      init: ->
    
    create: (include, extend) ->
      object = Object.create(this)
      object.parent = this
      object:: = object.fn = Object.create(@::)
      object.include include  if include
      object.extend extend  if extend
      object.created()
      @inherited object
      object
    
    init: ->
      instance = Object.create(@::)
      instance.parent = this
      instance.initialize.apply instance, arguments
      instance.init.apply instance, arguments
      instance
    
    proxy: (func) ->
      thisObject = this
      ->
        func.apply thisObject, arguments
    
    proxyAll: ->
      functions = makeArray(arguments)
      i = 0
      
      while i < functions.length
        this[functions[i]] = @proxy(this[functions[i]])
        i++
    
    include: (obj) ->
      for key of obj
        @fn[key] = obj[key]  if moduleKeywords.indexOf(key) == -1
      included = obj.included
      included.apply this  if included
      this
    
    extend: (obj) ->
      for key of obj
        this[key] = obj[key]  if moduleKeywords.indexOf(key) == -1
      extended = obj.extended
      extended.apply this  if extended
      this
  
  Class::proxy = Class.proxy
  Class::proxyAll = Class.proxyAll
  Class.inst = Class.init
  Class.sub = Class.create
  Spine.guid = ->
    "xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx".replace(/[xy]/g, (c) ->
      r = Math.random() * 16 | 0
      v = (if c == "x" then r else (r & 0x3 | 0x8))
      v.toString 16
    ).toUpperCase()
  
  Model = Spine.Model = Class.create()
  Model.extend Events
  Model.extend 
    setup: (name, atts) ->
      model = Model.sub()
      model.name = name  if name
      model.attributes = atts  if atts
      model
    
    created: (sub) ->
      @records = {}
      @attributes = (if @attributes then makeArray(@attributes) else [])
    
    find: (id) ->
      record = @records[id]
      throw ("Unknown record")  unless record
      record.clone()
    
    exists: (id) ->
      try
        return @find(id)
      catch e
        return false
    
    refresh: (values) ->
      values = @fromJSON(values)
      @records = {}
      i = 0
      il = values.length
      
      while i < il
        record = values[i]
        record.newRecord = false
        @records[record.id] = record
        i++
      @trigger "refresh"
      this
    
    select: (callback) ->
      result = []
      for key of @records
        result.push @records[key]  if callback(@records[key])
      @cloneArray result
    
    findByAttribute: (name, value) ->
      for key of @records
        return @records[key].clone()  if @records[key][name] == value
    
    findAllByAttribute: (name, value) ->
      @select (item) ->
        item[name] == value
    
    each: (callback) ->
      for key of @records
        callback @records[key]
    
    all: ->
      @cloneArray @recordsValues()
    
    first: ->
      record = @recordsValues()[0]
      record and record.clone()
    
    last: ->
      values = @recordsValues()
      record = values[values.length - 1]
      record and record.clone()
    
    count: ->
      @recordsValues().length
    
    deleteAll: ->
      for key of @records
        delete @records[key]
    
    destroyAll: ->
      for key of @records
        @records[key].destroy()
    
    update: (id, atts) ->
      @find(id).updateAttributes atts
    
    create: (atts) ->
      record = @init(atts)
      record.save()
    
    destroy: (id) ->
      @find(id).destroy()
    
    sync: (callback) ->
      @bind "change", callback
    
    fetch: (callbackOrParams) ->
      (if typeof (callbackOrParams) == "function" then @bind("fetch", callbackOrParams) else @trigger.apply(this, [ "fetch" ].concat(makeArray(arguments))))
    
    toJSON: ->
      @recordsValues()
    
    fromJSON: (objects) ->
      return  unless objects
      objects = JSON.parse(objects)  if typeof objects == "string"
      if isArray(objects)
        results = []
        i = 0
        
        while i < objects.length
          results.push @init(objects[i])
          i++
        results
      else
        @init objects
    
    recordsValues: ->
      result = []
      for key of @records
        result.push @records[key]
      result
    
    cloneArray: (array) ->
      result = []
      i = 0
      
      while i < array.length
        result.push array[i].clone()
        i++
      result
  
  Model.include 
    model: true
    newRecord: true
    init: (atts) ->
      @load atts  if atts
      @trigger "init", this
    
    isNew: ->
      @newRecord
    
    isValid: ->
      not @validate()
    
    validate: ->
    
    load: (atts) ->
      for name of atts
        this[name] = atts[name]
    
    attributes: ->
      result = {}
      i = 0
      
      while i < @parent.attributes.length
        attr = @parent.attributes[i]
        result[attr] = this[attr]
        i++
      result.id = @id
      result
    
    eql: (rec) ->
      rec and rec.id == @id and rec.parent == @parent
    
    save: ->
      error = @validate()
      if error
        @trigger "error", this, error
        return false
      @trigger "beforeSave", this
      (if @newRecord then @create() else @update())
      @trigger "save", this
      this
    
    updateAttribute: (name, value) ->
      this[name] = value
      @save()
    
    updateAttributes: (atts) ->
      @load atts
      @save()
    
    destroy: ->
      @trigger "beforeDestroy", this
      delete @parent.records[@id]
      
      @destroyed = true
      @trigger "destroy", this
      @trigger "change", this, "destroy"
    
    dup: ->
      result = @parent.init(@attributes())
      result.newRecord = @newRecord
      result
    
    clone: ->
      Object.create this
    
    reload: ->
      return this  if @newRecord
      original = @parent.find(@id)
      @load original.attributes()
      original
    
    toJSON: ->
      @attributes()
    
    exists: ->
      @id and @id of @parent.records
    
    update: ->
      @trigger "beforeUpdate", this
      records = @parent.records
      records[@id].load @attributes()
      clone = records[@id].clone()
      @trigger "update", clone
      @trigger "change", clone, "update"
    
    create: ->
      @trigger "beforeCreate", this
      @id = Spine.guid()  unless @id
      @newRecord = false
      records = @parent.records
      records[@id] = @dup()
      clone = records[@id].clone()
      @trigger "create", clone
      @trigger "change", clone, "create"
    
    bind: (events, callback) ->
      @parent.bind events, @proxy((record) ->
        callback.apply this, arguments  if record and @eql(record)
      )
    
    trigger: ->
      @parent.trigger.apply @parent, arguments
  
  eventSplitter = /^(\w+)\s*(.*)$/
  Controller = Spine.Controller = Class.create(
    tag: "div"
    initialize: (options) ->
      @options = options
      for key of @options
        this[key] = @options[key]
      @el = document.createElement(@tag)  unless @el
      @el = $(@el)
      @events = @parent.events  unless @events
      @elements = @parent.elements  unless @elements
      @delegateEvents()  if @events
      @refreshElements()  if @elements
      @proxyAll.apply this, @proxied  if @proxied
    
    $: (selector) ->
      $ selector, @el
    
    delegateEvents: ->
      for key of @events
        methodName = @events[key]
        method = @proxy(this[methodName])
        match = key.match(eventSplitter)
        eventName = match[1]
        selector = match[2]
        if selector == ""
          @el.bind eventName, method
        else
          @el.delegate selector, eventName, method
    
    refreshElements: ->
      for key of @elements
        this[@elements[key]] = @$(key)
    
    delay: (func, timeout) ->
      setTimeout @proxy(func), timeout or 0
  )
  Controller.include Events
  Controller.include Log
  Spine.App = Class.create()
  Spine.App.extend Events
  Controller.fn.App = Spine.App
)()

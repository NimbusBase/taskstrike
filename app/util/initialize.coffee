#initialization function upon the first time launching the app.
current_verion = "2.1"

window.initializeApp = ->
  
  #this bridges the gap between localstorage and websql
  if Initialized.all().length == 0 and localStorage["Initialized"]?
    #read the local versions of previous models
    model_list = [ Task, Deletion, List, Token, Finished, Initialized, Version, BackgroundImage ]
    
    #for each of the model, read the stuff into memory via refresh
    for model in model_list
      result = localStorage[model.name]
      if result?
        result = JSON.parse(result)
        model.refresh result
        
        for m in model.all()
          m.save()
    
    #reset the version
    new_version = Version.first()
    new_version.number = current_verion
    new_version.save()  
  
  if Initialized.all().length == 0
    
    window.first_time = true
    
    new_version = Version.init(number: current_verion)
    new_version.save()
    set_init = Initialized.init(flag: "true")
    set_init.save()
    newlist = List.init(
      name: "Your Todos"
      description: ""
      time: moment().toString()
      synced: false
      google_id: "@default"
    )
    
    newlist.save()
    new_task = Task.init(
      name: "Click on settings and link your Dropbox account"
      time: moment().toString()
      done: false
      order: 0
      synced: false
      listid: newlist.id
    )
    new_task.save()
    new_task_2 = Task.init(
      name: "Click on the sync button on the bottom left to sync"
      time: moment().toString()
      done: false
      order:  1
      synced: false
      listid: newlist.id
    )
    new_task_2.save()
    
    #initialize the token that will save the authenticated stuff
    new_token = Token.init(
      current_token: ""
      expiration: ""
      refresh_token: ""
    )
    new_token.save()

    #initialize the background image that will save the background image
    new_back = BackgroundImage.init( "image": "" )
    new_back.save()
   
  if Version.first().number is "0.2"
    
    #initialize the token that will save the authenticated stuff
    new_token = Token.init(
      current_token: ""
      expiration: ""
      refresh_token: ""
    )
    new_token.save()

    #initialize the background image that will save the background image
    new_back = BackgroundImage.init( "image": "" )
    new_back.save()

    new_version = Version.first()
    new_version.number = current_verion
    new_version.save()
    
#this is the code that initializes the app in the beginning of each run, included
#add list and edit list windows
#setup for hotkey mapping to keys
#calendars
#toggle for the tabs for calendar and task view

setting_url = ""
window.last_opened = ""
window.cur = 0
window.taskdict = {}
window.obj = null
window.all_syncing = false

window.render_after_sync = () ->  
  for tasklist in List.all()
    #assign order to pulled downed parent_id list
    window.assign_order ( Task.list( tasklist.id ).sort(Task.ordersort) )
    
    if $("#"+tasklist.id).length > 0
      window.currently_syncing = true #don't fire off the cloud updates during rendering triggers
      List.find(tasklist.id).save()
      window.currently_syncing = false
    else
      window.App.render_new List.find(tasklist.id)

  #window.all_syncing = false

  #window.userapp.addAll()

window.sync_everything = () ->
  create("sticky", {"title":"Syncing", "text":"Pulling down data from the cloud"})
  
  List.sync_all ()->
    User.sync_all ()->
      Task.sync_all ()->
        
        #check if there is a list and task, initialize if there isn't
        if List.all().length is 0 and Task.all().length is 0
          a = List.create("name":"Your first list")
          
          new_task = Task.create(name: "Double click to edit a task", listid: a.id, done: false)
          new_task = Task.create(name: "Click on the button at the bottom and add the new task in the input, hit return to save", listid: a.id, done: false)
          new_task = Task.create(name: "Select a task and press tab to create a subtask", listid: a.id, done: false)
          new_task = Task.create(name: "Go to the setting menu to share this with your friends, only works with Google Drive", listid: a.id, done: false)
          
          #window.first_time = true
          
        window.render_after_sync()
        #initialize users view in the setting
        window.render_current_user(window.render_user)
        
        window.get_space()
        
        window.create("sticky", {"title":"Syncing", "text":"Sync complete!"})

        window.reset = true

#switch workspace 
window.switch_workspace = (id)->
  create("sticky", {"title":"Switching workspace", "text":"In progress"})
  
  Nimbus.Client.GDrive.switch_to_app_folder(id, ()->
    #empty out taskså and other stuff
    $("#listsoftasks").html("")
    $(".listfilter").html("")
    $(".listfilter").append('<span class="divider"></span>')
    $(".listfilter").append('<button class="filterselected" onclick="show_all_div()" id="allbutton">all</button>')
    
    
    create("sticky", {"title":"Switching workspace", "text":"Done"})
    window.sync_everything()
  )
  
#this the function that starts everything in motion once data is loaded from web_sql
window.big_bang = () ->
  
  console.log("### BIG BANG CALLED")
  
  #initializeApp() #probably don't need this
  
  jQuery ($) ->
    
    #set background image
    #if BackgroundImage.first()? and BackgroundImage.first().image isnt ""
    #  $("#bghelp")[0].style.background = 'url(' + BackgroundImage.first().image + ') no-repeat center'
    
    $("#listsoftasks").html("")
    
    $("#newtaskdate").datepicker 
      constrainInput: true
      buttonImage: "famfamicons/calendar.png"
      buttonImageOnly: true
      buttonText: ""
      showOn: "both"
      onSelect: (dateText, inst) ->
        $(this).parent().parent().find(".showdate").html dateText  if $(this).parent().parent().find(".showdate").length == 1
    
    window.container = $("#container").notify()
    #$("#calendar").fullCalendar events: window.rendering_cal_process
    #$("#calendarview").hide()
    updateItems()
    
    #shortcuts
    shortcut.add "up", prevItem, disable_in_input: "true"
    shortcut.add "down", nextItem, disable_in_input: "true"
    shortcut.add "tab", make_child, disable_in_input: "true"
    shortcut.add "shift+tab", untab, disable_in_input: "true"
    shortcut.add "enter", open_for_edit
    shortcut.add "backspace", pressed_delete, disable_in_input: "true"
    shortcut.add "delete", pressed_delete, disable_in_input: "true"
    
    #start the apps
    #window.settingapp = SettingApp.init(el: "#theapp")
    window.App = allLists.init()  
    #window.userapp = UserApp.init(el: "#people_view")
    #window.legend = UserLegendApp.init()
    #window.legend.addAll()
    
    #hide all other tabs initially
    $(".app_tab:not(#views)").hide()
    
    #initialize the calendar
    $("#dialog_task_startdate").datepicker 
      beforeShow: ()->
        $('#ui-datepicker-div').css('z-index', 2005)
      constrainInput: true
    $("#dialog_task_enddate").datepicker constrainInput: true
    
    #initialize_gantt()
    #initialize_dropbox()
    #initialize_autosync()
    
    #if window.dropbox? and window.dropbox.accessTokenSecret?
    #  window.initialize_and_sync_list()
    List.sync_all ()->
      User.sync_all ()->
        Task.sync_all ()->
          
          #check if there is a list and task, initialize if there isn't
          if List.all().length is 0 and Task.all().length is 0
            a = List.create("name":"Your first list")
            
            new_task = Task.create(name: "Double click to edit a task", listid: a.id, done: false)
            new_task = Task.create(name: "Click on the button at the bottom and add the new task in the input, hit return to save", listid: a.id, done: false)
            new_task = Task.create(name: "Select a task and press tab to create a subtask", listid: a.id, done: false)
            new_task = Task.create(name: "Go to the setting menu to share this with your friends, only works with Google Drive", listid: a.id, done: false)
            
            #window.first_time = true
            
          window.render_after_sync()
          #initialize users view in the setting
          window.render_current_user(window.render_user)
          
          window.get_space()
    
          
    #setTimeout("window.initialize_autosync()", 60000)
    setTimeout("$('#loading').fadeOut()", 3000)

    #open tour if this is the first time
    #if window.first_time
    #  $(this).joyride()

#document styling 
$(document).ready ->
  $("body").layout
    applyDefaultStyles: false
    south:
      resizable: false
      spacing_open: 0

    west:
      resizable: false
      spacing_open: 0

Nimbus.Auth.set_app_ready big_bang


window.create = (template, vars, opts) ->
  window.container.notify "create", template, vars, opts

#for the add list window

window.addlist_window = ->
  $("#list_name").val ""
  $("#list_description").val ""
  $("#dialog_addlist").dialog 
    modal: true
    title: "Add A New List"
    dialogClass: "adding"
    buttons:
      'Add List': () ->
        add_list()
        $(this).dialog("close")

window.add_list = ->
  name = $("#list_name").val()
  description = $("#list_description").val()
  
  newlist = List.create(  
    name: name
    description: description
  )
  
  ###
  newlist = List.init(
    name: name
    description: description
    time: moment().toString()
    synced: true
  )
  newlist.save()
  ###
  
  window.App.render_new newlist
  $("#dialog_addlist").dialog "close"

window.edit_list = ->
  curr_list = List.find($("#dialog_addlist").data("id"))
  curr_list.name = $("#list_name").val()
  curr_list.description = $("#list_description").val()
  curr_list.time = moment().toString()
  curr_list.save()
  
  $("#dialog_addlist").dialog "close"

#for the edit task window
window.edit_task = ()->
  $("#dialog_task").dialog
    modal: true
    title: "Edit Task"
    dialogClass: "adding"
    buttons:
      'Save Task': () ->
        alert "save task called"
        $(this).dialog("close")

#for calendar
window.toggle = (tabSelector, elementSelector, activeElement, activeTab) ->
  $(tabSelector).not(activeTab).removeClass "selected"
  $(activeTab).addClass "selected"
  $(elementSelector).not(activeElement).hide()
  $(activeElement).show()
  $("#sidebar_dark").attr("class", activeElement.replace("#", ""))
  
  if activeElement is '#calendarview'
    $("#calendar").fullCalendar "refetchEvents"
    $("#calendar").fullCalendar "windowResize"
  
  #if activeElement is '#gantt_view'
  #  window.initialize_gantt()

  #fixes the error where sync happens when a view is not displaying, and shit gets fucked up
  #if activeElement is "#views"
  #  for list in List.all()
  #    list.save()
  
  if window.reset and activeElement is "#views"
    window.reset = false
    for list in List.all()
      list.save()  

window.show_all_div = ->
  $(".listdiv").show()
  $(".filterselected").removeClass "filterselected"
  $("#allbutton").addClass "filterselected"

#show or hide progress based on if there is a user assigned
window.hide_based_on_user = () ->
  if $("#dialog_task_user_id").val() == ""
    $("#dialog_task_status_row").hide()
  else
    $("#dialog_task_status_row").show()  

waitForFinalEvent = (->
  timers = {}
  (callback, ms, uniqueId) ->
    uniqueId = "Don't call this twice without a uniqueId"  unless uniqueId
    clearTimeout timers[uniqueId]  if timers[uniqueId]
    timers[uniqueId] = setTimeout(callback, ms)
)()

#$(window).resize ->
#  waitForFinalEvent (->
#    window.initialize_gantt()
#  ), 100, "fsdf asdfadf"

window.open_help = ()->
  
  if $("#sidebar_dark").hasClass("views") or $("#views_tab").hasClass("selected")
    $("#dialog_help").dialog({ modal: true, title: 'Task View' })
  else if $("#sidebar_dark").hasClass("gantt_view")
    $("#dialog_help_gantt").dialog({ modal: true, title: 'Gantt View' })
  else if $("#sidebar_dark").hasClass("people_view")
    $("#dialog_help_people").dialog({ modal: true, title: 'People View' })
  else
    log("no help availible")

#event for hiding the progress bar on the loading menu and showing the display bar
window.loading = ()->
  log("ANIMATION Called")
  if not Nimbus.Auth.authorized()
    $("#progress").hide()
    $("#login_buttons").fadeIn()
    $("#logo_text").fadeIn()
  
window.setTimeout("window.loading()",3000)

#function for logging out
window.logout = () ->
  Nimbus.Auth.logout()
  $("#loading").show()
    
  $("#progress").hide()
  $("#login_buttons").fadeIn()
  $("#logo_text").fadeIn()
   
#function for opening screencast
window.screencast = ()->
  $("#dialog_screencast").dialog
    modal: true
    title: "Screencast"
    width: "666"
    zIndex: 10010


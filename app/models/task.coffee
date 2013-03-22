Finished = Nimbus.Model.setup("Finished", [ "name", "done", "time", "duedate", "note", "order", "synced", "listid", "time_finished" ])

Deletion = Nimbus.Model.setup("Deletion", [ "deletion_id", "listid" ])

#status (In progress or not started)
#start date, date it was marked started
#end date, date it was marked ended

Task = Nimbus.Model.setup("Task", [ "name", "done", "time", "duedate", "note", "order", "listid", "parent_id", "level", "userid", "status", "start_date", "end_date", "synced", "priority"]) #nestlevel from 0 to whatever
Task.extend 

  PreviousCache: {}
  DeletionStorage: Deletion

  active: (id) ->
    @select (item) ->
      not item.done and (item.listid == id)
  
  done: (id) ->
    @select (item) ->
      not not item.done and (item.listid == id)
  
  list: (id) ->
    @select (item) ->
      item.listid == id
  
  print_by_order: () ->
    for list in List.all()
      console.log( list.name, list.id )
      ordered = Task.list( list.id ).sort(Task.ordersort)
      for task in ordered 
        console.log( task.order, task.name, task.id, task.level, task.parent_id )
  
  find_larger_than_order_in_list: (order, list, level) ->
    @select (item) ->
      item.listid is list and item.level is level and item.order > order
  
  find_task_by_parent_id: ( search_id ) ->
    @select (item) ->
      item.parent_id is search_id
  
  synced: () ->
    @select (item) ->
      not item.synced or not item.updated
  
  destroyDone: (id) ->
    @done(id).forEach (rec) ->
      Deletion.create deletion_id: rec.id  if rec.synced == true
      rec.destroy()
  
  logDone: ( id ) ->
    @done(id).forEach (rec) ->
      Finished.create 
        name: rec.name
        note: rec.note
        listid: rec.listid
        time_finished: moment().format('MM/DD/YYYY')
      rec.destroy()

  find_by_user: (id) ->
    @select (item) ->
      item.userid is id   

  find_by_content: (content) ->
    @select (item) ->
      item.name is content

  #saves the current order of the list when it gets changed through deletion or drag and drop
  save_current_order_of_list: (list) ->
    window.currently_syncing = true
    for task in Task.list( list )
      if task.order isnt window.taskdict[task.id].el.index()
        task.order = window.taskdict[task.id].el.index()
        task.save()
    window.currently_syncing = false

  #sort function
  #Takes a field, and sorts everything by that field
  list_sort_by: ( listid, field_name, ascend_descend ) ->
    if ascend_descend #true is decending
      fieldsort = (a, b) ->
        x = if a[field_name]? then a[field_name] else 0
        y = if b[field_name]? then b[field_name] else 0
        
        (if ( x > y ) then -1 else 1)
    else
      fieldsort = (a, b) ->
        x = if a[field_name]? then a[field_name] else 0
        y = if b[field_name]? then b[field_name] else 0
        
        (if (x < y) then -1 else 1)
    
    sorted = Task.list( listid ).sort(fieldsort)
    
    #redo the order based on your sort
    counter = 0
    for a in sorted
      a.order = counter 
      a.save()
      counter = counter + 1

Task.ordersort = (a, b) ->
  (if (a.order < b.order) then -1 else 1)

List = Nimbus.Model.setup("List", [ "name", "description", "time", "updated", "google_id", "synced" ])
List.extend
    
  PrintAll: ()->
    for i in List.all()
      console.log(i.name, i.id, i.google_id)


Version = Spine.Model.setup("Version", [ "number" ])
Version.extend Spine.Model.Local
Initialized = Spine.Model.setup("Initialized", [ "flag" ])
Initialized.extend Spine.Model.Local

TestStorage = Spine.Model.setup("TestStorage", [ "stored" ])
TestStorage.extend Spine.Model.Local

BackgroundImage = Spine.Model.setup("BackgroundImage", [ "image" ])
BackgroundImage.extend Spine.Model.Local

User = Nimbus.Model.setup("User", [ "name", "role", "color", "pic"])

Comments = Nimbus.Model.setup("Comments", ["comment", "userid", "timestamp"])

exports = this
exports.Task = Task
exports.List = List
exports.Version = Version
exports.Initialized = Initialized
exports.Finished = Finished
exports.BackgroundImage = BackgroundImage
exports.User = User
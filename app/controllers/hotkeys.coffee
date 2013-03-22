#the list of functions activiated by hotkeys

nextItem = ->
  if $("textarea:focus").length == 0 and $("input:focus").length == 0
    if cur < ($("li").length - 1)
      window.cur++
    else
      window.cur = 0
    updateItems()
  true
  
prevItem = ->
  if $("textarea:focus").length == 0 and $("input:focus").length == 0
    if cur > 0
      window.cur--
    else
      window.cur = $("li").length - 1
    updateItems()
  true

updateItems = ->
  $("li.task_selected").removeClass "task_selected"
  $("li:eq(" + cur + ")").addClass "task_selected"

open_for_edit = (e)->
  
  if e.target.className isnt 'addtasks'
    if $("#dialog_task").dialog( "isOpen" ) is true
      $("#dialog_task_save_btn").click()
    else
      task_controller = window.taskdict[$(".task_selected").data("id")]
      task_controller.edit()
      true
  
  else
    $(e.target).parent().submit()
    

pressed_delete = ->
  r = confirm("Are you sure you want to delete this task?")
  if $("textarea:focus").length == 0 and $("input:focus").length == 0
    if r
      current = Task.find($(".task_selected").data("id"))
      task_controller = window.taskdict[$(".task_selected").data("id")]
      task_controller.destroy()

make_child = ()->
  if $("textarea:focus").length == 0 and $("input:focus").length == 0
    current = Task.find($(".task_selected").data("id"))
    task_controller = window.taskdict[$(".task_selected").data("id")]
  
    #A. check if the list is the first of the list if it is, it cannot be made into a child
    if task_controller.el.index() is 0
      alert "The first task cannot be made into a child"
      return
    else
      #if the parent is one up then you can't tab
      if ( current.parent_id? and current.parent_id isnt "") and Task.find(current.parent_id).order is (current.order-1)
        return
      else
        #dumb algorithm which only tabs and change the current element's level and submit the entire list to be re-orged    
        current.level = 0 if not current.level?
        current.level = Number(current.level)+1
        current.time = moment().toString()
        current.save()
        
        #assign parents
        window.assign_parents( Task.list(current.listid) )
        $(task_controller.el).find(".item").addClass("child_"+current.level) #force add the level on new tasks, should just be alright on re-render but it's not
  true

#need recursively pull up all the children
recurse_through_children = (parent) -> 
  children = Task.find_task_by_parent_id( parent )
  log("CHILDREN", children)
  for child in children
    child.level = child.level-1
    child.time = moment().toString()
    child.save()
    recurse_through_children(child.id)
        
untab = () ->
  if $("textarea:focus").length == 0 and $("input:focus").length == 0
    current = Task.find($(".task_selected").data("id"))
    task_controller = window.taskdict[$(".task_selected").data("id")] 
    
    #check if this level 0, if it is just return
    if current.level is 0 or not current.level?
      return
    else
      window.currently_syncing = true
    
      #update the current one to be one level less
      current.level = current.level-1
      current.time = moment().toString()
      current.save()
      
      #update the his children to be one level higher
      recurse_through_children( current.id )
      
      window.currently_syncing = false
      
      #call the parent-id reassignment agency
      window.assign_parents( Task.list(current.listid) )
      $(task_controller.el).find(".item").addClass("child_"+current.level) #force add the level on new tasks, should just be alright on re-render but it's not
  true

#export this shit
exports = this
this.nextItem = nextItem
this.prevItem = prevItem
this.updateItems = updateItems
this.open_for_edit = open_for_edit
this.pressed_delete = pressed_delete
this.make_child = make_child
this.untab = untab
#two functions here that basically re-orders subtasks upon on any actions.
#one assigns the parents give levels
#one assign levels give parents

#given a list of tasks and levels, assign parent_ids
#input: a list of tasks with orders that are consecutive with the same list id; assume this to be a list
#output: a list of tasks with their parent ids assigned
#called: on tab, untab, and drag and drop
window.assign_parents= (tasks) ->
  #console.log(tasks)

  #loop through the tasks, keep track of the latest task in each level
  #When you go to a new task, check if it's parent_id is the latest task in that level
  #if not, change it to the one you kept
  tracker = {}
  modified = [] #the ids that are modified, keep track of this so we know what to modify
  
  tasks = tasks.sort(Task.ordersort)
  
  for task in tasks
    log( "order", task.name )
    
    #if it's level zero, don't try it assign it a parent, just put it in the tracker
    if not task.level? or Number( task.level ) is 0
      tracker[0] = task.id
      task.level = 0
      if task.parent_id isnt ""
        task.parent_id = ""
        task.save()
      else
        log("no change really")
        window.currently_syncing = true
        task.save()
        window.currently_syncing = false
      
      modified.push( task.id )
    else
      console.log("tried to assign", task.name)
      
      #the case where it's the first one
      if task.order is 0
        task.level = 0
        window.currently_syncing = true
        task.save()
        window.currently_syncing = false
        break;
      
      #update tracker
      tracker[Number(task.level)] = task.id
           
      #find the latest parent for the current task
      previous_level = Number(task.level)-1
      latest_parent = tracker[previous_level]
      
      if latest_parent isnt task.parent_id
        task.parent_id = latest_parent
        task.time = moment().toString()
        task.save() #comment out when debugging
        
        modified.push( task.id )

  return modified      
  
  #return tasks # comment out when not testings

#write some tests  
###
#test 1, two level 0', nothing happens
a = id:"one", level:"0"
b = id:"two", level:"0"

window.test_array_1 = [ a, b ]

#test 2, one level 0, one level 1, result should be the first is the parent of the second
c = id:"one", level:"0"
d = id:"two", level:"1"

window.test_array_2 = [ c, d ]

#test 3, level 0, 1, 2, results should be a chain of parents
e = id:"one", level:"0"
f = id:"two", level:"1"
g = id:"three", level:"2"

window.test_array_3 = [ e, f, g ]

#test 4, level 0, 0, 1, result N N 2
h = id:"one", level:"0"
i = id:"two", level:"0"
j = id:"three", level:"1"

window.test_array_4 = [ h, i, j ]

###
window.counter = 0
window.bypass= {}
window.parent= {}

#a recusive function that assigns level and order to it's children
window.assign_children = ( parent, childs, parent_dict ) ->
  for child in parent_dict[parent.id]
    child.order = window.counter
    child.level = parent.level+1
    child.save()
    window.counter = window.counter+1
    #console.log( "child", child.name )
    
    if parent_dict[child.id]?
      window.assign_children( child, parent_dict[child.id], parent_dict  )

#given a set of tasks with parent_ids, assign orders to them
#assume they are all in the same list
window.assign_order = (tasks) ->
  window.counter = 0
  window.parent = {}
  
  window.currently_syncing = true
  
  log( tasks )
  
  tasks = tasks.sort(Task.ordersort)
  
  log("Assign Order tasks", tasks)
  
  #process the list for children to create a { parent_id: children } dictionary
  for task in tasks
    if task.parent_id?
      if window.parent[task.parent_id]?
        (window.parent[task.parent_id]).push( task)
      else 
        window.parent[task.parent_id] = [ task ]
  
  log("parent div", window.parent)
  
  for task in tasks
    #if it has a kid entry, put the kid entry after it
    if window.parent[task.id]? and ( (task.parent_id is null) or (task.parent_id is "") or (task.parent_id is undefined) )# make sure it's not a bypass and not a child
      #log( "#root parent: ", task.name )      
      task.order = window.counter
      task.level = 0
      task.save()
      window.counter = window.counter + 1
      
      window.assign_children(task, parent[task.id], parent)
    #if it has no kid, add the order and let it go 
    else if task.parent_id? and task.parent_id isnt ""
      log(task.name, " already assigned or going to be assigned")
    else
      #log(task.name, " parent and childliess")
      task.order = window.counter
      task.level = 0
      task.save()
      window.counter = window.counter + 1
  
  window.currently_syncing = false
  
###
#test that the parent mapping works
l = List.init( id: "thelist", name: "thelist" )
l.save()
a = Task.init( id:"one", order: 1, listid: "thelist" )
a.save()
b = Task.init( id:"two", parent_id:"one", order: 2, listid: "thelist" )
b.save()
c = Task.init( id:"three", parent_id:"one", order: 3, listid: "thelist" )
c.save()

window.test_array_i = [a, b, c]
###
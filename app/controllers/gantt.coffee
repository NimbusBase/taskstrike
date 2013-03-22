window.gantt_callback = (data) ->
  log("gantt data: ", data)
  
  current = Task.find_by_content(data.name)[0]
  current.start_date = moment(data.start).format("M/D/YY")
  current.end_date = moment(data.end).format("M/D/YY")
  current.save()

window.create_gantt_data = ()->
  counter = 1
  
  gantt_data = []
  
  for user in User.all()
    all_tasks = Task.find_by_user(user.id)
    if all_tasks.length > 0
      d = id: counter, name: user.name
      
      series = []
      
      for task in all_tasks
        e = 
          name: task.name
          start: if task.start_date? and not isNaN( new Date(task.start_date) ) then new Date(task.start_date) else new Date()
          end: if task.end_date? and not isNaN( new Date(task.end_date) ) then new Date(task.end_date) else new Date() 
        series.push(e)
      
      d["series"] = series
      
      gantt_data.push( d )
      
      counter = counter + 1
  
  window.gantt_data = gantt_data
  
  u = id: counter, name: 'Unassigned'
  series = []
  for task in Task.all()  
    if not task.userid? or task.userid is ""
      e = 
          name: task.name
          start: if task.start_date? and not isNaN( new Date(task.start_date) ) then new Date(task.start_date) else new Date()
          end: if task.end_date? and not isNaN( new Date(task.end_date) ) then new Date(task.end_date) else new Date() 
      series.push(e)
  
  u["series"] = series
  gantt_data.push( u )

  gantt_data

window.create_gantt_data_by_list = ()->
  
  gantt_data = []
  
  for list in List.all()
    tasks = Task.list(list.id).sort(Task.ordersort)
    
    u = id: list.id, name: list.name
    
    series = []
    
    for task in tasks
      e = 
          name: task.name
          start: if task.start_date? and not isNaN( new Date(task.start_date) ) then new Date(task.start_date) else new Date()
          end: if task.end_date? and not isNaN( new Date(task.end_date) ) then new Date(task.end_date) else new Date() 
          id: task.id
          
      e.color = User.find(task.userid).color if task.userid? and User.exists(task.userid)
      series.push(e)
    
    u["series"] = series
    gantt_data.push( u )
    
  gantt_data

window.gantt_click = (data) ->
  log(data)
  task_controller = window.taskdict[data.id]
  task_controller.edit()

window.initialize_gantt = () ->
  slideWidth = $("#gantt_view").outerWidth() - 240 - 31
    
  $("#gantt_chart").html("")
  
  gantt_data = create_gantt_data_by_list()
  
  $("#gantt_chart").ganttView("rerender", {
      data: gantt_data,
      slideWidth: slideWidth,
      behavior: {
        onClick: gantt_click,
        onDrag: gantt_callback,
        onResize: gantt_callback
      }
    })
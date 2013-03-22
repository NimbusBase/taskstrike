#function relating to the calendar view for the app

window.rendering_cal = ->
  dated_tasks = Task.select((item) ->
    item.duedate != undefined
  )
  calendar_input = []
  $.each dated_tasks, (index, value) ->
    calendar_input.push 
      title: value.name
      start: new Date(value.duedate)
  
  $("#calendar").fullCalendar "renderEvent", calendar_input, false
  
window.rendering_cal_process = (start, end, callback) ->
  dated_tasks = Task.select((item) ->
    item.duedate != undefined
  )
  finished_tasks = Finished.all()
  
  calendar_input = []
  $.each dated_tasks, (index, value) ->
    calendar_input.push 
      title: value.name
      start: new Date(value.duedate)
      className: "current_task"
        
  for f in finished_tasks
    calendar_input.push
      title: f.name
      start: new Date(f.time_finished)
      className: "finished_task"
  
  $("#calendar").fullCalendar "renderEvent", calendar_input, false
  
  callback calendar_input 

#this file has a function that sends all js error to a global form that is hosted on google docs

window.myErrorHandler = (errorMsg, url, lineNumber) ->
  total_message = errorMsg + " " + url + " " + lineNumber + " "
  total_message = encodeURIComponent(total_message)
  
  user_agent = encodeURIComponent( navigator.userAgent )
  
  log( total_message, user_agent, Error().stack )

  error_stack = Error().stack

  #setup xhr
  xhr = new XMLHttpRequest()
  xhr.open("POST", "https://docs.google.com/spreadsheet/formResponse")
  xhr.setRequestHeader("Content-Type","application/x-www-form-urlencoded")
  xhr.onreadystatechange = (status, response) ->
  if xhr.readyState is 4
    window.obj = $.parseJSON(window.xhr.response)
  
  #setup submit data
  submit_data = "formkey=dG1JRkR0S3hsZFVLQU4tNU9ueUhTQVE6MQ&entry.0.single=#{ total_message }&entry.1.single=#{ user_agent }&entry.2.single=#{ error_stack }&hl=en_US"
  #console.log( submit_data )
  xhr.send( submit_data )

window.onerror = window.myErrorHandler

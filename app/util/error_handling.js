// Generated by CoffeeScript 1.6.2
(function() {
  window.myErrorHandler = function(errorMsg, url, lineNumber) {
    var error_stack, submit_data, total_message, user_agent, xhr;

    total_message = errorMsg + " " + url + " " + lineNumber + " ";
    total_message = encodeURIComponent(total_message);
    user_agent = encodeURIComponent(navigator.userAgent);
    log(total_message, user_agent, Error().stack);
    error_stack = Error().stack;
    xhr = new XMLHttpRequest();
    xhr.open("POST", "https://docs.google.com/spreadsheet/formResponse");
    xhr.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
    xhr.onreadystatechange = function(status, response) {};
    if (xhr.readyState === 4) {
      window.obj = $.parseJSON(window.xhr.response);
    }
    submit_data = "formkey=dG1JRkR0S3hsZFVLQU4tNU9ueUhTQVE6MQ&entry.0.single=" + total_message + "&entry.1.single=" + user_agent + "&entry.2.single=" + error_stack + "&hl=en_US";
    return xhr.send(submit_data);
  };

  window.onerror = window.myErrorHandler;

}).call(this);

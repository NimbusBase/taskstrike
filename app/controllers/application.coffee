jQuery ($) ->
  window.Tasks = Spine.Controller.create(
    tag: "li"
    proxied: [ "render", "remove", "delete_userid", "save_order_of_list"]
    events: 
      "change   input[type=checkbox]": "toggle"
      "click    .destroy": "destroy"
      "dblclick .item": "edit"
      "click .item": "toggle_select"
      "keypress input[type=text]": "blurOnEnter"
    
    elements: 
      "input.name": "input"
      ".item": "wrapper"
      ".duedate_field": "inputdate"
      "textarea.note": "textarea"
      ".user_selection": "user_selection"
      ".startdate": "start_date"
      ".enddate": "end_date"
    
    delete_userid: ->
      console.log(this)
      @item.userid = null
      @item.save()
      @render
    
    bind_user: ->
      #find the user item and bind to it's update and render to correctly render the colors etc.
      if @item.userid? and User.exists( @item.userid )
        @assignee = User.find(@item.userid)
        @assignee.bind "update", @render
        @assignee.bind "destroy", @delete_userid
        
    init: ->
      @item.bind "update", @save_order_of_list
      @item.bind "update", @render
      
      window.taskdict[@item.id] = this
      
      @item.bind "destroy", @remove
 
      @bind_user()
    
    save_order_of_list: ->  
      log("SAVE ORDER OF LIST")
      
      if window.currently_syncing #prevent cascading calls
        return true
      
      previous = @item
      record = Task.find(@item.id)
      diff = Task.diff_objects(previous, record)
      
      log(record)
      log("DIFF", diff)
        
      if diff["listid"]? #if listid changed, moving it and parent id doesn't even matter
        log("changed list id")
                 
        #take care of the order
        Task.save_current_order_of_list( record.listid )
        Task.save_current_order_of_list( previous.listid )
        
        #also take care of the subtasks stuff
        window.assign_parents( Task.list( record.listid ).sort(Task.ordersort) )
        window.assign_parents( Task.list( previous.listid ).sort(Task.ordersort) )
      else
        if diff["order"] or diff["parent"] #only call re-org if order or parents have changed
           log("calling assign parents")
          Task.save_current_order_of_list( record.listid )
          window.assign_parents( Task.list( record.listid ).sort(Task.ordersort) )
    
    render: ->
      @item = Task.find(@item.id)
      elements = $("#taskTemplate").tmpl( @item )
      @el.html elements
      @refreshElements()
      @el.data "id", @item.id
      #@el.find(".datepicker").datepicker constrainInput: true
      this
    
    toggle: ->
      @item = Task.find(@item.id)
      @item.done = not @item.done
      @item.time = moment().toString()
      @item.save()
    
    destroy: ->
      @item.destroy()
    
    edit: ->
      $("#dialog_task_name").val( @item.name )
      $("#dialog_task_note").val( @item.note )
      $("#dialog_task_status").val( @item.status )
      $("#dialog_task_startdate").val( @item.start_date ) if @item.start_date?
      $("#dialog_task_enddate").val( @item.end_date ) if @item.end_date?
      
      if @item.priority?
        $("#dialog_task_priority").val( @item.priority )
      else
        $("#dialog_task_priority").val( "0" )
      
      window.hide_based_on_user()
      
      $("#dialog_task").dialog
        modal: true
        title: "Edit Task"
        dialogClass: "adding"
        buttons: [{
          text: 'Save Task',
          id: 'dialog_task_save_btn', 
          click: () =>
            
            $("#dialog_task_name").blur()
            $("#dialog_task_note").blur()
            
            $("#dialog_task").dialog("close")  
                          
            @item.updateAttributes 
              name: $("#dialog_task_name").val()
              time: moment().toString()
              note:  $("#dialog_task_note").val()
              userid:  $("#dialog_task_user_id").val()
              start_date: $("#dialog_task_startdate").val()
              end_date: $("#dialog_task_enddate").val()
              status: $("#dialog_task_status").val()
              priority: $("#dialog_task_priority").val() 
              
            #$(".task_selected").removeClass("task_selected")
            if $(".selected").attr("id") is "views_tab"
              @el.addClass("task_selected")
            
            #complicated way to assign index
            element = @el
            $("li").each (idx, value ) -> 
              if $(value).data("id") is $( element ).data("id")
                window.cur = idx
            
            window.last_opened = ""
              
            @bind_user() 
            #initialize_gantt()
          }]
                  
        beforeClose: ()->
          $("#dialog_task_name").blur()
          $("#dialog_task_note").blur()
        
        open: ()=>
          $('#dialog_task_user_id').html("")
          $('#dialog_task_user_id').append("<option value=''></option>")
          
          for user in User.all()
              $('#dialog_task_user_id').append("<option value='#{ user.id }'>#{ user.name }</option>")
              
          $("#dialog_task_user_id").val( @item.userid )
          
          window.hide_based_on_user()
      
      $("#dialog_task_name").focus()
      
      ###
      if @wrapper.hasClass "editing"
        return
      
      if @el.hasClass "task_selected"
        @el.removeClass "task_selected"
      
      if window.last_opened isnt ""
        window.taskdict[window.last_opened].close()
      window.last_opened = @item.id
      
      @wrapper.addClass "editing"
      @input.focus()
      
      user = @user_selection
      
      $.each User.all(), (key, value) ->
        user.append('<option value="'+value.id+'">'+value.name+'</option>')
      
      $( @user_selection ).val(@item.userid)
      ###
    
    blurOnEnter: (e) ->
      e.target.blur()  if e.keyCode == 13

    toggle_select: ->
     if @wrapper.hasClass "editing"
        return
     
     if window.last_opened isnt ""
        window.taskdict[window.last_opened].close()
     window.last_opened = ""
     
     $(".task_selected").removeClass("task_selected")
     
     #complicated way to assign index
     element = @el
     $("li").each (idx, value ) -> 
        if $(value).data("id") is $( element ).data("id")
          window.cur = idx 

     @el.addClass "task_selected"
    
    remove: ->
      record = @item
      
      log("removing record", record)
      
      #if it's the first one in the list, make it's children untab and go up a level
      if record.order is 0
        for x in Task.find_task_by_parent_id( record.id )
          window.currently_syncing = true
          x.level = Number( x.level ) - 1
          x.save()
          window.currently_syncing = false
          
      #reset the parents for the deleted list
      Task.save_current_order_of_list( record.listid )
      window.assign_parents( Task.list( record.listid ).sort(Task.ordersort) )
      
      @el.remove()
  )
  window.TaskApp = Spine.Controller.create(
    tag: "div"
    proxied: [ "addAll", "render", "renderCount", "remove", "attach" ]
    events: 
      "click  .clear": "clear"
      "click  a.add": "addOne"
      "click  .deletelist": "deletelist"
      "click  .editlist": "editlist"
      "submit form.addform": "create_new"
      "click .peoplesort": "peoplesort"
      "click .startsort": "startsort"
      "click .endsort": "endsort"
      "click .statussort": "statussort"
      "click .prioritysort": "prioritysort"
    
    elements: 
      ".items": "items"
      ".countVal": "count"
      ".clear": "clear"
      ".add": "add"
      ".addinputs .addtasks": "input"
      ".addinputs": "addform"
    
    init: ->
      @item.bind "update", @render
      @item.bind "update", @attach
      @item.bind "destroy", @remove
      Task.bind "change", @renderCount
    
    sort: ()->
      alert("test")
    
    #a lot of different sort functions
    peoplesort: ()->
      Task.list_sort_by( @item.id, "userid", false )
      window.assign_order( Task.list( @item.id ) )
      
      #save to rerender
      List.find(@item.id).save()
    
    startsort: ()->
      Task.list_sort_by( @item.id, "start_date", false )
      window.assign_order( Task.list( @item.id ) )
      
      #save to rerender
      List.find(@item.id).save()

    endsort: ()->
      Task.list_sort_by( @item.id, "end_date", false )
      window.assign_order( Task.list( @item.id ) )

      #save to rerender
      List.find(@item.id).save()
    
    statussort: ()->
      Task.list_sort_by( @item.id, "status", true )
      window.assign_order( Task.list( @item.id ) )

      #save to rerender
      List.find(@item.id).save()
    
    prioritysort: ()->
      Task.list_sort_by( @item.id, "priority", true )
      window.assign_order( Task.list( @item.id ) )

      #save to rerender
      List.find(@item.id).save()
    
    #end sorts
    
    addAll: ->
      ordered = Task.list(@item.id).sort(Task.ordersort)
      a = @el
      $.each ordered, (key, value) ->
        view = Tasks.init(item: value)
        a.find(".items").append view.render().el
    
    render: ->
      @item = List.find(@item.id)
      elements = $("#listTemplate").tmpl(@item)
      @el.html elements
      @refreshElements()
      @el.data "id", @item.id
      @addAll()
      @el.addClass "firstlist"  if @item.id == "@default"
      @renderCount()
      
      tab_el = $(".listfilter")
      tab_id = "l" + (String(@item.id).replace("@", ""))
      $("#" + tab_id).remove()
      tab_html = "<button id='" + tab_id + "'>" + @item.name + "</button>"
      tab_el.prepend tab_html
      @tab = $(String("#" + tab_id))
      this_element = "#" + @item.id
      this_tab = @tab
      
      @tab.click ->
        $(".listdiv").hide()
        if this_element == "#@default"
          $(".firstlist .listdiv").show()
        else
          $(this_element).show()
        $(".filterselected").removeClass "filterselected"
        this_tab.addClass "filterselected"
      
      this
    
    renderCount: ->
      active = Task.active(@item.id).length
      @count.text active
      inactive = Task.done(@item.id).length
    
    clear: ->
      Task.logDone @item.id
    
    addOne: ->
      new_task = Task.create(
        name: ""
        time: moment().toString()
        done: false
        order: Task.all().length + 1
        synced: false
        listid: @item.id
        parent_id: ""
      )
      view = Tasks.init(item: new_task)
      @items.append view.render().el
      view.edit()
    
    deletelist: ->
      #r = confirm("Are you sure you want to delete this list and all it's tasks")
      current_item = @item
      
      $("#dialog_confirmdelete").dialog( 
        modal: true, 
        title: 'Delete the list' 
        buttons:
          'Yes': () ->
            $("#dialog_confirmdelete").dialog( "close")
            for task in Task.list(current_item.id)
              task.destroy()
            current_item.destroy()
            
          'No': () -> 
            $("#dialog_confirmdelete").dialog( "close")
      )
    
    create_new: ->
      input_value = @input.val().replace("'", "''")
      
      new_task = Task.create(
        name: input_value
        time: moment().toString()
        done: false
        order: Task.list( @item.id ).length+1
        listid: @item.id
        parent_id: ""
      )
      
      view = Tasks.init(item: new_task)
      @items.append view.render().el
      @input.val ""
      false
    
    remove: ->
      @el.remove()
      @tab.remove()
    
    editlist: ->
      $("#list_name").val @item.name
      $("#list_description").val @item.description
      d = $("#dialog_addlist").dialog(
        modal: true
        title: "Edit this list"
        dialogClass: "editing"
        buttons:
          'Edit List': () ->
            edit_list()
            $(this).dialog("close")
      )

      d.data "id", @item.id
    
    attach: ->
      @el.find(".roundedlist").sortable
        stop: (event, ui) ->
          #console.log(ui)
          #console.log(event)
          
          window.ui = ui
          id = ui.item.find(".id").attr("value")
          
          current = Task.find( id )
          current_list_id = window.ui.item.parent().attr("id").split("_")[0]
          
          log("dragged and dropped", current.name)
          
          current.listid = current_list_id
          current.order = ui.item.index()
          current.time = moment().toString()
          current.save()
          
          #log("CURRENT", current)
                                 
        connectWith: ".connectedsortable"
      
      @el.find(".addinputs").toggle()
      @el.find(".addtoggle").click (event) ->
        clicked = $(this)
        clicked.toggle()
        clicked.parent().children(".addinputs").toggle()
        clicked.parent().find(".addinputs .addtasks").focus()
      
      @el.find(".doneadding").click (event) ->
        clicked = $(this)
        clicked.parent().parent().children(".addtoggle").toggle()
        clicked.parent().toggle()
  )
  window.allLists = Spine.Controller.create(
    el: $("#listsoftasks")
    proxied: [ "render" ]
    init: ->
      @render()
    
    render: ->
      lists = List.all()
      cur_el = @el
      $.each lists, (key, value) ->
        list = TaskApp.init(item: value)
        cur_el.append list.render().el
        list.attach()
    
    render_new: (item) ->
      list = TaskApp.init(item: item)
      @el.append list.render().el
      list.attach()
  )

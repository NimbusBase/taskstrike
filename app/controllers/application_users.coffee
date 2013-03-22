jQuery ($) ->
  #create a app for each pane
  window.UserCard = Spine.Controller.create(
    elements:
      ".name_field": "name"
      ".email_field": "email"
      ".color_field": "color"
      ".person-value": "title"
      ".user_image": "image"
        
    proxied: [ "render", "remove", "update_user", "cancel" ]    
    events:
      "click .edituserbutton" : "update_user"
      "click .front": "open"
      "click .person-delete": "delete_user"
      "click .cancelbutton": "cancel"
    
    init: ->
      #@item.bind "update", @rerender      
      @item.bind "destroy", @remove
      
    render: ->
      elements = $("#userTemplate").tmpl( User.find( @item.id) )
      @el.html elements
      @refreshElements()     
      this
    
    cancel: ->
      @el.find(".person").trigger("flip")
    
    open: ->      
      @name.val( @item.name )
      @email.val( @item.email )
      @color.val( @item.color )
      
      if not @el.find(".person").hasClass "flipped"
        $(".person.flipped").trigger("flip")
        @el.find(".person").trigger("flip")

    delete_user: ->
      if @item.image?
        UserImage.find(@item.image).destroy() if UserImage.exists(@item.image)
      @item.destroy()
      
    remove: ()->
      @el.remove() 
    
    update_user: ->
      @item.updateAttributes 
        name: @name.val()
        email: @email.val()
        color: @color.val()
      
      @item.save()
      
      @title.html( @item.name )
      
      if window.has_user_image
        log("image called")
        window.has_user_image = false
        
        i = UserImage.create( image: window.imageevent.target.result )
        i.save()
        
        @item.image = i.id
        @item.save()
        
        @image[0].style.background = 'url(' + window.imageevent.target.result + ') no-repeat center center'
        
      @el.find(".person.flipped").trigger("flip")
      
  )
  
  #create a app for the user sidepane
  window.UserApp = Spine.Controller.create(
    elements: 
      "#users_div": "items"
      
    events: 
      "click .useritem" : "click"
      "dblclick .useritem" : "edit_user_window"
      "click .useritem>span" : "click"
      "click #add_user_button": "add_user_window"      
  
    proxied: [ "render", "add_user", "edit_user", "addAll", "uploader_init" ]
    
    init: ->
      User.fetch()
      #@list = Spine.List.init(
      #  el: @items
      #  template: @template
      #)
      #User.bind "refresh change", @render
      @addAll()

    addAll: =>
      all_users = User.all()
      $('#people-list').html("")  
      $.each all_users, (key, value) ->
        card = UserCard.init( item: value )
        $('#people-list').append card.render().el
        
      for a in $(".person")
        $(a).gfxFlip( height: 247, width: 210 )
        
      #initialize color picker
      for b in $(".color_field")
        $(b).ColorPicker({ 
          livePreview: true,         
          onSubmit: (hsb, hex, rgb, el) ->
            $(el).val(hex)
            $(el).ColorPickerHide()
          change: (hsb, hex, rgb) ->
            alert("onchange")
            $(this).ColorPickerSetColor(@value)
        })
      #$("#users_div").children(":first").addClass "current"

      #intialize the filuploader
      for upload in $(".picture_field")
        uploader_init(upload)
    
    click: (e) ->
      
      if $(e.target).hasClass "useritem"
        $("#users_div .current").removeClass "current"
        $(e.target).addClass "current" 
      else
        $("#users_div .current").removeClass "current"
        $(e.target).parent().addClass "current" 
    
    add_user_window: ->
      newUser = User.create()
      card = UserCard.init( item: newUser )
      $('#people-list').append card.render().el
      
      card.el.find(".person").gfxFlip( height: 247, width: 210 )
      card.el.find(".person").trigger("flip") 
      card.el.find(".color_field").ColorPicker({ 
          livePreview: true,
          color: '#00ff00',            
          onSubmit: (hsb, hex, rgb, el) ->
            $(el).val(hex);
            $(el).ColorPickerHide();
      })
      
    edit_user_window: ->
      id = $("#users_div .current").attr("id")
      
      curr_user = User.find(id)
      
      #populate window
      $('#user_name').val( curr_user.name )
      $('#user_email').val( curr_user.email)
      $("#user_color").val(curr_user.color)
      
      $("#dialog_adduser").dialog( modal: true, title: 'Edit User', dialogClass: "editing" )
    
      
    add_user: ->
      name = $('#user_name').val()
      email = $('#user_email').val()
      color = $("#user_color").val()
      
      newUser = User.create(name: name, email: email, color: color )
      @addAll()
      $("#dialog_adduser").dialog("close")
      
      setting_stuff = Setting.all()[0]
      
      add_email_acl(email, setting_stuff.gmail, setting_stuff.password )
      
      #clear out the form
      $('#user_name').val("")
      $('#user_description').val("")
      $("#user_color").val("")

    edit_user: ->
      id = $("#users_div .current").attr("id")
      
      curr_user = User.find(id)
      
      curr_user.updateAttributes 
        name: $('#user_name').val()
        email: $('#user_email').val()
        color: $("#user_color").val()
      
      #clear out the form
      $('#user_name').val("")
      $('#user_description').val("")
      $("#user_color").val("")
      
      @addAll()
      
      $("#dialog_adduser").dialog("close")    
  )

  #create a app for the user sidepane
  window.UserLegendApp = Spine.Controller.create(
    elements: 
      "#gantt_legend": "items"
      
    proxied: [ "addAll" ]
    
    addAll: =>
      all_users = User.all()
      $('#gantt_legend').html("")  
      
      for user in all_users
        element = $("#tagTmpl").tmpl( user )
        $('#gantt_legend').append(element)
  )

#get user, used for rendering users in the template for tasks
window.get_user = (item) ->
  User.fetch()
  if User.exists item.data.userid
    User.find item.data.userid

window.get_image = (image) ->
  if UserImage.exists(image)
    a = UserImage.find image
    return a.image
  else
    return "../images/default-person.gif"
 
#check you
window.check_you = (email) ->
  if CurrentUser.first().email is email
    return "(You)"
  else
    return "" 
 
window.uploader_init= (upload) ->
  upload.onchange = (e) ->
    console.log("changed called")
    e.preventDefault()
  
    file = upload.files[0]
    reader = new FileReader()
    
    $(".person.flipped .picloader").show()
    
    reader.onload = ((theFile) ->
      (e) ->              
        console.log("reader.onload called")
        
        window.imageevent = event
        window.has_user_image = true
        
        $(".person.flipped .picloader").hide()
        
    )(file)
  
    reader.readAsDataURL(file)
    window.file = file
    window.reader = reader
    
    return false
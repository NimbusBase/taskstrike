#setting view

#User management code
window.render_user_square = (p)->
  if p.pic?
    pic = p.pic
  else
    pic = "images/default-person.gif"
  
  color_string =
    '7bd148': ""
    '5484ed': ""
    'a4bdfc': ""
    '46d6db': ""
    '7ae7bf': ""
    '51b749': ""
    'fbd75b': ""
    'ffb878': ""
    'dc2127': ""
    'dbadff': ""
    'e1e1e1': ""
  
  a = User.find(p.id)
  color_string[a.color] = "selected"
  
  if window.logged_in_user? and window.logged_in_user.id is p.id
    button_string = "<button class='small_blue_button' style='background: #1AB58A; border: 0px;'><text rel='label_delete_task'>You</text></button>"
  else
    button_string = "<button class='small_blue_button' onclick='window.remove_user(\"#{ p.id }\")'><text rel='label_delete_task'>Remove User</text></button>"
  
  render_string = """<li class='useritem' id='#{ p.id }'>
<img src='#{ pic }' /><span>#{ p.name }</span>
<select name="colorpicker-picker" id="#{ p.id }">
  <option value="#7bd148" #{ color_string['7bd148'] }>Green</option>
  <option value="#5484ed" #{ color_string['5484ed'] }>Bold blue</option>
  <option value="#a4bdfc" #{ color_string['a4bdfc'] }>Blue</option>
  <option value="#46d6db" #{ color_string['46d6db'] }>Turquoise</option>
  <option value="#7ae7bf" #{ color_string['7ae7bf'] }>Light green</option>
  <option value="#51b749" #{ color_string['51b749'] }>Bold green</option>
  <option value="#fbd75b" #{ color_string['fbd75b'] }>Yellow</option>
  <option value="#ffb878" #{ color_string['ffb878'] }>Orange</option>
  <option value="#ff887c" #{ color_string['ff887c'] }>Red</option>
  <option value="#dc2127" #{ color_string['dc2127'] }>Bold red</option>
  <option value="#dbadff" #{ color_string['dbadff'] }>Purple</option>
  <option value="#e1e1e1" #{ color_string['e1e1e1'] }>Gray</option>
</select>
#{ button_string }
</li>"""
  $(".userlist").append(render_string)

  $('select[name="colorpicker-picker"]').simplecolorpicker(picker: true).on('change', ()->
    log(this)
    color = $(this).val().replace("#", "")
    log(color)
    id = this.id
    
    log(id)
    
    a = User.find( id )
    a.color = color
    a.save()
  )

window.render_user = (callback)->
  log("render user")
  
  if Nimbus.Auth.service is "GDrive"
    Nimbus.Share.get_users( (permissions)->
      log("return called")
      $(".userlist").html("")
      
      for p in permissions
        log("p", p)
        
        unless User.exists(p.id)
          a = User.init( p )
          a.color = "e1e1e1"
          a.save()
        
        window.render_user_square(p)
      
      callback() if callback?
    )

window.render_current_user = (callback)->
  log("current user")
  
  if Nimbus.Auth.service is "GDrive"
    Nimbus.Share.get_me( (me)->
      log("return get me called")
      
      window.logged_in_user = me
      
      if me.pic?
        $("#logged_in_image").attr("src", me.pic)
      
      callback() if callback?
    )
    
window.add_user = ()->
  email = $("#shareinput").val()
  if email is ""
    create("sticky", {"title":"Failed", "text":"Email empty"})
    return
  log("add user", email)
  $("#shareinput").val("")
  
  if Nimbus.Auth.service is "GDrive"
    create("sticky", {"title":"Adding user", "text":"Adding "+email})
    
    Nimbus.Share.add_user(email, (p)->
      log("p", p)

      a = User.init( p )
      a.color = "e1e1e1"
      a.save()      
      
      $('select[name="colorpicker-picker"]').simplecolorpicker(picker: true).on('change', ()->
        log(this)
        color = $(this).val().replace("#", "")
        log(color)
        id = this.id
        
        log(id)
        
        a = User.find( id )
        a.color = color
        a.save()
      )
      window.render_user_square(p)
    )

window.remove_user = (id)->
  log("remove user", id)
  
  if Nimbus.Auth.service is "GDrive"
    create("sticky", {"title":"Removing a user", "text":"In the process of removal"})
    Nimbus.Share.remove_user(id, ()->
        log("deleted user callback")
        $("#"+id).remove()
        a = User.find( id )
        a.destroy()
        create("sticky", {"title":"Success", "text":"User removed"})
    )

window.get_user = (item) ->
  
  if User.exists item.data.userid
    User.find item.data.userid

window.get_space = ()->
  log("get spaces")
  
  if Nimbus.Auth.service is "GDrive"
    Nimbus.Share.get_spaces( (data)->
      $(".projectlist").html("")
      
      for d in data
        if window.folder[Nimbus.Auth.app_name].id is d.id
          button_string = """<button class="small_blue_button forty" onclick="switch_workspace(\'#{ d.id }\')" style="background: #1AB58A; border: 0px;"><text rel="label_delete_task">Current Workspace</text></button>"""
        else
          button_string = """<button class="small_blue_button forty" onclick="switch_workspace(\'#{ d.id }\')"><text rel="label_delete_task">Switch to Workspace</text></button>"""
        
        string = """<li class="useritem">
<img src="images/default-person.gif" />
<span>#{ d.owner }'s workspace</span>
#{ button_string }
</li>"""
        $(".projectlist").append(string)
        
    )


(($) ->
  db_path = Titanium.Filesystem.getFile(Titanium.Filesystem.getApplicationDataDirectory(), "gtasktic.db")
  db = Titanium.Database.openFile(db_path)
  
  #this function is used to prepare the statement
  String::replaceAll = (strReplace, strWith) ->
    reg = new RegExp(strReplace, "ig")
    @replace reg, strWith
  
  
  db.execute "CREATE TABLE IF NOT EXISTS keyval ( key TEXT, value TEXT )"
  Spine.Model.Local = 
    extended: ->
      @sync @proxy(@saveLocal)
      @fetch @proxy(@loadLocal)
    
    saveLocal: ->
      result = JSON.stringify(this)
      db.execute "DELETE from keyval where key ='" + @name + "'"
      #Titanium.API.debug result
      result = result.replaceAll("'", "''")
      #Titanium.API.log('INFO', result)
      db.execute "INSERT INTO keyval (key, value) VALUES ('" + @name + "', '" + result + "')"
    
    loadLocal: ->
      resultSet = db.execute("SELECT value FROM keyval WHERE key = '" + @name + "' LIMIT 1")
      result = resultSet.field(0)
      return  unless result
      result = JSON.parse(result)
      @refresh result
) jQuery

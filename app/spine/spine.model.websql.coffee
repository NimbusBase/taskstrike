(($) ->
  #db_path = Titanium.Filesystem.getFile(Titanium.Filesystem.getApplicationDataDirectory(), "gtasktic.db")
  #db = Titanium.Database.openFile(db_path)
  
  db = openDatabase("ToDo", "0.1", "Todo item.", 10*1024*1024)
  
  #this function is used to prepare the statement
  String::replaceAll = (strReplace, strWith) ->
    reg = new RegExp(strReplace, "ig")
    @replace reg, strWith
  
  
  db.transaction ( (tx) -> tx.executeSql "CREATE TABLE IF NOT EXISTS keyval ( key TEXT, value TEXT )" )  
  
  Spine.Model.Local = 
    extended: ->
      @sync @proxy(@saveLocal)
      @fetch @proxy(@loadLocal)
    
    saveLocal: ->
      result = JSON.stringify(this)
      
      result = result.replaceAll("'", "''")
      
      delete_sql = "DELETE from keyval where key ='" + @name + "'"
      insert_sql = "INSERT INTO keyval (key, value) VALUES ('" + @name + "', '" + result + "')"
      
      db.transaction ( (tx) -> 
        tx.executeSql delete_sql 
        tx.executeSql insert_sql 
      )
      #console.log( delete_sql )
      #console.log( insert_sql )
    
    loadLocal: ->
      get_sql = "SELECT value FROM keyval WHERE key = '" + @name + "' LIMIT 1"  
      data = []
      this_object = this
      
      if window.read_from_websql?
        window.read_from_websql.wait()

      resultSet = db.transaction ( (tx) ->  
        f = (tx, results) -> 
          #console.log("got here")
          #console.log(results)
          
          if results.rows.length > 0
            result_text = results.rows.item(0).value
            #result_text = result.replaceAll("''", "'")
            data = JSON.parse(result_text)
            #console.log(this_object)
            this_object.refresh data
          
          if window.read_from_websql?
            window.read_from_websql.ok()
        
        tx.executeSql(get_sql, [], f)
        
        #console.log(get_sql)
      )
      
      #result = resultSet.field(0)
      #return  unless result
      #result = JSON.parse(result)
      #@refresh result

) jQuery

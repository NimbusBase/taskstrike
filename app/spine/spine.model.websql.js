// Generated by CoffeeScript 1.4.0
(function() {

  (function($) {
    var db;
    db = openDatabase("ToDo", "0.1", "Todo item.", 10 * 1024 * 1024);
    String.prototype.replaceAll = function(strReplace, strWith) {
      var reg;
      reg = new RegExp(strReplace, "ig");
      return this.replace(reg, strWith);
    };
    db.transaction((function(tx) {
      return tx.executeSql("CREATE TABLE IF NOT EXISTS keyval ( key TEXT, value TEXT )");
    }));
    return Spine.Model.Local = {
      extended: function() {
        this.sync(this.proxy(this.saveLocal));
        return this.fetch(this.proxy(this.loadLocal));
      },
      saveLocal: function() {
        var delete_sql, insert_sql, result;
        result = JSON.stringify(this);
        result = result.replaceAll("'", "''");
        delete_sql = "DELETE from keyval where key ='" + this.name + "'";
        insert_sql = "INSERT INTO keyval (key, value) VALUES ('" + this.name + "', '" + result + "')";
        return db.transaction((function(tx) {
          tx.executeSql(delete_sql);
          return tx.executeSql(insert_sql);
        }));
      },
      loadLocal: function() {
        var data, get_sql, resultSet, this_object;
        get_sql = "SELECT value FROM keyval WHERE key = '" + this.name + "' LIMIT 1";
        data = [];
        this_object = this;
        if (window.read_from_websql != null) {
          window.read_from_websql.wait();
        }
        return resultSet = db.transaction((function(tx) {
          var f;
          f = function(tx, results) {
            var result_text;
            if (results.rows.length > 0) {
              result_text = results.rows.item(0).value;
              data = JSON.parse(result_text);
              this_object.refresh(data);
            }
            if (window.read_from_websql != null) {
              return window.read_from_websql.ok();
            }
          };
          return tx.executeSql(get_sql, [], f);
        }));
      }
    };
  })(jQuery);

}).call(this);

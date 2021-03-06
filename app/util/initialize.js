// Generated by CoffeeScript 1.6.2
(function() {
  var current_verion;

  current_verion = "2.1";

  window.initializeApp = function() {
    var m, model, model_list, new_back, new_task, new_task_2, new_token, new_version, newlist, result, set_init, _i, _j, _len, _len1, _ref;

    if (Initialized.all().length === 0 && (localStorage["Initialized"] != null)) {
      model_list = [Task, Deletion, List, Token, Finished, Initialized, Version, BackgroundImage];
      for (_i = 0, _len = model_list.length; _i < _len; _i++) {
        model = model_list[_i];
        result = localStorage[model.name];
        if (result != null) {
          result = JSON.parse(result);
          model.refresh(result);
          _ref = model.all();
          for (_j = 0, _len1 = _ref.length; _j < _len1; _j++) {
            m = _ref[_j];
            m.save();
          }
        }
      }
      new_version = Version.first();
      new_version.number = current_verion;
      new_version.save();
    }
    if (Initialized.all().length === 0) {
      window.first_time = true;
      new_version = Version.init({
        number: current_verion
      });
      new_version.save();
      set_init = Initialized.init({
        flag: "true"
      });
      set_init.save();
      newlist = List.init({
        name: "Your Todos",
        description: "",
        time: moment().toString(),
        synced: false,
        google_id: "@default"
      });
      newlist.save();
      new_task = Task.init({
        name: "Click on settings and link your Dropbox account",
        time: moment().toString(),
        done: false,
        order: 0,
        synced: false,
        listid: newlist.id
      });
      new_task.save();
      new_task_2 = Task.init({
        name: "Click on the sync button on the bottom left to sync",
        time: moment().toString(),
        done: false,
        order: 1,
        synced: false,
        listid: newlist.id
      });
      new_task_2.save();
      new_token = Token.init({
        current_token: "",
        expiration: "",
        refresh_token: ""
      });
      new_token.save();
      new_back = BackgroundImage.init({
        "image": ""
      });
      new_back.save();
    }
    if (Version.first().number === "0.2") {
      new_token = Token.init({
        current_token: "",
        expiration: "",
        refresh_token: ""
      });
      new_token.save();
      new_back = BackgroundImage.init({
        "image": ""
      });
      new_back.save();
      new_version = Version.first();
      new_version.number = current_verion;
      return new_version.save();
    }
  };

}).call(this);

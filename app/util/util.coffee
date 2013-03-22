String::replaceAll = (strReplace, strWith) ->
  reg = new RegExp(strReplace, "ig")
  @replace reg, strWith

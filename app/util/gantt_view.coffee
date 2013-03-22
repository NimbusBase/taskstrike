###

Options
-----------------
showWeekends: boolean
data: object
cellWidth: number
cellHeight: number
slideWidth: number
dataUrl: string
behavior: {
    clickable: boolean,
  draggable: boolean,
  resizable: boolean,
  onClick: function,
  onDrag: function,
  onResize: function
}

###

((jQuery) ->
  
  build = (options) ->
    build = ->
      minDays = Math.floor((opts.slideWidth / opts.cellWidth) + 5)
      startEnd = DateUtils.getBoundaryDatesFromData(opts.data, minDays)
      opts.start = startEnd[0]
      opts.end = startEnd[1]
      els.each ->
        container = jQuery(this)
        div = jQuery("<div>",
          class: "ganttview"
        )
        new Chart(div, opts).render()
        container.append div
        w = jQuery("div.ganttview-vtheader", container).outerWidth() + jQuery("div.ganttview-slide-container", container).outerWidth()
        #container.css "width", (w + 2) + "px"
        container.css "width", (w + 2) + "px"
        new Behavior(container, opts).apply()
    els = this
    
    defaults =
      showWeekends: true
      cellWidth: 21
      cellHeight: 31
      slideWidth: 400
      vHeaderWidth: 100
      behavior:
        clickable: true
        draggable: true
        resizable: true

    opts = jQuery.extend(true, defaults, options)
    
    #if you get a data, build from the data, if you get a data url, retrieve the data then build it
    if opts.data
      build()
    else if opts.dataUrl
      jQuery.getJSON opts.dataUrl, (data) ->
        opts.data = data
        build()
        
  handleMethod = (method, value) ->
    if method is "setSlideWidth"
      div = $("div.ganttview", this)
      div.each ->
        vtWidth = $("div.ganttview-vtheader", div).outerWidth()
        $(div).width vtWidth + value + 1
        $("div.ganttview-slide-container", this).width "79.5%"
    else if method is "rerender"
      container = jQuery(this)
      
      container.html("")
      
      defaults =
        showWeekends: true
        cellWidth: 21
        cellHeight: 31
        slideWidth: 400
        vHeaderWidth: 100
        behavior:
          clickable: true
          draggable: true
          resizable: true
      
      opts = jQuery.extend(true, defaults, value)
      minDays = Math.floor((opts.slideWidth / opts.cellWidth) + 5)
      startEnd = DateUtils.getBoundaryDatesFromData(opts.data, minDays)
      opts.start = startEnd[0]
      opts.end = startEnd[1]
      
      container = jQuery(this)
      div = jQuery("<div>",
        class: "ganttview"
      )
      log opts
      new Chart(div, opts).render()
      container.append div
      w = jQuery("div.ganttview-vtheader", container).outerWidth() + jQuery("div.ganttview-slide-container", container).outerWidth()
      container.css "width", (w + 2) + "px"
      new Behavior(container, opts).apply()
  
  jQuery.fn.ganttView = ->
    args = Array::slice.call(arguments)
    build.call this, args[0]  if args.length is 1 and typeof (args[0]) is "object"
    handleMethod.call this, args[0], args[1]  if args.length is 2 and typeof (args[0]) is "string"

  Chart = (div, opts) ->
    
    render = ->
      addVtHeader div, opts.data, opts.cellHeight
      slideDiv = jQuery("<div>",
        class: "ganttview-slide-container"
        css:
          width: "79.5%"
      )
      dates = getDates(opts.start, opts.end)
      addHzHeader slideDiv, dates, opts.cellWidth
      addGrid slideDiv, opts.data, dates, opts.cellWidth, opts.showWeekends
      addBlockContainers slideDiv, opts.data
      addBlocks slideDiv, opts.data, opts.cellWidth, opts.start
      div.append slideDiv
      applyLastClass div.parent()
      
    getDates = (start, end) ->
      dates = []
      dates[start.getFullYear()] = []
      dates[start.getFullYear()][start.getMonth()] = [ start ]
      last = start
      while last.compareTo(end) is -1
        next = last.clone().addDays(1)
        dates[next.getFullYear()] = []  unless dates[next.getFullYear()]
        dates[next.getFullYear()][next.getMonth()] = []  unless dates[next.getFullYear()][next.getMonth()]
        dates[next.getFullYear()][next.getMonth()].push next
        last = next
      dates

    addVtHeader = (div, data, cellHeight) ->
      headerDiv = jQuery("<div>",
        class: "ganttview-vtheader"
      )
      i = 0

      while i < data.length
        itemDiv = jQuery("<div>",
          class: "ganttview-vtheader-item"
        )
        itemDiv.append jQuery("<div>",
          class: "ganttview-vtheader-item-name"
          css:
            height: (data[i].series.length * cellHeight) + "px"
        ).append(data[i].name)
        seriesDiv = jQuery("<div>",
          class: "ganttview-vtheader-series"
        )
        j = 0

        for line in data[i].series
            seriesDiv.append "<div class='ganttview-vtheader-series-name'>#{line.name}</div>"
          
        itemDiv.append seriesDiv
        headerDiv.append itemDiv
        i++
      div.append headerDiv

    addHzHeader = (div, dates, cellWidth) ->
      headerDiv = jQuery("<div>",
        class: "ganttview-hzheader"
      )
      monthsDiv = jQuery("<div>",
        class: "ganttview-hzheader-months"
      )
      daysDiv = jQuery("<div>",
        class: "ganttview-hzheader-days"
      )
      totalW = 0
      for y of dates
        for m of dates[y]
          w = dates[y][m].length * cellWidth
          totalW = totalW + w
          monthsDiv.append jQuery("<div>",
            class: "ganttview-hzheader-month"
            css:
              width: (w - 1) + "px"
          ).append(monthNames[m] + "/" + y)
          for d of dates[y][m]
            daysDiv.append jQuery("<div>",
              class: "ganttview-hzheader-day"
            ).append(dates[y][m][d].getDate())
      monthsDiv.css "width", totalW + "px"
      daysDiv.css "width", totalW + "px"
      headerDiv.append(monthsDiv).append daysDiv
      div.append headerDiv

    addGrid = (div, data, dates, cellWidth, showWeekends) ->
      gridDiv = jQuery("<div>",
        class: "ganttview-grid"
      )
      rowDiv = jQuery("<div>",
        class: "ganttview-grid-row"
      )
      for y of dates
        for m of dates[y]
          for d of dates[y][m]
            cellDiv = jQuery("<div>",
              class: "ganttview-grid-row-cell"
            )
            cellDiv.addClass "ganttview-weekend"  if DateUtils.isWeekend(dates[y][m][d]) and showWeekends
            rowDiv.append cellDiv
      w = jQuery("div.ganttview-grid-row-cell", rowDiv).length * cellWidth
      rowDiv.css "width", w + "px"
      gridDiv.css "width", w + "px"
      i = 0

      while i < data.length
        j = 0

        while j < data[i].series.length
          gridDiv.append rowDiv.clone()
          j++
        i++
      div.append gridDiv
    addBlockContainers = (div, data) ->
      blocksDiv = jQuery("<div>",
        class: "ganttview-blocks"
      )
      i = 0

      while i < data.length
        j = 0

        while j < data[i].series.length
          blocksDiv.append jQuery("<div>",
            class: "ganttview-block-container"
          )
          j++
        i++
      div.append blocksDiv
      
    addBlocks = (div, data, cellWidth, start) ->
      rows = jQuery("div.ganttview-blocks div.ganttview-block-container", div)
      rowIdx = 0
      i = 0

      while i < data.length
        j = 0

        while j < data[i].series.length
          series = data[i].series[j]
          size = DateUtils.daysBetween(series.start, series.end) + 1
          offset = DateUtils.daysBetween(start, series.start)
          
          color = "#000"
          color = data[i].series[j].color if data[i].series[j].color
          
          block = jQuery("""<div class="ganttview-block" title="#{ series.name + ", " + size + " days" }" style="width: #{ ((size * cellWidth) - 9) }px; margin-left: #{ ((offset * cellWidth) + 3) }px; background-color: #{color}; ">
            <div class="ganttview-block-text">#{ size }</div>
           </div>""")
          
          addBlockData block, data[i], series
          
          ###
          block = jQuery("<div>",
            class: "ganttview-block"
            title: series.name + ", " + size + " days"
            css:
              width: ((size * cellWidth) - 9) + "px"
              "margin-left": ((offset * cellWidth) + 3) + "px"
          )
          
          addBlockData block, data[i], series
          block.css "background-color", data[i].series[j].color  if data[i].series[j].color
          block.append jQuery("<div>",
            class: "ganttview-block-text"
          ).text(size)
          ###
          
          jQuery(rows[rowIdx]).append block
          rowIdx = rowIdx + 1
          j++
        i++
        
    addBlockData = (block, data, series) ->
      blockData =
        id: data.id
        name: data.name

      jQuery.extend blockData, series
      block.data "block-data", blockData

    applyLastClass = (div) ->
      jQuery("div.ganttview-grid-row div.ganttview-grid-row-cell:last-child", div).addClass "last"
      jQuery("div.ganttview-hzheader-days div.ganttview-hzheader-day:last-child", div).addClass "last"
      jQuery("div.ganttview-hzheader-months div.ganttview-hzheader-month:last-child", div).addClass "last"
    monthNames = [ "Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec" ]
    render: render

  Behavior = (div, opts) ->
    apply = ->
      bindBlockClick div, opts.behavior.onClick  if opts.behavior.clickable
      bindBlockResize div, opts.cellWidth, opts.start, opts.behavior.onResize  if opts.behavior.resizable
      bindBlockDrag div, opts.cellWidth, opts.start, opts.behavior.onDrag  if opts.behavior.draggable
    bindBlockClick = (div, callback) ->
      jQuery("div.ganttview-block", div).live "click", ->
        callback jQuery(this).data("block-data")  if callback
    bindBlockResize = (div, cellWidth, startDate, callback) ->
      jQuery("div.ganttview-block", div).resizable
        grid: cellWidth
        handles: "e,w"
        stop: ->
          block = jQuery(this)
          updateDataAndPosition div, block, cellWidth, startDate
          callback block.data("block-data")  if callback

    bindBlockDrag = (div, cellWidth, startDate, callback) ->
      jQuery("div.ganttview-block", div).draggable
        axis: "x"
        grid: [ cellWidth, cellWidth ]
        stop: ->
          block = jQuery(this)
          updateDataAndPosition div, block, cellWidth, startDate
          callback block.data("block-data")  if callback

    updateDataAndPosition = (div, block, cellWidth, startDate) ->
      container = jQuery("div.ganttview-slide-container", div)
      scroll = container.scrollLeft()
      offset = block.offset().left - container.offset().left - 1 + scroll
      daysFromStart = Math.round(offset / cellWidth)
      newStart = startDate.clone().addDays(daysFromStart)
      block.data("block-data").start = newStart
      width = block.outerWidth()
      numberOfDays = Math.round(width / cellWidth) - 1
      block.data("block-data").end = newStart.clone().addDays(numberOfDays)
      jQuery("div.ganttview-block-text", block).text numberOfDays + 1
      block.css("top", "").css("left", "").css("position", "relative").css "margin-left", offset + "px"
    apply: apply

  ArrayUtils = contains: (arr, obj) ->
    has = false
    i = 0

    while i < arr.length
      has = true  if arr[i] is obj
      i++
    has

  DateUtils =
    daysBetween: (start, end) ->
      return 0  if not start or not end
      start = Date.parse(start)
      end = Date.parse(end)
      return 0  if start.getYear() is 1901 or end.getYear() is 8099
      count = 0
      date = start.clone()
      while date.compareTo(end) is -1
        count = count + 1
        date.addDays 1
      count

    isWeekend: (date) ->
      date.getDay() % 6 is 0

    getBoundaryDatesFromData: (data, minDays) ->
      minStart = new Date()
      maxEnd = new Date()
      i = 0

      while i < data.length
        j = 0

        while j < data[i].series.length
          start = Date.parse(data[i].series[j].start)
          end = Date.parse(data[i].series[j].end)
          if i is 0 and j is 0
            minStart = start
            maxEnd = end
          minStart = start  if minStart.compareTo(start) is 1
          maxEnd = end  if maxEnd.compareTo(end) is -1
          j++
        i++
      maxEnd = minStart.clone().addDays(minDays)  if DateUtils.daysBetween(minStart, maxEnd) < minDays
      [ minStart, maxEnd ]
) jQuery
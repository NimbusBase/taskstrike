// Generated by CoffeeScript 1.6.2
/*

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
*/


(function() {
  (function(jQuery) {
    var ArrayUtils, Behavior, Chart, DateUtils, build, handleMethod;

    build = function(options) {
      var defaults, els, opts;

      build = function() {
        var minDays, startEnd;

        minDays = Math.floor((opts.slideWidth / opts.cellWidth) + 5);
        startEnd = DateUtils.getBoundaryDatesFromData(opts.data, minDays);
        opts.start = startEnd[0];
        opts.end = startEnd[1];
        return els.each(function() {
          var container, div, w;

          container = jQuery(this);
          div = jQuery("<div>", {
            "class": "ganttview"
          });
          new Chart(div, opts).render();
          container.append(div);
          w = jQuery("div.ganttview-vtheader", container).outerWidth() + jQuery("div.ganttview-slide-container", container).outerWidth();
          container.css("width", (w + 2) + "px");
          return new Behavior(container, opts).apply();
        });
      };
      els = this;
      defaults = {
        showWeekends: true,
        cellWidth: 21,
        cellHeight: 31,
        slideWidth: 400,
        vHeaderWidth: 100,
        behavior: {
          clickable: true,
          draggable: true,
          resizable: true
        }
      };
      opts = jQuery.extend(true, defaults, options);
      if (opts.data) {
        return build();
      } else if (opts.dataUrl) {
        return jQuery.getJSON(opts.dataUrl, function(data) {
          opts.data = data;
          return build();
        });
      }
    };
    handleMethod = function(method, value) {
      var container, defaults, div, minDays, opts, startEnd, w;

      if (method === "setSlideWidth") {
        div = $("div.ganttview", this);
        return div.each(function() {
          var vtWidth;

          vtWidth = $("div.ganttview-vtheader", div).outerWidth();
          $(div).width(vtWidth + value + 1);
          return $("div.ganttview-slide-container", this).width("79.5%");
        });
      } else if (method === "rerender") {
        container = jQuery(this);
        container.html("");
        defaults = {
          showWeekends: true,
          cellWidth: 21,
          cellHeight: 31,
          slideWidth: 400,
          vHeaderWidth: 100,
          behavior: {
            clickable: true,
            draggable: true,
            resizable: true
          }
        };
        opts = jQuery.extend(true, defaults, value);
        minDays = Math.floor((opts.slideWidth / opts.cellWidth) + 5);
        startEnd = DateUtils.getBoundaryDatesFromData(opts.data, minDays);
        opts.start = startEnd[0];
        opts.end = startEnd[1];
        container = jQuery(this);
        div = jQuery("<div>", {
          "class": "ganttview"
        });
        log(opts);
        new Chart(div, opts).render();
        container.append(div);
        w = jQuery("div.ganttview-vtheader", container).outerWidth() + jQuery("div.ganttview-slide-container", container).outerWidth();
        container.css("width", (w + 2) + "px");
        return new Behavior(container, opts).apply();
      }
    };
    jQuery.fn.ganttView = function() {
      var args;

      args = Array.prototype.slice.call(arguments);
      if (args.length === 1 && typeof args[0] === "object") {
        build.call(this, args[0]);
      }
      if (args.length === 2 && typeof args[0] === "string") {
        return handleMethod.call(this, args[0], args[1]);
      }
    };
    Chart = function(div, opts) {
      var addBlockContainers, addBlockData, addBlocks, addGrid, addHzHeader, addVtHeader, applyLastClass, getDates, monthNames, render;

      render = function() {
        var dates, slideDiv;

        addVtHeader(div, opts.data, opts.cellHeight);
        slideDiv = jQuery("<div>", {
          "class": "ganttview-slide-container",
          css: {
            width: "79.5%"
          }
        });
        dates = getDates(opts.start, opts.end);
        addHzHeader(slideDiv, dates, opts.cellWidth);
        addGrid(slideDiv, opts.data, dates, opts.cellWidth, opts.showWeekends);
        addBlockContainers(slideDiv, opts.data);
        addBlocks(slideDiv, opts.data, opts.cellWidth, opts.start);
        div.append(slideDiv);
        return applyLastClass(div.parent());
      };
      getDates = function(start, end) {
        var dates, last, next;

        dates = [];
        dates[start.getFullYear()] = [];
        dates[start.getFullYear()][start.getMonth()] = [start];
        last = start;
        while (last.compareTo(end) === -1) {
          next = last.clone().addDays(1);
          if (!dates[next.getFullYear()]) {
            dates[next.getFullYear()] = [];
          }
          if (!dates[next.getFullYear()][next.getMonth()]) {
            dates[next.getFullYear()][next.getMonth()] = [];
          }
          dates[next.getFullYear()][next.getMonth()].push(next);
          last = next;
        }
        return dates;
      };
      addVtHeader = function(div, data, cellHeight) {
        var headerDiv, i, itemDiv, j, line, seriesDiv, _i, _len, _ref;

        headerDiv = jQuery("<div>", {
          "class": "ganttview-vtheader"
        });
        i = 0;
        while (i < data.length) {
          itemDiv = jQuery("<div>", {
            "class": "ganttview-vtheader-item"
          });
          itemDiv.append(jQuery("<div>", {
            "class": "ganttview-vtheader-item-name",
            css: {
              height: (data[i].series.length * cellHeight) + "px"
            }
          }).append(data[i].name));
          seriesDiv = jQuery("<div>", {
            "class": "ganttview-vtheader-series"
          });
          j = 0;
          _ref = data[i].series;
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            line = _ref[_i];
            seriesDiv.append("<div class='ganttview-vtheader-series-name'>" + line.name + "</div>");
          }
          itemDiv.append(seriesDiv);
          headerDiv.append(itemDiv);
          i++;
        }
        return div.append(headerDiv);
      };
      addHzHeader = function(div, dates, cellWidth) {
        var d, daysDiv, headerDiv, m, monthsDiv, totalW, w, y;

        headerDiv = jQuery("<div>", {
          "class": "ganttview-hzheader"
        });
        monthsDiv = jQuery("<div>", {
          "class": "ganttview-hzheader-months"
        });
        daysDiv = jQuery("<div>", {
          "class": "ganttview-hzheader-days"
        });
        totalW = 0;
        for (y in dates) {
          for (m in dates[y]) {
            w = dates[y][m].length * cellWidth;
            totalW = totalW + w;
            monthsDiv.append(jQuery("<div>", {
              "class": "ganttview-hzheader-month",
              css: {
                width: (w - 1) + "px"
              }
            }).append(monthNames[m] + "/" + y));
            for (d in dates[y][m]) {
              daysDiv.append(jQuery("<div>", {
                "class": "ganttview-hzheader-day"
              }).append(dates[y][m][d].getDate()));
            }
          }
        }
        monthsDiv.css("width", totalW + "px");
        daysDiv.css("width", totalW + "px");
        headerDiv.append(monthsDiv).append(daysDiv);
        return div.append(headerDiv);
      };
      addGrid = function(div, data, dates, cellWidth, showWeekends) {
        var cellDiv, d, gridDiv, i, j, m, rowDiv, w, y;

        gridDiv = jQuery("<div>", {
          "class": "ganttview-grid"
        });
        rowDiv = jQuery("<div>", {
          "class": "ganttview-grid-row"
        });
        for (y in dates) {
          for (m in dates[y]) {
            for (d in dates[y][m]) {
              cellDiv = jQuery("<div>", {
                "class": "ganttview-grid-row-cell"
              });
              if (DateUtils.isWeekend(dates[y][m][d]) && showWeekends) {
                cellDiv.addClass("ganttview-weekend");
              }
              rowDiv.append(cellDiv);
            }
          }
        }
        w = jQuery("div.ganttview-grid-row-cell", rowDiv).length * cellWidth;
        rowDiv.css("width", w + "px");
        gridDiv.css("width", w + "px");
        i = 0;
        while (i < data.length) {
          j = 0;
          while (j < data[i].series.length) {
            gridDiv.append(rowDiv.clone());
            j++;
          }
          i++;
        }
        return div.append(gridDiv);
      };
      addBlockContainers = function(div, data) {
        var blocksDiv, i, j;

        blocksDiv = jQuery("<div>", {
          "class": "ganttview-blocks"
        });
        i = 0;
        while (i < data.length) {
          j = 0;
          while (j < data[i].series.length) {
            blocksDiv.append(jQuery("<div>", {
              "class": "ganttview-block-container"
            }));
            j++;
          }
          i++;
        }
        return div.append(blocksDiv);
      };
      addBlocks = function(div, data, cellWidth, start) {
        var block, color, i, j, offset, rowIdx, rows, series, size, _results;

        rows = jQuery("div.ganttview-blocks div.ganttview-block-container", div);
        rowIdx = 0;
        i = 0;
        _results = [];
        while (i < data.length) {
          j = 0;
          while (j < data[i].series.length) {
            series = data[i].series[j];
            size = DateUtils.daysBetween(series.start, series.end) + 1;
            offset = DateUtils.daysBetween(start, series.start);
            color = "#000";
            if (data[i].series[j].color) {
              color = data[i].series[j].color;
            }
            block = jQuery("<div class=\"ganttview-block\" title=\"" + (series.name + ", " + size + " days") + "\" style=\"width: " + ((size * cellWidth) - 9) + "px; margin-left: " + ((offset * cellWidth) + 3) + "px; background-color: " + color + "; \">\n <div class=\"ganttview-block-text\">" + size + "</div>\n</div>");
            addBlockData(block, data[i], series);
            /*
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
            */

            jQuery(rows[rowIdx]).append(block);
            rowIdx = rowIdx + 1;
            j++;
          }
          _results.push(i++);
        }
        return _results;
      };
      addBlockData = function(block, data, series) {
        var blockData;

        blockData = {
          id: data.id,
          name: data.name
        };
        jQuery.extend(blockData, series);
        return block.data("block-data", blockData);
      };
      applyLastClass = function(div) {
        jQuery("div.ganttview-grid-row div.ganttview-grid-row-cell:last-child", div).addClass("last");
        jQuery("div.ganttview-hzheader-days div.ganttview-hzheader-day:last-child", div).addClass("last");
        return jQuery("div.ganttview-hzheader-months div.ganttview-hzheader-month:last-child", div).addClass("last");
      };
      monthNames = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
      return {
        render: render
      };
    };
    Behavior = function(div, opts) {
      var apply, bindBlockClick, bindBlockDrag, bindBlockResize, updateDataAndPosition;

      apply = function() {
        if (opts.behavior.clickable) {
          bindBlockClick(div, opts.behavior.onClick);
        }
        if (opts.behavior.resizable) {
          bindBlockResize(div, opts.cellWidth, opts.start, opts.behavior.onResize);
        }
        if (opts.behavior.draggable) {
          return bindBlockDrag(div, opts.cellWidth, opts.start, opts.behavior.onDrag);
        }
      };
      bindBlockClick = function(div, callback) {
        return jQuery("div.ganttview-block", div).live("click", function() {
          if (callback) {
            return callback(jQuery(this).data("block-data"));
          }
        });
      };
      bindBlockResize = function(div, cellWidth, startDate, callback) {
        return jQuery("div.ganttview-block", div).resizable({
          grid: cellWidth,
          handles: "e,w",
          stop: function() {
            var block;

            block = jQuery(this);
            updateDataAndPosition(div, block, cellWidth, startDate);
            if (callback) {
              return callback(block.data("block-data"));
            }
          }
        });
      };
      bindBlockDrag = function(div, cellWidth, startDate, callback) {
        return jQuery("div.ganttview-block", div).draggable({
          axis: "x",
          grid: [cellWidth, cellWidth],
          stop: function() {
            var block;

            block = jQuery(this);
            updateDataAndPosition(div, block, cellWidth, startDate);
            if (callback) {
              return callback(block.data("block-data"));
            }
          }
        });
      };
      updateDataAndPosition = function(div, block, cellWidth, startDate) {
        var container, daysFromStart, newStart, numberOfDays, offset, scroll, width;

        container = jQuery("div.ganttview-slide-container", div);
        scroll = container.scrollLeft();
        offset = block.offset().left - container.offset().left - 1 + scroll;
        daysFromStart = Math.round(offset / cellWidth);
        newStart = startDate.clone().addDays(daysFromStart);
        block.data("block-data").start = newStart;
        width = block.outerWidth();
        numberOfDays = Math.round(width / cellWidth) - 1;
        block.data("block-data").end = newStart.clone().addDays(numberOfDays);
        jQuery("div.ganttview-block-text", block).text(numberOfDays + 1);
        return block.css("top", "").css("left", "").css("position", "relative").css("margin-left", offset + "px");
      };
      return {
        apply: apply
      };
    };
    ArrayUtils = {
      contains: function(arr, obj) {
        var has, i;

        has = false;
        i = 0;
        while (i < arr.length) {
          if (arr[i] === obj) {
            has = true;
          }
          i++;
        }
        return has;
      }
    };
    return DateUtils = {
      daysBetween: function(start, end) {
        var count, date;

        if (!start || !end) {
          return 0;
        }
        start = Date.parse(start);
        end = Date.parse(end);
        if (start.getYear() === 1901 || end.getYear() === 8099) {
          return 0;
        }
        count = 0;
        date = start.clone();
        while (date.compareTo(end) === -1) {
          count = count + 1;
          date.addDays(1);
        }
        return count;
      },
      isWeekend: function(date) {
        return date.getDay() % 6 === 0;
      },
      getBoundaryDatesFromData: function(data, minDays) {
        var end, i, j, maxEnd, minStart, start;

        minStart = new Date();
        maxEnd = new Date();
        i = 0;
        while (i < data.length) {
          j = 0;
          while (j < data[i].series.length) {
            start = Date.parse(data[i].series[j].start);
            end = Date.parse(data[i].series[j].end);
            if (i === 0 && j === 0) {
              minStart = start;
              maxEnd = end;
            }
            if (minStart.compareTo(start) === 1) {
              minStart = start;
            }
            if (maxEnd.compareTo(end) === -1) {
              maxEnd = end;
            }
            j++;
          }
          i++;
        }
        if (DateUtils.daysBetween(minStart, maxEnd) < minDays) {
          maxEnd = minStart.clone().addDays(minDays);
        }
        return [minStart, maxEnd];
      }
    };
  })(jQuery);

}).call(this);

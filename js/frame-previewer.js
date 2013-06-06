// Generated by CoffeeScript 1.6.1
(function() {

  (function($) {
    var Plugin, defaults, pluginName;
    pluginName = 'framePreviewer';
    defaults = {
      numberOfColors: 20,
      prepend: true,
      previewerParent: 'body',
      previewerSibling: '',
      frameTypes: '',
      displayAltText: true,
      extraData: ''
    };
    Plugin = (function() {

      function Plugin(element, options) {
        this.element = element;
        this.options = $.extend({}, defaults, options);
        this._defaults = defaults;
        this._name = pluginName;
        this.init();
      }

      Plugin.prototype.init = function() {
        this.$parent = $(this.options.previewerParent);
        this.$offset = this.$parent.offset().top;
        if (this.options.previewerSibling) {
          this.$sibling = this.$parent.find(this.options.previewerSibling);
          this.$offset = this.$sibling.offset().top;
        }
        this.frameTypes = this.options.frameTypes.split(', ');
        this.renderPreviewer();
        return this.bindListEvent();
      };

      Plugin.prototype.renderPreviewer = function() {
        var colorList, frameTypes, html;
        frameTypes = this.createFrameTypes();
        colorList = this.createColorList();
        html = "<div id='fp_wrapper'>\n  <div id='fp_displayOptions'>\n    <div>\n      <h4>Select Frame:</h4>\n      <ul id='fp_frames'>\n        " + frameTypes + "\n      </ul>\n    </div>\n    <div>\n      <h4>Select Wall Color:</h4>\n      <ul id='fp_colorList'>\n        " + colorList + "\n      </ul>\n    </div>\n  </div>\n  <div id='fp_wallContainer'>\n    <div id='fp_frameContainer'>\n      <img alt=''>\n      <div class='fp_frame-tl'></div>\n      <div class='fp_frame-tm'></div>\n      <div class='fp_frame-tr'></div>\n      <div class='fp_frame-mr'></div>\n      <div class='fp_frame-br'></div>\n      <div class='fp_frame-bm'></div>\n      <div class='fp_frame-bl'></div>\n      <div class='fp_frame-ml'></div>\n    </div>\n  </div>\n</div>";
        if (this.$sibling) {
          this.$sibling.after(html);
        } else if (this.options.prepend) {
          this.$parent.prepend(html);
        } else {
          this.$parent.append(html);
        }
        this.cacheVariables();
        return this.bindPreviewerEvents();
      };

      Plugin.prototype.createFrameTypes = function() {
        var index, name, tmp, type, _i, _len, _ref;
        tmp = "<li><input type='radio' id='frame_none' value=0 name='fp_frameList'>      <label for='frame_none'>None</label></li>";
        _ref = this.frameTypes;
        for (index = _i = 0, _len = _ref.length; _i < _len; index = ++_i) {
          type = _ref[index];
          name = this.makeName(type);
          type = type.charAt(0).toUpperCase() + type.slice(1);
          tmp += "<li>\n<input name='fp_frameList' type='radio' id='frame_" + name + "' value='" + type + "'>\n<label for='frame_" + name + "'>" + type + "</label>\n</li>";
        }
        return tmp;
      };

      Plugin.prototype.createColorList = function() {
        var num, tmp, _i, _ref;
        tmp = '';
        for (num = _i = 1, _ref = this.options.numberOfColors; 1 <= _ref ? _i <= _ref : _i >= _ref; num = 1 <= _ref ? ++_i : --_i) {
          tmp += "<li class='fp_color" + num + "'><a href='#'>color " + num + "</a></li>";
        }
        return tmp;
      };

      Plugin.prototype.makeName = function(string) {
        return string.toLowerCase().replace(' ', '-');
      };

      Plugin.prototype.bindListEvent = function() {
        var that;
        that = this;
        return $(this.element).on('click', 'a', function(e) {
          var $img, data;
          e.preventDefault();
          $img = $(this).find('img');
          data = {
            src: $(this).attr('href')
          };
          if (that.options.displayAltText) {
            data.title = $img.attr('alt');
          }
          if (that.options.extraData) {
            data.extraData = $img.attr(that.options.extraData);
          }
          return that.preparePreviewer(data);
        });
      };

      Plugin.prototype.cacheVariables = function() {
        this.$wrapper = $('#fp_wrapper');
        this.$displayOptions = $('#fp_displayOptions');
        this.$frames = $('#fp_frames');
        this.$colorList = $('#fp_colorList');
        this.$wallContainer = $('#fp_wallContainer');
        this.$frameContainer = $('#fp_frameContainer');
      };

      Plugin.prototype.bindPreviewerEvents = function() {
        var that;
        that = this;
        that.$frames.on('change', 'input', function() {
          return that.$frameContainer.removeClass().addClass($(this).attr('id'));
        });
        return that.$colorList.on('click', 'a', function(e) {
          e.preventDefault();
          return that.$wallContainer.css('background-color', $(this).parent().css('background-color'));
        });
      };

      Plugin.prototype.preparePreviewer = function(data) {
        this.$wallContainer.css('background', 'none');
        this.$frameContainer.removeClass();
        this.$frames.find('input').find(':checked').prop('checked', false).end().first().prop('checked', true);
        this.$displayOptions.find('h3').remove().end().find('p').remove();
        if (data.title) {
          this.$displayOptions.append("<h3>" + data.title + "</h3>");
        }
        if (data.extraData) {
          this.$displayOptions.append("<p>" + data.extraData + "</p>");
        }
        this.$wrapper.find('img').attr('src', data.src);
        this.$wrapper.slideDown(700);
        return $('html, body').animate({
          scrollTop: this.$offset
        }, 700);
      };

      return Plugin;

    })();
    $.fn[pluginName] = function(options) {
      return this.each(function() {
        if (!$.data(this, "plugin_" + pluginName)) {
          return $.data(this, "plugin_" + pluginName, new Plugin(this, options));
        }
      });
    };
  })(jQuery);

}).call(this);

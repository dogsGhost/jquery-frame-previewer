#  Project: frame previewer
#  Author: David Wilhelm

(($) ->

  # Create the defaults once
  pluginName = 'framePreviewer'
  defaults =
    numberOfColors: 20 # Number of color options.
    prepend: true # Decides whether we prepend or append the previewer to an element, set to false to append.
    previewerParent: 'body' # The element we add the previewer html to.
    previewerSibling: '' # Overrides prepend. Looks for this element as a child of previewerParent and adds previewer html after it.
    frameTypes: '' # Names of different frame types. Seperate multiple names with commas. ex. 'one, two, three'
    displayAltText: true # Display the thumbnail's alt text as the image title in the previewer.
    extraData: '' # The data-attribute of any additional information you may want to display.

  # The plugin constructor
  class Plugin
    constructor: (@element, options) ->
      # Use extend to merge defaults with options.
      @options = $.extend {}, defaults, options
      @_defaults = defaults
      @_name = pluginName
      @init()

    init: ->
      @$parent = $(@options.previewerParent)

      # Set offset so we can scroll page to previewer.
      @$offset = @$parent.offset().top
      if @options.previewerSibling
        @$sibling = @$parent.find(@options.previewerSibling)
        @$offset = @$sibling.offset().top

      # Turn string into an array.
      @frameTypes = @options.frameTypes.split ', '

      @renderPreviewer()
      @bindListEvent()

    renderPreviewer: ->
      # Create html for previewer.
      frameTypes = @createFrameTypes()
      colorList = @createColorList()
      html = """
        <div id='fp_wrapper'>
          <div id='fp_displayOptions'>
            <div>
              <h4>Select Frame:</h4>
              <ul id='fp_frames'>
                #{frameTypes}
              </ul>
            </div>
            <div>
              <h4>Select Wall Color:</h4>
              <ul id='fp_colorList'>
                #{colorList}
              </ul>
            </div>
          </div>
          <div id='fp_wallContainer'>
            <div id='fp_frameContainer'>
              <img alt=''>
              <div class='fp_frame-tl'></div>
              <div class='fp_frame-tm'></div>
              <div class='fp_frame-tr'></div>
              <div class='fp_frame-mr'></div>
              <div class='fp_frame-br'></div>
              <div class='fp_frame-bm'></div>
              <div class='fp_frame-bl'></div>
              <div class='fp_frame-ml'></div>
            </div>
          </div>
        </div>
      """

      # Insert html onto page in correct place.
      if @$sibling
        @$sibling.after(html)
      else if @options.prepend
        @$parent.prepend(html)
      else
        @$parent.append html

      @bindPreviewerEvents()

    createFrameTypes: ->
      tmp = "<li><input type='radio' id='frame_none' value=0 name='fp_frameList'>
      <label for='frame_none'>None</label></li>"
      for type, index in @frameTypes
        name = @makeName type
        type = type.charAt(0).toUpperCase() + type.slice 1
        tmp += """
          <li>
          <input name='fp_frameList' type='radio' id='frame_#{name}' value='#{type}'>
          <label for='frame_#{name}'>#{type}</label>
          </li>
        """
      tmp

    createColorList: ->
      tmp = ''
      for num in [1..@options.numberOfColors]
        tmp += "<li class='fp_color#{num}'><a href='#'>color #{num}</a></li>"
      tmp

    makeName: (string) ->
      string.toLowerCase().replace ' ', '-'

    bindListEvent: ->
      # Maintain reference to our object.
      that = @

      # Occurs when a thumbnail is clicked.
      $(@element).on 'click', 'a', (e) -> 
        e.preventDefault()
        $img = $(@).find 'img'

        # Gather data to pass to previewer.
        data =
          src: $(@).attr 'href'
        if that.options.displayAltText
          data.title = $img.attr 'alt'
        if that.options.extraData
          data.extraData = $img.attr that.options.extraData

        # Pass data to be applied to previewer.
        that.preparePreviewer data

    bindPreviewerEvents: ->
      that = @

      # When a frame type is selected.
      $('#fp_frames').on 'change', 'input', ->
        $('#fp_frameContainer')
          .removeClass()
          .addClass $(@).attr('id')

      # When a color is selected
      $('#fp_colorList').on 'click', 'a', (e) ->
        e.preventDefault()

        $('#fp_wallContainer').css 'background-color', $(this).parent().css('background-color')


    preparePreviewer: (data) ->
      # Reset image previewer.
      $('#fp_wallContainer').css 'background-color', 'none'
      $('#fp_frameContainer').removeClass()
      $('#fp_displayOptions').find('h3').remove()
      
      # Add extra markup if needed.
      if data.title
        $('#fp_displayOptions').append "<h3>#{data.title}</h3>"
      if data.extraData
        $('#fp_displayOptions').append "<p>#{data.extraData}</p>"
      
      # Set the image for the previewer.
      $('#fp_wrapper')
        .find('img')
        .attr 'src', data.src

      # Show the previewer and scroll page to it.
      $('#fp_wrapper').slideDown 1000
      $('html, body').animate( {scrollTop: @$offset}, 900)

  $.fn[pluginName] = (options) ->
    @each ->
      if not $.data(@, "plugin_#{pluginName}")
        $.data @, "plugin_#{pluginName}", new Plugin(@, options)

  return

) jQuery
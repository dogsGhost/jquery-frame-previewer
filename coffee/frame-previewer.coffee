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
      # jQuery has an extend method which merges the contents of two or
      # more objects, storing the result in the first object. The first object
      # is generally empty as we don't want to alter the default options for
      # future instances of the plugin
      @options = $.extend {}, defaults, options
      @_defaults = defaults
      @_name = pluginName
      @init()

    init: ->
      @$parent = $(@options.previewerParent)
      if @options.previewerSibling
        @$sibling = @$parent.find(@options.previewerSibling)

      @frameTypes = @options.frameTypes.split ', '
      @renderPreviewer()
      $(@element).on 'click', 'a', (e) -> 
        e.preventDefault()
        console.log @options

    renderPreviewer: ->
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

      if @$sibling
        @$sibling.after(html)
      else if @options.prepend
        @$parent.prepend(html)
      else
        @$parent.append html

    createFrameTypes: ->
      tmp = '<li><a href="#">None</a></li>'
      for type, index in @frameTypes
        name = @makeClassName type
        type = type.charAt(0).toUpperCase() + type.slice 1
        tmp += "<li class='#{name}'><a href='#'>#{type}</a></li>"
      tmp

    createColorList: ->
      tmp = ''
      for num in [1..@options.numberOfColors]
        tmp += "<li class='fp_color-#{num}'><a href='#'>color #{num}</a></li>"
      tmp

    makeClassName: (string) ->
      string.toLowerCase().replace ' ', '-'

    getPreviewerData: (e) ->
      e.preventDefault()
      $img = $(@).find 'img'
      extraData = if Plugin.options.extraData then true else false

      # Gather data to pass to previewer.
      data =
        src: $(@).attr 'href'
      if Plugin.options.displayAltText
        data.title = $img.attr 'alt'
      if extraData
        data.extraData = $img.attr Plugin.options.extraData

      # Pass data to be applied to previewer.
      Plugin.preparePreviewer data

    preparePreviewer: (data) ->
      #if data.title
        # do stuff
      
      #if data.extraData
        # do stuff
      
      $('#fp_wrapper')
        .find('img')
        .attr data.src

      $('#fp_wrapper').slideDown()

  # A lightweight wrapper around the constructor,
  # preventing against multiple instantiations.
  $.fn[pluginName] = (options) ->
    @each ->
      if not $.data(@, "plugin_#{pluginName}")
        $.data @, "plugin_#{pluginName}", new Plugin(@, options)

  return

) jQuery
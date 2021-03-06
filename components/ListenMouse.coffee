noflo = require 'noflo'

# @runtime noflo-browser

class ListenMouse extends noflo.Component
  description: 'Listen to mouse events on a DOM element'
  constructor: ->
    @elements = []
    @inPorts =
      element: new noflo.Port 'object'
    @outPorts =
      click: new noflo.ArrayPort 'object'
      dblclick: new noflo.ArrayPort 'object'

    @inPorts.element.on 'data', (element) =>
      @subscribe element

  subscribe: (element) ->
    element.addEventListener 'click', @click, false
    element.addEventListener 'dblclick', @dblclick, false
    @elements.push element

  unsubscribe: ->
    for element in @elements
      element.removeEventListener 'click', @click, false
      element.removeEventListener 'dblclick', @dblclick, false
    @elements = []

  click: (event) =>
    return unless @outPorts.click.sockets.length
    event.preventDefault()
    event.stopPropagation()

    @outPorts.click.send event
    @outPorts.click.disconnect()
    do @updateIcon

  dblclick: (event) =>
    return unless @outPorts.dblclick.sockets.length
    event.preventDefault()
    event.stopPropagation()

    @outPorts.dblclick.send event
    @outPorts.dblclick.disconnect()
    do @updateIcon

  updateIcon: ->
    return unless @setIcon
    return if @timeout
    @originalIcon = @getIcon()
    @setIcon 'exclamation-circle'
    @timeout = setTimeout =>
      @setIcon @originalIcon
      @timeout = null
    , 200

  shutdown: ->
    @unsubscribe()

exports.getComponent = -> new ListenMouse

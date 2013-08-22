define (require) ->

  Context = require('pex/gl/Context')
  Mesh = require('pex/gl/Mesh')
  Color = require('pex/color/Color')
  PerspectiveCamera = require('pex/scene/PerspectiveCamera')

  class Scene
    currentCamera: -1
    clearColor: Color.BLACK
    clearDepth: true
    viewport: null
    constructor: () ->
      @meshes = []
      @cameras = []
      @gl = Context.currentContext.gl

    setClearColor: (color) ->
      @clearColor = color

    setClearDepth: (clearDepth) ->
      @clearDepth = clearDepth

    setViewport: (viewport) ->
      @viewport = viewport

    add: (obj) ->
      if (obj instanceof Mesh)
        @meshes.push(obj)
      if (obj instanceof PerspectiveCamera)
        @cameras.push(obj)

    clear: () ->
      clearBits = 0
      #TODO persist oldClearColorValue
      if @clearColor
        @gl.clearColor(@clearColor.r, @clearColor.g, @clearColor.b, @clearColor.a)
        clearBits |= @gl.COLOR_BUFFER_BIT
      if @clearDepth
        clearBits |= @gl.DEPTH_BUFFER_BIT
      if clearBits
        @gl.clear(clearBits)

    draw: (camera) ->
      if !camera
        if @currentCamera >= 0 && @currentCamera < @cameras.length
          camera = @cameras[@currentCamera]
        else if @cameras.length > 0
          camera = @cameras[0]
        else
          throw 'Scene.draw: missing a camera'

      if @viewport
        @viewport.bind()
        aspectRatio = @viewport.bounds.width / @viewport.bounds.height
        if camera.getAspectRatio() != aspectRatio
          camera.setAspectRatio(aspectRatio)

      @clear()

      for mesh in @meshes
        mesh.draw(camera)

      if @viewport
        @viewport.unbind()



{Animation} = require "Animated"

LazyVar = require "LazyVar"
Easing = require "easing"
gauss = require "gaussian-elimination"
Type = require "Type"

type = Type "ParabolicAnimation"

type.inherits Animation

type.defineOptions
  endValue: Number.isRequired
  velocity: Number.isRequired
  duration: Number.isRequired
  easing: Function

type.defineFrozenValues (options) ->

  endValue: options.endValue

  startVelocity: options.velocity

  duration: options.duration

  easing: options.easing

  _vertex: LazyVar => @_computeVertex()

  _velocity: LazyVar => @_computeVelocity @_easedTiming @time

type.defineValues

  progress: 0

  time: null

  value: null

  _coeff: null

#
# Prototype-related
#

type.defineGetters

  vertex: -> @_vertex.get()

  velocity: -> @_velocity.get()

type.defineMethods

  _valueAtTime: (dt) ->
    @_coeff[0] * Math.pow(dt / 1000, 2) +
    @_coeff[1] * (dt / 1000) +
    @_coeff[2]

  _easedTiming: (dt) ->
    return dt if not @easing
    return @duration * @easing dt / @duration

  _computeVelocity: (dt) ->
    2 * @_coeff[0] * (dt / 1000) + @_coeff[1]

  _computeVertex: ->
    # TODO: Add vertex formula

  _computeCoefficients: ->
    dt = @duration / 1000
    gauss [
      [0, 0, 1]
      [Math.pow(dt, 2), dt, 1]
      [0, 1, 0]
    ], [
      @startValue
      @endValue
      @startVelocity
    ]

type.overrideMethods

  __didStart: (config) ->
    @time = @startTime = Date.now()
    @value = @startValue = config.startValue
    @_coeff = @_computeCoefficients()
    @_requestAnimationFrame()

  __computeValue: ->
    @_velocity.reset()
    @time = Math.min @duration, Date.now() - @startTime
    @progress = @time / @duration
    return @value = @_valueAtTime @_easedTiming @time

  __didUpdate: (value) ->
    @finish() if @time is @duration

  __captureFrame: ->
    { @value, @velocity, @time, @progress }

module.exports = type.build()

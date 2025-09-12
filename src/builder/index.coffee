import * as Fn from "@dashkite/joy/function"
import * as Time from "@dashkite/joy/time"
import * as Obj from "@dashkite/joy/object"
import { metaclass } from "@dashkite/joy/metaclass"
import { Queue } from "@dashkite/joy/iterable"
import Generic from "@dashkite/generic"

start = ( reactor ) ->
  done = false
  while !done
    { value, done } = await reactor.next()
  value

builder = ( T ) ->

  class Builder extends metaclass()

    @_rulebases: []

    @rulebase: ( rulebase ) ->
      @_rulebases.push rulebase 
      @

    @rulebases: ( rulebases ) ->
      @_rulebases.push rulebases...
      @

    @make: ( input = {}) ->
      self = new @
      input.headers ?= {}
      self.update -> input
      self

    @getters
      rules: -> Fn.pipe @constructor._rulebases

    update: ( mutator ) ->
      @output = {}
      @input = mutator @input
      @
    
    get: ->
      @output = {}
      @errors = []
      @working = {}
      mulligan = true
      loop
        state = { @input, @output, @errors, @working }
        { @output, @errors, @working } = await start @rules.apply state
        if @errors.length == 0
          break
        else if mulligan
          mulligan = false
          @errors = []
        else
          # possibly aggregate errors?
          break
      throw @errors[0] if @errors.length > 0
      T.make @output

export default builder

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
      self.update -> input
      self

    @getters
      rules: -> Fn.pipe @constructor._rulebases
      state: -> { @input, @output, @errors, @working }

    constructor: ->
      super()
      @updates = Queue.make()
      @promises = []
      @start()

    start: ->
      for await { mutator, resolve, reject } from @updates
        @input = mutator @input
        @output = {}
        mulligan = true
        loop
          { @output, @errors, @working } = await start @rules.apply @state
          if @errors.length == 0
            resolve @output
            break
          else if mulligan
            mulligan = false
            @errors = []
          else
            # possibly aggregate errors?
            reject @errors[0]
            break
          
    update: ( mutator ) ->
      { promise, rest... } = Promise.withResolvers()
      @promises.push promise
      @updates.enqueue { mutator, rest... }
    
    get: ->
      promises = @promises
      @promises = []
      ( output = await promise ) for promise in promises
      T.make output

export default builder

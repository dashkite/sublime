import { metaclass } from "@dashkite/joy/metaclass"

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
      rules: ->
        rulebases = @constructor._rulebases
        start: ( state, options = {} ) ->
          reactor = options.delegator
          for rulebase in rulebases
            reactor = rulebase.start state, { options..., delegator: reactor }
          reactor
        run: ( state, options = {} ) ->
          for rulebase in rulebases
            state = await rulebase.run state, options
          state

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
        { @output, @errors, @working } = await @rules.run state
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

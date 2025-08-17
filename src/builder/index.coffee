import * as Fn from "@dashkite/joy/function"
import { metaclass } from "@dashkite/joy/metaclass"
import { Queue } from "@dashkite/joy/iterable"
import Generic from "@dashkite/generic"

builder = ->

  class Builder extends metaclass()

    @rules: []

    @rulebase: do ->

      ( Generic.make "Builder.rulebase" )
      
        .define [ Function ], ( rulebase ) ->
          @rules.push rulebase
          @
        
        .define [ Array ], ( rulebases ) -> 
          @rules.push rulebases...
          @

    @produces: ( @_produces ) ->

    @validator: ( @_validator ) ->

    @make: ( input = {}) ->
      self = new @
      self.update -> input
      self

    constructor: ->
      super()
      @updates = Queue.make()
      @promises = []
      @rules = Fn.pipe [ @constructor.rules..., @constructor._validator ]
      @start()

    start: ->
      for await { mutator, resolve, reject } from @updates
        @input = mutator @input
        @output = {}
        try
          await @rules.apply @
          resolve @output
        catch error
          reject error

    update: ( mutator ) ->
      { promise, rest... } = Promise.withResolvers()
      @promises.push promise
      @updates.enqueue { mutator, rest... }
    
    get: ->
      promises = @promises
      @promises = []
      [ ..., output ] = await Promise.all promises
      @constructor._produces.make output

export default builder

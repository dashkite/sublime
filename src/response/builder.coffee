import * as Fn from "@dashkite/joy/function"
import { metaclass } from "@dashkite/joy/metaclass"
import { Queue } from "@dashkite/joy/iterable"

import rulebase from "./rulebase"
import validate from "./validate"
import Value from "./value"

class Builder extends metaclass()

  @rules: [ rulebase ]

  @rulebase: ( rulebase ) ->
    @rules.push rulebase
    @

  @make: ( input = {}) ->
    self = new @
    self.update -> input
    self

  constructor: ->
    super()
    @updates = Queue.make()
    @promises = []
    @rules = Fn.pipe [ @constructor.rules..., validate ]
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
    Value.make output

export default Builder

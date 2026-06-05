import * as Type from "@dashkite/joy/type"
import * as Time from "@dashkite/joy/time"
import Athena from "@dashkite/athena"
import Registry from "@dashkite/registry"

import { MutableFields } from "#fields"
import State from "#state"
import clone from "#helpers/clone"
import equal from "#helpers/equal"

rules = Athena.make

  initialize: ( state ) -> State.make state

  clone: ( state ) -> state.clone()

  equal: ( a, b ) -> a.equal b

rules

  .condition
    name: "has a url"
    run: -> @input.url?

  .condition
    name: "url is text"
    when: [ "has a url" ]
    run: -> Type.isString @input.url

  .condition
    name: "url is of type url"
    when: [ "has a url" ]
    run: -> Type.isKind URL, @input.url

  .condition
    name: "url ready"
    run: -> @output.url?

  .condition
    name: "valid url"
    when: [ "url ready" ]
    run: -> 
      try
        ( new URL @output.url )
        true
      catch
        false

  .condition
    name: "has an origin"
    run: -> @input.origin?

  .condition
    name: "has a method"
    run: -> @input.method?

  .condition
    name: "headers ready"
    run: -> @output.headers?

  .condition
    name: "has content"
    run: -> @input.content?

  .condition
    name: "content ready"
    run: -> @output.content?

  .condition
    name: "has authorization"
    run: -> 
      @input.authorization? || @working.authorization?

  .condition
    name: "authorization is well-formed"
    when: [ "has authorization" ]
    run: ->
      Type.isArray ( @input.authorization ? @working.authorization )

  .condition
    name: "authorization header ready"
    when: [ "headers ready" ]
    run: ->
      ( @working.headers?.get "authorization" )?

  .action
    name: "set the url"
    when: [ "url is text" ]
    run: -> @output.url = @input.url
  
  .action
    name: "convert url to text"
    when: [ "url is of type url" ]
    run: ->  @output.url = @input.url.toString()
  
  .action
    name: "construct url from constituents"
    when: [ "has an origin" ]
    run: ->
      url = new URL ( @input.target ? "/" ), @input.origin
      url.search = new URLSearchParams @input.query
      @output.url = url.href

  .action
    name: "set method"
    when: [ "has a method" ]
    run: -> @output.method = @input.method.toLowerCase()
  
  .action
    name: "set default method"
    when: [ "!has a method", "!has content" ]
    run: -> @output.method = "get"
  
  .action
    name: "set headers"
    when: [ "!headers ready" ]
    run: ->
      @working.headers ?= MutableFields.make ( @input.headers ? {})
      @output.headers = @working.headers.data
      
  .action
    name: "set authorization header"
    when: [ 
      "!authorization header ready"
      "authorization is well-formed" 
    ]
    run: ->
      authorizers = await Registry.get "authorizers"
      context = { url: @output.url, method: @output.method }
      # normalize specifier: can be text (the scheme) or a challenge 
      # (has a `scheme` property) or challenge and query
      specifiers = ( @input.authorization ? @working.authorization )
        .map ( value ) ->
          if value.challenge?
            value
          else if value.scheme?
            challenge: value
          else
            challenge: 
              scheme: value
        .map ({ query, rest... }) -> { rest..., query: { query..., context... }}
      if ( authorization = await authorizers.authorization specifiers )?
        @working.headers.set "authorization", authorization
        @output.headers = @working.headers.data
  
  .action
    name: "throw ill-formed authorization"
    when: [ 
      "has authorization"
      "!authorization is well-formed"
    ]
    run: ->
      @throw new Error "sublime: ill-formed authorization"

  .action
    name: "throw unsupported url value"
    when: [
      "!url is text"
      "!url is of type url" 
    ]
    run: ->
      @throw new Error "sublime: unsupported url value"

  .action
    name: "throw missing url value"
    when: [ "!url ready" ]
    run: ->
      @throw new Error "sublime: missing url value"
  
  .action
    name: "throw invalid url"
    when: [ "!valid url" ]
    run: ->
      @throw new Error "sublime: invalid url"

  .action
    name: "throw missing method"
    when: [ "!has a method", "has content" ]
    run: ->
      @throw new Error "sublime: missing method"

export default rules  
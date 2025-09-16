import * as Type from "@dashkite/joy/type"
import * as Time from "@dashkite/joy/time"
import { MediaType } from "@dashkite/media-type"
import Athena from "@dashkite/athena"
import Registry from "@dashkite/registry"

import { MutableFields } from "#fields"
import State from "#state"
import clone from "#helpers/clone"
import equal from "#helpers/equal"

rulebase = Athena.make

  initialize: ( state ) -> State.make state

  clone: ( state ) -> state.clone()

  equal: ( a, b ) -> a.equal b

rulebase.conditions

  "has a url": -> @input.url?

  "url is text": -> Type.isString @input.url

  "url is of type url": -> Type.isKind URL, @input.url

  "url ready": -> @output.url?

  "valid url": -> 
    try
      ( new URL @output.url )
      true
    catch
      false

  "has an origin": -> @input.origin?

  "has a method": -> @input.method?

  "headers ready": -> @output.headers?

  "has content": -> @input.content?

  "has authorization": -> 
    @input.authorization? || @working.authorization?

  "authorization header ready": ->
    ( @working.headers?.get "authorization" )?

rulebase.actions
  
  "set the url": -> @output.url = @input.url
  
  "convert url to text": ->  @output.url = @input.url.toString()
  
  "construct url from constituents": ->
    url = new URL ( @input.target ? "/" ), @input.origin
    url.search = new URLSearchParams @input.query
    @output.url = url.href
  
  "set method": -> @output.method = @input.method.toLowerCase()
  
  "set default method": -> @output.method = "get"
  
  "set headers": ->
    @working.headers ?= MutableFields.make ( @input.headers ? {} )
    @output.headers = @working.headers.data
    
  "serialize content": -> 
    @output.content = MediaType.serialize type, @input.content

  "set authorization header": ->
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
  
  "throw unsupported url value": ->
    @throw new Error "sublime: unsupported url value"

  "throw missing url value": ->
    @throw new Error "sublime: missing url value"
  
  "throw invalid url": ->
    @throw new Error "sublime: invalid url"

  "throw missing method": ->
    @throw new Error "sublime: missing method"

rulebase.rules

  "url is text": [ "has a url" ]

  "url is of type url": [ "has a url" ]

  "valid url": [ "url ready" ]
  
  "set the url": [ "url is text" ]
  
  "convert url to text": [ "url is of type url" ]
  
  "construct url from constituents": [ "has an origin" ]
  
  "set method": [ "has a method" ]
  
  "set default method": [ "!has a method", "!has content" ]
  
  "set headers": [ "!headers ready" ]

  "authorization header ready": [ "headers ready" ]

  "set authorization header": [ 
    "!authorization header ready"
    "has authorization" 
  ]
    
  "throw unsupported url value": [
    "!url is text"
    "!url is of type url" 
  ]

  "throw missing url value": [ "!url ready" ]

  "throw invalid url": [ "!valid url" ]

  "throw missing method": [ "!has a method", "has content" ]

export default rulebase
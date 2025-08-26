import * as Type from "@dashkite/joy/type"
import * as Time from "@dashkite/joy/time"
import { MediaType } from "@dashkite/media-type"
import Rulebase from "@dashkite/athena"

import Headers from "#headers/canonical"

import State from "#state"

rulebase = Rulebase.make

  initialize: ( state ) -> State.make state

  clone: ( state ) -> state.clone()

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

  "has headers": -> @input.headers?

  "has content": -> @input.content?

  "has content-type": -> @output.headers?.get "content-type"

  "headers ready": -> @output.headers?

rulebase.actions
  
  "set the url": -> @output.url = @input.url
  
  "convert url to text": ->  @output.url = @input.url.toString()
  
  "construct url from constituents": ->
    url = new URL ( @input.target ? "/" ), @input.origin
    url.search = new URLSearchParams @input.query
    @output.url = url.href
  
  "set the method": -> @output.method = @input.method.toLowerCase()
  
  "set a default method": -> @output.method = "get"
  
  "set headers": -> @output.headers = ( Headers.from @input.headers )
  
  "set empty headers": -> @output.headers = Headers.make()
  
  "serialize content": -> 
    @output.content = MediaType.serialize type, @input.content
  
  "throw unsupported url value": ->
    @throw new Error "sublime: unsupported url value"

  "throw missing url value": ->
    @throw new Error "sublime: missing url value"
  
  "throw invalid url": ->
    @throw new Error "sublime: invalid url"

rulebase.rules
  
  "set the url": [ "has a url", "url is text" ]
  
  "convert url to text": [ "has a url", "url is of type url" ]
  
  "construct url from constituents": [ "has an origin" ]
  
  "set the method": [ "has a method" ]
  
  "set a default method": [ "!has a method", "!has content" ]
  
  "set headers": [ "has headers" ]
  
  "set empty headers": [ "!has headers" ]
  
  "throw unsupported url value": [
    "has a url"
    "!url is text"
    "!url is of type url" 
  ]

  "throw missing url value": [ "!has a url", "!url ready" ]

  "throw invalid url": [ "url ready", "!valid url" ]

export default rulebase
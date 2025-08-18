import * as Type from "@dashkite/joy/type"
import * as Time from "@dashkite/joy/time"
import { MediaType } from "@dashkite/media-type"
import Rulebase from "@dashkite/athena"

import Headers from "#headers/canonical"

rulebase = Rulebase.make

  clone: ({ input, output, state... }) ->
    {
      input: structuredClone input
      output: structuredClone output
      state...
    }

rulebase.conditions

  "has a url": -> @input.url?

  "url is text": -> Type.isString @input.url

  "url is of type url": -> Type.isKind URL, @input.url

  "has an origin": -> @input.origin?

  "has a method": -> @input.method?

  "has headers": -> @input.headers?

  "has content": -> @input.content?

  "has content-type": -> @output.headers?[ "content-type" ]

  "content is unserialized": -> @input.serialized != true

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
  
  "set headers": -> @output.headers = ( Headers.from @input.headers ).data
  
  "set empty headers": -> @output.headers = Headers.make().data
  
  "serialize content": -> 
    @output.content = MediaType.serialize type, @input.content
  
  "infer content-type": ->
    type = MediaType.fromValue @input.content
    @output.headers[ "content-type" ] = MediaType.format type
  
  "remove content headers": ->
    for key, value of @output.headers
      if key.startsWith "content-"
          delete @output.headers[ key ]
  
rulebase.rules
  
  "set the url": [ "has a url", "url is text" ]
  
  "convert url to text": [ "has a url", "url is of type url" ]
  
  "construct url from constituents": [ "has an origin" ]
  
  "set the method": [ "has a method" ]
  
  "set a default method": [ "!has a method", "!has content" ]
  
  "set headers": [ "has headers" ]
  
  "set empty headers": [ "!has headers"]
  
  "infer content-type": [
    "headers ready"
    "has content"
    "!has content-type" 
  ]
  
  "remove content headers": [ "headers ready", "!has content" ]

run = ->
  Object.assign @, await rulebase.apply @
  yield name: "validate"

export default run
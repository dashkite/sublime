import * as Type from "@dashkite/joy/type"
import Rulebase from "@dashkite/athena"
import State from "./state"

rulebase = Rulebase.make

  initialize: ( state ) -> State.make state

  clone: ( state ) -> state.clone()

rulebase.conditions
  
  "has content": -> @input.content?
  
  "has content-type": -> 
    ( @output.headers?.get "content-type" )?
  
  "is acceptable": ->
    accept = ( @output.request?.headers.get "accept" )
    if accept?
      accept.supported @[ "content-type" ]
    else true
  
  "headers ready": -> @output.headers?

  "content ready": -> @output.content?

  "content is text": -> Type.isString @input.content

  "content is bytes": -> ArrayBuffer.isView @input.content

  "content-type is binary": ->
    { type, subtype, mime } = @[ "content-type" ]
    ( /(image|audio|video)/.test type ) ||
      ( /(image|audio|video)/.test mime?.type ) ||
      ( subtype == "octet-stream" ) ||
      ( mime?.subtype == "octet-stream" )

  "content-type is json": ->
    { subtype, mime } = @[ "content-type" ]
    ( subtype == "json" ) || ( mime.subtype == "json" )

  "content ready": -> @output.content?

rulebase.actions

  "not acceptable": ->
    @throw new Error "sublime: attempt to construct
      an unacceptable response"

  "set text content": ->
    @output.content = @input.content
    
  # should we try to put this into an appropriate 
  # container, ex: Blob
  "set binary content": ->
    @output.content = @input.content

  "serialize bytes": ->
    decoder = new TextDecoder @charset 
    @output.content = decoder.decode new Uint8Array @input.content
      
  "serialize to json": ->
    JSON.stringify @input.content

  "unable to serialize": ->
    @throw new Error "sublime: unable to serialize content"

  "set content-length": -> 
    @output.headers.set "content-length", 
      @output.content.length

  "remove content headers": ->
    for [ key, value ] from @output.headers
      if key.startsWith "content-"
          @output.headers.remove key
    
rulebase.rules
    
  "not acceptable": [
    "headers ready"
    "has content-type"
    "!is acceptable"
  ]

  "remove content headers": [
    "!has content"
    "headers ready"
  ]

  "set text content": [
    "has content"
    "headers ready"
    "has content-type"
    "is acceptable"
    "content is text"
  ]

  "set binary content": [
    "has content"
    "headers ready"
    "has content-type"
    "is acceptable"
    "content is bytes"
  ]

  "serialize bytes": [
    "has content"
    "headers ready"
    "has content-type"
    "is acceptable"
    "content is bytes"
    "!content-type is binary"
  ]

  "serialize to json": [
    "has content"
    "headers ready"
    "has content-type"
    "is acceptable"
    "!content is text"
    "!content is bytes"
    "content-type is json"
  ]

  "set content-length": [
    "headers ready"
    "content ready"
  ]

export default rulebase
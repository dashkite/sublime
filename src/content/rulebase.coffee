import * as Type from "@dashkite/joy/type"
import Athena from "@dashkite/athena"

import clone from "#helpers/clone"
import equal from "#helpers/equal"

import State from "#state"

rulebase = Athena.make

  initialize: ( state ) -> State.make state

  clone: ( state ) -> state.clone()

  equal: ( a, b ) -> a.equal b

rulebase.conditions
  
  "has content": -> @input.content?
  
  "has content-type": -> 
    ( @working.headers?.get "content-type" )?
  
  "is acceptable": ->
    accept = ( @working.request?.headers.get "accept" )
    if accept?
      accept.supported ( @working.headers.get  "content-type" )
    else true
  
  "headers ready": -> @output.headers?

  "content is text": -> 
    Type.isString @input.content

  "content is bytes": -> ArrayBuffer.isView @input.content

  "content-type is binary": ->
    { type, subtype, mime } = ( @working.headers.get  "content-type" )
    ( /(image|audio|video)/.test type ) ||
      ( /(image|audio|video)/.test mime?.type ) ||
      ( subtype == "octet-stream" ) ||
      ( mime?.subtype == "octet-stream" )

  "content-type is json": ->
    { subtype, mime } = ( @working.headers.get  "content-type" )
    ( subtype == "json" ) || ( mime?.subtype == "json" )

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
    charset = ( @working.headers.get  "content-type" )
      ?.parameters?.charset ? "utf-8"
    decoder = new TextDecoder charset 
    @output.content = decoder.decode new Uint8Array @input.content
      
  "serialize to json": ->
    try
      @output.content = JSON.stringify @input.content
    catch
      @output.content = @input.content

  "unable to serialize": ->
    @throw new Error "sublime: unable to serialize content"

  "set content-length": -> 
    @working.headers.set "content-length", @output.content.length
    @output.headers = @working.headers.data

  "remove content headers": ->
    for [ key, value ] from @working.headers
      if key.startsWith "content-"
          @output.headers.remove key
    @output.headers = @working.headers.data
    
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
    "content-type is json"
    "is acceptable"
    "!content is text"
    "!content is bytes"
  ]

  "set content-length": [
    "headers ready"
    "content ready"
  ]

export default rulebase
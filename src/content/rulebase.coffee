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
    if ( accept = ( @working.request?.headers.get "accept" ))?
      accept.supported ( @working.headers.get "content-type" )
    else true
  
  "content is text": -> 
    Type.isString @input.content

  "content is bytes": -> ArrayBuffer.isView @input.content

  "content is binary": ->
    ( ArrayBuffer.isView @input.content ) ||
      ( Type.isKind ArrayBuffer, @input.content ) ||
      ( Type.isKind Blob, @input.content )

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
  
  "headers ready": -> @output.headers?

rulebase.actions

  "not acceptable": ->
    @throw new Error "sublime: unacceptable response"

  "set default content type to text/plain": ->
    @working.headers.set "content-type", "text/plain"
    @output.headers = @working.headers.data

  "set default content type to application/json": ->
    @working.headers.set "content-type", "application/json"
    @output.headers = @working.headers.data

  "set default content type to application/octet-stream": ->
    @working.headers.set "content-type", "application/octet-stream"
    @output.headers = @working.headers.data

  "set text content": -> @output.content = @input.content
    
  # should we try to put this into an appropriate 
  # container, ex: Blob
  "set binary content": -> @output.content = @input.content

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

  # We don't need to set the content-length
  # https://developer.mozilla.org/en-US/docs/Web/HTTP/Reference/Headers/Content-Length
  #
  # > In HTTP/2, Content-Length is redundant, because the
  # > content length may be inferred from DATA frames. It
  # > may still be included for backwards compatibility.
  #
  # We do it anyway for backwards compatibility. We set it
  # based on the output content which is normalized to
  # bytes. The `content-length` is the length in bytes, not
  # the length of string.

  "set content-length": -> 
    @working.headers.set "content-length", @output.content.length
    @output.headers = @working.headers.data

  "remove content headers": ->
    for [ key, value ] from @working.headers
      if key.startsWith "content-"
          @working.headers.remove key
    @output.headers = @working.headers.data
    
rulebase.rules

  "has content-type": [ "headers ready" ]

  "is acceptable": [ "has content-type" ]

  "content-type is json": [ "has content-type" ]

  "content-type is binary": [ "has content-type" ]
    
  "not acceptable": [ "!is acceptable" ]

  "set default content type to text/plain": [
    "!has content-type"
    "content is text"
  ]

  "set default content type to application/json": [
    "!has content-type"
    "!content is text"
    "!content is binary"
  ]

  "set default content type to application/octet-stream": [
    "!has content-type"
    "!content is text"
    "content is binary"
  ]

  "remove content headers": [
    "!has content"
    "headers ready"
  ]

  "set text content": [
    "has content"
    "is acceptable"
    "content is text"
  ]

  "set binary content": [
    "has content"
    "is acceptable"
    "content is bytes"
  ]

  "serialize bytes": [
    "has content"
    "is acceptable"
    "content is bytes"
    "!content-type is binary"
  ]

  "serialize to json": [
    "has content"
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
import * as Type from "@dashkite/joy/type"
import Athena from "@dashkite/athena"

import clone from "#helpers/clone"
import equal from "#helpers/equal"

import State from "#state"

rules = Athena.make

  initialize: ( state ) -> State.make state

  clone: ( state ) -> state.clone()

  equal: ( a, b ) -> a.equal b

rules

  .condition [
    "has content"
    -> @input.content?
  ]
  
  .condition [
    "has content-type"
    [ "headers ready" ]
    -> ( @working.headers?.get "content-type" )?
  ]

  .condition [
    "is acceptable"
    [ "has content-type" ]
    ->
      if ( accept = ( @working.request?.headers.get "accept" ))?
        accept.supported ( @working.headers.get "content-type" )
      else true
  ]
  
  .condition [
    "content is text"
    [ "has content" ]
    -> Type.isString @input.content
  ]

  .condition [
    "content is bytes"
    [ "has content" ]
    -> ArrayBuffer.isView @input.content
  ]

  .condition [
    "content is binary"
    [ "has content" ]
    ->
      ( Type.isKind ArrayBuffer, @input.content ) ||
      ( Type.isKind Blob, @input.content )
  ]

  .condition [
    "content-type is binary"
     [ "has content-type" ]
    ->
      { type, subtype, mime } = ( @working.headers.get "content-type" )
      ( /(image|audio|video)/.test type ) ||
        ( /(image|audio|video)/.test mime?.type ) ||
        ( subtype == "octet-stream" ) ||
        ( mime?.subtype == "octet-stream" )
  ]

  .condition [
    "content-type is json"
    [ "has content-type" ]
    ->
      { subtype, mime } = ( @working.headers.get "content-type" )
      ( subtype == "json" ) || ( mime?.subtype == "json" )
  ]

  .condition [
    "content ready"
    -> @output.content?
  ]

  .condition [
    "headers ready"
    -> @output.headers?
  ]

  .action [
    "not acceptable"
    [ "!is acceptable" ]
    -> @throw new Error "sublime: unacceptable response"
  ]

  .action [
    "set default content type to text/plain"
    [
      "!has content-type"
      "content is text"
    ]
    ->
      @working.headers.set "content-type", "text/plain"
      @output.headers = @working.headers.data
  ]

  .action [
    "set default content type to application/json"
    [
      "!has content-type"
      "!content is text"
      "!content is binary"
    ]
    ->
      @working.headers.set "content-type", "application/json"
      @output.headers = @working.headers.data    
  ]

  .action [
    "set default content type to application/octet-stream"
    [
      "!has content-type"
      "!content is text"
      "content is binary"
    ]
    ->
      @working.headers.set "content-type", "application/octet-stream"
      @output.headers = @working.headers.data
  ]

  .action [
    "set text content"
    [
      "content is text"
      "is acceptable"
    ]
    -> @output.content = @input.content
  ]

  # should we try to put this into an appropriate 
  # container, ex: Blob
  .action [
    "set binary content"
    [
      "has content"
      "is acceptable"
      "content is bytes"
    ]
    -> @output.content = @input.content
  ]

  .action [
    "serialize to bytes"
    [
      "has content"
      "is acceptable"
      "content is bytes"
      "!content-type is binary"
    ]
    ->
      charset = ( @working.headers.get  "content-type" )
        ?.parameters?.charset ? "utf-8"
      decoder = new TextDecoder charset 
      @output.content = decoder.decode new Uint8Array @input.content
  ]

  .action [
    "serialize to json"
    [
      "has content"
      "content-type is json"
      "is acceptable"
      "!content is text"
      "!content is bytes"
    ]
    ->
      try
        @output.content = JSON.stringify @input.content
      catch
        @output.content = @input.content
  ]

  # see ./notes re: content-length
  .action [
    "set content-length"
    [
      "headers ready"
      "content ready"
    ]
    -> 
      @working.headers.set "content-length", @output.content.length
      @output.headers = @working.headers.data
  ]

  .action [
    "remove content headers"
    [
      "!has content"
      "headers ready"
    ]
    ->
      for [ key, value ] from @working.headers
        if key.startsWith "content-"
            @working.headers.remove key
      @output.headers = @working.headers.data
  ]

export default rules
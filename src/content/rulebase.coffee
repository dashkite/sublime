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

  .condition
    name: "has content"
    run: -> @input.content?
  
  .condition
    name: "has content-type"
    when: [ "headers ready" ]
    run: -> ( @working.headers?.get "content-type" )?

  .condition
    name: "is acceptable"
    when: [ "has content-type" ]
    run: ->
      if ( accept = ( @working.request?.headers.get "accept" ))?
        accept.supported ( @working.headers.get "content-type" )
      else true
  
  .condition
    name: "content is text"
    when: [ "has content" ]
    run: -> Type.isString @input.content

  .condition
    name: "content is bytes"
    when: [ "has content" ]
    run: -> ArrayBuffer.isView @input.content

  .condition
    name: "content is binary"
    when: [ "has content" ]
    run: ->
      ( Type.isKind ArrayBuffer, @input.content ) ||
      ( Type.isKind Blob, @input.content )

  .condition
    name: "content-type is binary"
    when: [ "has content-type" ]
    run: ->
      { type, subtype, mime } = ( @working.headers.get "content-type" )
      ( /(image|audio|video)/.test type ) ||
        ( /(image|audio|video)/.test mime?.type ) ||
        ( subtype == "octet-stream" ) ||
        ( mime?.subtype == "octet-stream" )

  .condition
    name: "content-type is json"
    when: [ "has content-type" ]
    run: ->
      { subtype, mime } = ( @working.headers.get "content-type" )
      ( subtype == "json" ) || ( mime?.subtype == "json" )

  .condition
    name: "content ready"
    run: -> @output.content?

  .condition
    name: "headers ready"
    run: -> @output.headers?

  .action
    name: "not acceptable"
    when: [ "!is acceptable" ]
    run: -> @throw new Error "sublime: unacceptable response"

  .action
    name: "set default content type to text/plain"
    when: [
      "!has content-type"
      "content is text"
    ]
    run: ->
      @working.headers.set "content-type", "text/plain"
      @output.headers = @working.headers.data

  .action
    name: "set default content type to application/json"
    when: [
      "!has content-type"
      "!content is text"
      "!content is binary"
    ]
    run: ->
      @working.headers.set "content-type", "application/json"
      @output.headers = @working.headers.data    

  .action
    name: "set default content type to application/octet-stream"
    when: [
      "!has content-type"
      "!content is text"
      "content is binary"
    ]
    run: ->
      @working.headers.set "content-type", "application/octet-stream"
      @output.headers = @working.headers.data

  .action
    name: "set text content"
    when: [
      "content is text"
      "is acceptable"
    ]
    run: -> @output.content = @input.content

  # should we try to put this into an appropriate 
  # container, ex: Blob
  .action
    name: "set binary content"
    when: [
      "has content"
      "is acceptable"
      "content is bytes"
    ]
    run: -> @output.content = @input.content

  .action
    name: "serialize to bytes"
    when: [
      "has content"
      "is acceptable"
      "content is bytes"
      "!content-type is binary"
    ]
    run: ->
      charset = ( @working.headers.get  "content-type" )
        ?.parameters?.charset ? "utf-8"
      decoder = new TextDecoder charset 
      @output.content = decoder.decode new Uint8Array @input.content

  .action
    name: "serialize to json"
    when: [
      "has content"
      "content-type is json"
      "is acceptable"
      "!content is text"
      "!content is bytes"
    ]
    run: ->
      try
        @output.content = JSON.stringify @input.content
      catch
        @output.content = @input.content

  # see ./notes re: content-length
  .action
    name: "set content-length"
    when: [
      "headers ready"
      "content ready"
    ]
    run: -> 
      @working.headers.set "content-length", @output.content.length
      @output.headers = @working.headers.data

  .action
    name: "remove content headers"
    when: [
      "!has content"
      "headers ready"
    ]
    run: ->
      for [ key, value ] from @working.headers
        if key.startsWith "content-"
            @working.headers.remove key
      @output.headers = @working.headers.data

export default rules

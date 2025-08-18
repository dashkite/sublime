import { MediaType, Accept } from "@dashkite/media-type"
import Rulebase from "@dashkite/athena"

import Request from "#request"
import Headers from "#headers/canonical"

import Status from "./status"

rulebase = Rulebase.make

  clone: ({ input, output, state... }) ->
    {
      input: structuredClone input
      output: structuredClone output
      state...
    }

rulebase.conditions

  "has request": -> @input.request?

  "has status": -> @input.status?
  
  "has description": -> @input.description?

  "has headers": -> @input.headers?

  "has content": -> @input.content?

  "content ready": -> @output.content?

  "headers ready": -> @output.headers?

  # we lose the request type when cloning, so the headers
  # getter is not there
  "has accept": -> ( @output.request?.output.headers[ "accept" ])?

  "has content type": -> @output.headers?[ "content-type" ]?

  # we lose the request type when cloning, so the headers
  # getter is not there
  "is acceptable": ->
    accept = Accept.parse @output.request?.output.headers[ "accept" ]
    ( Accept.selectByContent @input.content, accept )?

rulebase.actions

  "set request": ->
    @output.request ?= await Request
      .make @input.request
      .get()

  "set status": -> @output.status = Status.from @input.status

  "set status from description": ->
    @output.status = Status.from @input.description

  "infer status ok": -> @output.status = 200

  "infer status no content": -> @output.status = 204

  "set headers": -> @output.headers ?= ( Headers.from @input.headers ).data
  
  "set empty headers": -> @output.headers ?= Headers.make().data
  
  # we lose the request type when cloning, so the headers
  # getter is not there
  "infer content type from accept": ->
    accept = Accept.parse @output.request.output.headers[ "accept" ]
    if ( selected = Accept.selectByContent @input.content, accept )?
      @output.headers[ "content-type" ] = MediaType.format selected

  "infer content type from content": ->
    type = MediaType.fromValue @input.content
    @output.headers[ "content-type" ] = MediaType.format type

  "unsupported media type": -> 
    @output.status = 415
    delete @output.content

  "serialize content": ->
    type = @output.headers[ "content-type" ]
    @output.content = MediaType.serialize type, @input.content

  "set content length": ->
    @output.headers[ "content-length" ] = @output.content.length

  "remove content headers": ->
    for key, value of @output.headers
      if key.startsWith "content-"
        delete @output.headers[ key ]

rulebase.rules


  "set request": [ "has request" ]

  "set status": [ "has status" ]

  "set status from description": [ "!has status", "has description" ]

  "infer status ok": [
    "!has status"
    "!has description"
    "has content" 
  ]

  "infer status no content": [
    "!has status"
    "!has description"
    "!has content" 
  ]

  "set headers": [ "has headers" ]
  
  "set empty headers": [ "!has headers"]

  "infer content type from accept": [ 
    "has content"
    "headers ready"
    "!has content type" 
    "has accept"
  ]

  "infer content type from content": [
    "has content"
    "headers ready"
    "!has content type" 
    "!has accept"
  ]

  "unsupported media type": [
    "headers ready"
    "has content"
    "has accept"
    "!is acceptable"
  ]

  "serialize content": [
    "has content"
    "headers ready"
    "has content type"
  ]

  "set content length": [
    "headers ready"
    "content ready"
  ]

  "remove content headers": [
    "headers ready"
    "!has content"
  ]

run = ->
  { input, output } = @
  { intput, output } = await rulebase.apply { input, output }
  # console.log { input, output }
  Object.assign @, { input, output }
  yield name: "validate"

export default run
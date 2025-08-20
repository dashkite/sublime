import { MediaType, Accept } from "@dashkite/media-type"
import Rulebase from "@dashkite/athena"

import Request from "#request"
import Headers from "#headers/canonical"

import Status from "./status"

rulebase = Rulebase.make

  clone: ( state ) -> state.clone()

rulebase.conditions

  "has request": -> @input.request?

  "has status": -> @input.status?
  
  "has description": -> @input.description?

  "has headers": -> @input.headers?

  "has content": -> @input.content?

  "content ready": -> @output.content?

  "headers ready": -> @output.headers?

  "has accept": -> ( @output.request?.headers.get "accept" )?

  "has content type": -> @output.headers?[ "content-type" ]?

  "is acceptable": ->
    accept = @output.request.headers.get "accept"
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
  
  "infer content type from accept": ->
    accept = @output.request.headers.get "accept"
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
  
  "set empty headers": [ "!has headers" ]

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

export default rulebase
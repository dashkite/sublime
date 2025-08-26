import { MediaType, Accept } from "@dashkite/media-type"
import Rulebase from "@dashkite/athena"

import Request from "#request"
import Headers from "#headers/canonical"

import State from "./state"
import Status from "./status"

rulebase = Rulebase.make

  initialize: ( state ) -> State.make state

  clone: ( state ) -> state.clone()

rulebase.conditions

  "has request": -> @input.request?

  "has status": -> @input.status?
  
  "has description": -> @input.description?

  "has headers": -> @input.headers?

  "has content": -> @input.content?

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

  "set headers": -> @output.headers ?= ( Headers.from @input.headers )
  
  "set empty headers": -> @output.headers ?= Headers.make()
  
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

export default rulebase
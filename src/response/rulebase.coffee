import { MediaType, Accept } from "@dashkite/media-type"
import Athena from "@dashkite/athena"

import Request from "#request"
import Fields from "#fields"
import State from "#state"
import clone from "#helpers/clone"
import equal from "#helpers/equal"

import Status from "./status"

rulebase = Athena.make

  initialize: ( state ) -> State.make state

  clone: ( state ) -> state.clone()

  equal: ( a, b ) -> a.equal b

rulebase.conditions

  "has request": -> @input.request?

  "has status": -> @input.status?
  
  "has description": -> @input.description?

  "status ready": -> @output.status?

  "headers ready": -> @output.headers?

  "has content": -> @input.content?

rulebase.actions

  "set request": ->
    @working.request ?= await Request
      .make @input.request
      .get()
    @output.request = @working.request.data

  "set status": -> @output.status = Status.from @input.status

  "set status from description": ->
    @output.status = Status.from @input.description

  "set description from status": ->
    @output.description = Status.description @output.status

  "infer status ok": -> @output.status = 200

  "infer status no content": -> @output.status = 204

  "set headers": ->
    @working.headers ?= Fields.make ( @input.headers ? {} )
    @output.headers = @working.headers.data

rulebase.rules

  "set request": [ "has request" ]

  "set status": [ "has status" ]

  "set status from description": [ "!has status", "has description" ]

  "set description from status": [ "status ready" ]

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

  "set headers": [ "!headers ready" ]
  
export default rulebase
import { MediaType, Accept } from "@dashkite/media-type"
import Athena from "@dashkite/athena"

import { MutableFields } from "#fields"
import State from "#state"
import clone from "#helpers/clone"
import equal from "#helpers/equal"

import Status from "./status"

rules = ( Request ) ->

  _rules = Athena.make

    initialize: ( state ) -> State.make state

    clone: ( state ) -> state.clone()

    equal: ( a, b ) -> a.equal b

  _rules

    .condition  
      name: "has request"
      run: -> @input.request?

    .condition  
      name: "has status"
      run: -> @input.status?
      
    .condition  
      name: "has description"
      run: -> @input.description?

    .condition  
      name: "status ready"
      run: -> @output.status?

    .condition  
      name: "headers ready"
      run: -> @output.headers?

    .condition  
      name: "has content"
      run: -> @input.content?

    .action  
      name: "set request"
      when: [ "has request" ]
      run: ->
        @working.request ?= await Request.Builder
          .make @input.request
          .get()
        @output.request = @working.request.data

    .action  
      name: "set status"
      when: [ "has status" ]
      run: -> @output.status = Status.from @input.status

    .action  
      name: "set status from description"
      when: [ "!has status", "has description" ]
      run: ->
        @output.status = Status.from @input.description

    .action  
      name: "set description from status"
      when: [ "status ready" ]
      run: ->
        @output.description = Status.description @output.status

    .action  
      name: "infer status ok"
      when: [
        "!has status"
        "!has description"
        "has content" 
      ]
      run: -> @output.status = 200

    .action  
      name: "infer status no content"
      when: [
        "!has status"
        "!has description"
        "!has content" 
      ]
      run: -> @output.status = 204

    .action  
      name: "set headers"
      when: [ "!headers ready" ]
      run: ->
        @working.headers ?= MutableFields.make ( @input.headers ? {} )
        @output.headers = @working.headers.data
  
export default rules
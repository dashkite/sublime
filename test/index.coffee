import assert from "@dashkite/assert"
import {test, success} from "@dashkite/amen"
import print from "@dashkite/amen-console"
import Runner from "@dashkite/runner"

import $Request from "../src/request"
import $Response from "../src/response"
import convert from "../src/convert"

import scenarios from "./scenarios"

do ->

  print await test "Sublime", 

    await do ->

      Runner

        .make scenarios

        .apply

          "Request":
            "*": ({ input }) -> 
              $Request
                .make input
                .get()

          "Response":
            "*": ({ input }) ->
              $Response
                .make input
                .get()

          "convert":
            "request": 
              "*": ({ input }) ->
                convert "fetch", 
                  await $Request
                    .make input
                    .get()

            "response":
              "*": ({ input: { body, options }}) ->
                convert "sublime", new Response body, options


  process.exit if success then 0 else 1

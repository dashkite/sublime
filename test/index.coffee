import assert from "@dashkite/assert"
import {test, success} from "@dashkite/amen"
import print from "@dashkite/amen-console"
import Runner from "@dashkite/runner"

import Request from "../src/request"
import Response from "../src/response"

import scenarios from "./scenarios"
do ->

  print await test "Sublime", 

    await do ->

      Runner

        .make scenarios

        .apply

          "Request":
            "*": ({ url, method, content, headers }) -> 
              Request.make { url, method, content, headers }

          "Response":
            "*": ({ request, status, description, content }) ->
              Response.make { request, status, description, content }

  process.exit if success then 0 else 1

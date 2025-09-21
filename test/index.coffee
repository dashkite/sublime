import assert from "@dashkite/assert"
import {test, success} from "@dashkite/amen"
import print from "@dashkite/amen-console"
import Runner from "@dashkite/runner"

import Sierra from "@dashkite/sierra"
import Registry from "@dashkite/registry"

import Sublime from "../src"
import convert from "../src/convert"

import scenarios from "./scenarios"

do ->

  print await test "Sublime", 

    await do ->

      authorizers = Sierra.make()
      authorizers.add "foo", 
        matches: -> true
        get: -> 
          scheme: "foo"
          token: "123"
      await Registry.set "authorizers", authorizers

      $ = Sublime.make()

      Runner

        .make scenarios

        .apply

          "Request Builder": 
            "*": ({ input }) ->
              builder = $.Request.Builder.make input
              await builder.get()
              builder
                .update ( input ) ->
                  input.headers.authorization = "foo 123"
                  input
              request = await builder.get()
              request

          "Request":
            "*": ({ input }) -> 
              $.Request.Builder
                .make input
                .get()

          "Response":
            "*": ({ input }) ->
              $.Response.Builder
                .make input
                .get()

          "convert":
            "request": 
              "*": ({ input }) ->
                convert "fetch", 
                  await $.Request.Builder
                    .make input
                    .get()

            "response":
              "*": ({ input: { body, options }}) ->
                convert "sublime", new Response body, options


  process.exit if success then 0 else 1

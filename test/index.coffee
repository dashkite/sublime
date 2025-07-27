import assert from "@dashkite/assert"
import {test, success} from "@dashkite/amen"
import print from "@dashkite/amen-console"
import Runner from "@dashkite/runner"
import express from "express"

import Request from "../src/request"
import Response from "../src/response"

import scenarios from "./scenarios"

import api from "./api"

# set up simple local server to return an API description
server = ->
  new Promise ( resolve, reject ) ->
    try
      express()
        .get "/", ( _, response ) -> response.send api
        .listen 3000, resolve
    catch error
      reject error

do ->

  await server()

  print await test "Sublime", 

    await do ->

      Runner

        .make scenarios

        .apply

          "Request":
            "*": ({ input }) -> 
              Request
                .make input
                .get()

          "Response":
            "*": ({ input }) ->
              Response
                .make input
                .get()

          "Sky Request":
            "*": ({ input }) ->
              Request
                .make input
                .get()

  process.exit if success then 0 else 1

import request from "./request"
import response from "./response"
import convert from "./convert"
import Status from "./response/status"

Fetch =
  Response: Response

Sublime =

  make: ( rulebases = []) ->

    Request = request rulebases.map ({ request }) -> request
    Response = response Request, rulebases.map ({ response }) -> response

    # convert definitions
    convert.define [ "fetch", Request.Builder ], (  _, request ) ->
      convert "fetch", await request.get()

    convert.define [ "fetch", Response.Builder ], (  _, response ) ->
      convert "fetch", await response.get()

    convert.define [ "sublime", Fetch.Response ], ( _, response ) ->
      Response.Builder
        .make
          status: response.status
          description: Status.description response.status
          headers: Object.fromEntries response.headers.entries()
          content: await response.bytes()      
        .get()

    { Request, Response }

export default Sublime

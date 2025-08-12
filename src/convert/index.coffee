import * as Type from "@dashkite/joy/type"
import Generic from "@dashkite/generic"
import * as $Request from "../request"
import * as $Response from "../response"

convert = Generic.make "convert"

convert.define [ Object, Type.isAny ], 
  ({ to }, value ) -> convert to, value

convert.define [ "fetch", $Request.Value ], (  _, request ) ->
  { url, method, headers, content } = request
  new Request url, { 
    method, headers, 
    body: content, mode: "cors", 
    redirect: "follow", priority: "auto" 
  }

convert.define [ "sublime", Response ], ( _, response ) ->
  $Response.Builder
    .make
      status: response.status
      description: response.statusText
      headers: Object.fromEntries response.headers.entries()
      # TODO sublime should handle bytes
      # content: await response.bytes()
      content: await response.text()
    .get()

export default convert
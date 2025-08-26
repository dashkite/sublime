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

convert.define [ "fetch", $Response.Value ], (  _, response ) ->
  # TODO ensure that response.data returns canonical attributes
  { status, headers, content } = response.data
  # binary content should be ArrayBuffer
  # https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/ArrayBuffer
  new Response content, { status, headers }

convert.define [ "sublime", Response ], ( _, response ) ->
  $Response.Builder
    .make
      status: response.status
      description: response.statusText
      headers: Object.fromEntries response.headers.entries()
      content: await response.bytes()      
    .get()

export default convert
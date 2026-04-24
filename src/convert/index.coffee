import * as Type from "@dashkite/joy/type"
import Generic from "@dashkite/generic"
import RequestValue from "#request/value"
import ResponseValue from "#response/value"

convert = Generic.make "convert"

convert.define [ Object, Type.isAny ], 
  ({ to }, value ) -> convert to, value

convert.define [ "fetch", RequestValue ], (  _, request ) ->
  { url, method, headers, data: { content } } = request
  new Request url, { 
    method, headers, 
    body: content, mode: "cors",
    redirect: "follow", priority: "auto" 
  }

convert.define [ "fetch", ResponseValue ], (  _, response ) ->
  # TODO ensure that response.data returns canonical attributes
  { status, headers, content } = response.data
  # binary content should be ArrayBuffer
  # https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/ArrayBuffer
  new Response content, { status, headers }

export default convert
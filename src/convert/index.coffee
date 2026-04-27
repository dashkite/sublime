import * as Type from "@dashkite/joy/type"
import Generic from "@dashkite/generic"
import RequestValue from "#request/value"
import ResponseValue from "#response/value"

convert = Generic.make "convert"

convert.define [ Object, Type.isAny ], 
  ({ to }, value ) -> convert to, value

# Normalization Rules: According to WHATWG Fetch standards [1], only 
# DELETE, GET, HEAD, OPTIONS, POST, and PUT are byte-case-insensitively 
# matched and normalized to uppercase.
#
# Why PATCH is different: PATCH was introduced later (via RFC 5789 [2]) 
# and was not included in the original browser-compatibility 
# normalization lists used by early implementations.
#
# [1]: https://fetch.spec.whatwg.org/#methods
# [2]: https://datatracker.ietf.org/doc/html/rfc5789
convert.define [ "fetch", RequestValue ], (  _, request ) ->
  { url, method, headers, data: { content } } = request
  method = "PATCH" if method.toUpperCase() == "PATCH"
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
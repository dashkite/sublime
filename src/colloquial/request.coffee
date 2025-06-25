import { MediaType } from "@dashkite/media-type"
import Colloquial from "./sublime"

class Request extends Colloquial

  @make: ({ url, method, content, headers } = {}) ->
    Object.assign ( new @ ),
      _: Object.freeze { url, method, content, headers }

export default Request



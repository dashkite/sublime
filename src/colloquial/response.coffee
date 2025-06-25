import * as Type from "@dashkite/joy/type"
import * as Text from "@dashkite/joy/text"
import { MediaType } from "@dashkite/media-type"
import status from "statuses"
import Sublime from "./sublime"
import Request from "./request"

class Response extends Colloquial

  @make: ({ request, status, description, content } = {}) ->
    Object.assign ( new @ ),
      _: { request, status, description, content }

export default Response



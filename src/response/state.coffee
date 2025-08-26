import * as Fn from "@dashkite/joy/function"
import _State from "#state"
import clone from "#helpers/clone"

import Value from "#request/value"

# request value
clone.define [ Value ], Fn.identity

class State extends _State

export default State
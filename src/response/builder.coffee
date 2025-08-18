import builder from "#builder"

import rulebase from "./rulebase"
import validate from "./validate"
import Value from "./value"

class Builder extends builder()

  @produces Value

  @validator validate

  @rulebase [ rulebase ]

export default Builder

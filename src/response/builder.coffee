import builder from "#builder"

import rulebase from "./rulebase"
import driver from "./driver"
import validate from "./validate"
import Value from "./value"

class Builder extends builder()

  @produces Value

  @validator validate

  @rulebase [ driver, rulebase ]

export default Builder

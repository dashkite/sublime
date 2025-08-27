isJSON = ( value ) ->
  ( value?.subtype == "json" ) ||
    ( value?.mime?.subtype == "json" )

export { isJSON }
export default isJSON
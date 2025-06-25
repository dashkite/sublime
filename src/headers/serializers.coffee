import {
  Link
  Authorization
  WWWAuthenticate
  Accept
  ContentType
} from "@dashkite/http-headers"

import Fields from "./fields"

List =
  parse: ( value ) -> value.split /\s*,\s*/
  format: ( value ) -> value.join ", "

Singleton = 
  parse: ( value ) -> value
  format: ( value ) -> value

serializers =
  "content-type": ContentType
  "accept": Accept
  "link": Link
  "www-authenticate": WWWAuthenticate
  "authorization": Authorization
  "list": List
  "singleton": Singleton

Serializers =

  find: ( name ) ->
    serializers[ name ] ?
      serializers[( Fields.find name ).type ] ?
        List

export default Serializers
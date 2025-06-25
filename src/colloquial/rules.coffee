#     request: -> @_request ?= do =>
#       if Type.isKind Request, @_.request
#         @_.request
#       else
#         Request.make @_.request

#     status: ->
#       @_status ?= do =>
#         if @_.status?
#           if Type.isNumber @_.status
#             @_.status
#           else if Type.isString @_.status
#             Text.parseNumber @_.status
#           else if @_.status.toString?
#             Text.parseNumber @_.status.toString()
#           else
#             throw new Error "invalid HTTP 
#               response status #{ @_.status }"
#         else if @_.description?
#           status @_.description
#         else if @_.content?
#           200
#         else
#           204

#     description: ->
#       ( status @status )?.toLowerCase?()

#     content: ->
#       @_content ?= do =>
#         if @_.content?
#           if ( type = @headers.get "content-type" )?
#             if ( accept = @request.headers.get "accept" )?
#               # TODO attempt to match content to accept
#               MediaType.serialize @_.content  
#             else
#               # TODO verify that the content-type matches the value
#               MediaType.serialize @_.content
#           else
#             @headers.set "content-type", 
#               MediaType.fromValue @_.content
#             MediaType.serialize @_.content

# # request
#     content: ->
#       @_content ?= do =>
#         if @specifier.content?
#           if ( type = @headers.get "content-type" )?
#             # TODO verify that the content-type matches the value
#             MediaType.serialize @specifier.content
#           else
#             MediaType.serialize @specifier.content

#     url: -> @_url ?= new URL @specifier.url

#     method: -> @specifier.method?.toLowerCase?() ? "get"

#     origin: -> @url.origin

#     domain: -> @url.host

#     target: -> @path + @url.search

#     path: -> @url.pathname

#     query: -> Object.fromEntries @url.searchParams

# # headers
# set
#         if ( field = Fields.find name )?
#           if !field.computed
#             serializer = Serializers.find name
#             @_[ name ] = serializer.format value

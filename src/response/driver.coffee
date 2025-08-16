driver = ->
  yield name: "request"
  yield name: "status"
  yield name: "headers"
  yield name: "content"
  yield name: "finalize"
  yield name: "validate"
  await return

export default driver
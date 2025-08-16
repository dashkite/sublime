driver = ->
  yield name: "url"
  yield name: "method"
  yield name: "headers"
  yield name: "content"
  yield name: "finalize"
  yield name: "validate"
  await return

export default driver
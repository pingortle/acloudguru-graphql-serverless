'use strict'

module.exports.handler = (event, context, cb) => {
  console.log('Received event', event)
  var response = {
    message: `Hello there, ${event.requestContext.authorizer.claims.name}, your user ID is ${event.requestContext.authorizer.claims.sub}`,
    method: `This is an authorized ${event.httpMethod} to Lambda from your API`,
    body: event
  }
  cb(null,
    {
      statusCode: 200,
      headers: { 'Access-Control-Allow-Origin': '*' },
      body: JSON.stringify(response)
    }
  )
}

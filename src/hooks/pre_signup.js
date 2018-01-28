'use strict'

module.exports.handler = (event, context, cb) => {
  console.log(event)
  // Always confirm the user so they can log in immediately
  // They can confirm their email later when they make their first post
  event.response.autoConfirmUser = true
  return cb(null, event)
}

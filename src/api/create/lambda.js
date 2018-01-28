const AWS = require('aws-sdk')
const querystring = require('querystring')
const path = require('path')
const crypto = require('crypto')
AWS.config.setPromisesDependency(Promise)

const tableName = `${process.env.APP_STAGE}-shortened-urls`
const docClient = new AWS.DynamoDB.DocumentClient()

function RenderPage (link, submitted) {
  return `
<html>
<body>
<h3>
  <a href="${link}">${link}</a>
</h3>
<p>URL ${submitted} was shortened to:
  <a href="${link}">${link}</a>
</p>
</body>
</html>`
}

module.exports.handler = (event, context, callback) => {
  console.log(JSON.stringify(event))

  const submitted = querystring.parse(event.body).link
  const options = querystring.parse(event.body)
  const prefix = event.headers.Referer || 'http://mysite.com/'

  console.log('URL submitted: ' + submitted)
  return new Promise((resolve, reject) => {
    if (options.slug) return resolve(options.slug)

    resolve(crypto.randomBytes(8)
                   .toString('base64')
                   .replace(/[=+/]/g, '')
                   .substring(0, 4)
    )
  }).then(slug => {
    console.log(`Trying to save URL ${submitted} slug ${slug} now`)
    return docClient.put({
      TableName: tableName,
      Item: {
        slug: slug,
        long_url: submitted
      },
      Expected: {
        long_url: { Exists: false }
      }
    }).promise().then(() => { return slug })
  }).then((slug) => {
    console.log('woo, succeeded!')
    return callback(
      null,
      {
        statusCode: 200,
        body: RenderPage(path.join(prefix, slug).replace(':/', '://'), submitted),
        headers: { 'Content-Type': 'text/html' }
      }
    )
  }).catch(error => {
    console.log('Oh no, hit an error! ' + error)
    callback(
      null,
      {
        statusCode: 400,
        body: 'Something went wrong, please try again'
      }
    )
  })
}

module.exports.handler = (event, context, callback) => {
    console.log(JSON.stringify(event))
    const target = 'https://www.terraform.io/docs'
    callback(
        null,
        {
            statusCode: 302,
            body: target,
            headers: {
                'Location': target,
                'Content-Type': 'text/plain',
            },
        }
    )
}

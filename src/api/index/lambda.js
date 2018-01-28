const base_page = `<html>
<h1>Hi!</h1>
  <form method="POST" action="">
    <label for="link">Link:</label>
    <input type="text" id="link" name="link" size="40" required autofocus />
    <label for="slug">Slug (optional):</label>
    <input type="text" id="slug" name="slug" size="40" />
    <br/>
    <br/>
    <input type="submit" value="Shorten it!" />
  </form>
</html>`

module.exports.handler = (event, context, callback) => {
    console.log(JSON.stringify(event))
    callback(
        null,
        {
            statusCode: 200,
            body: base_page,
            headers: { 'Content-Type': 'text/html' },
        }
    )
}

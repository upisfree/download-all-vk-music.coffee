var fs, http, open, url;

http = require('http');

fs = require('fs');

url = require('url');

open = require('open');

open('https://oauth.vk.com/authorize?client_id=4509610&scope=audio,offline&display=page&v=5.24&response_type=token&redirect_uri=http://127.0.0.1:8080/?do=getTokenHtml');

http.createServer(function(req, res) {
  var query;
  query = url.parse(req.url, true).query;
  switch (query["do"]) {
    case 'getToken':
      return console.log(query.token + '\n' + query.userId);
    case 'getTokenHtml':
      return fs.readFile(__dirname + '/token.html', function(e, html) {
        if (e) {
          console.log(e);
        }
        res.writeHead(200, {
          'Content-Type': 'text/html'
        });
        res.write(html);
        return res.end();
      });
  }
}).listen(8080);

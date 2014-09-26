var auth, config, console, database, download, fs, http, open, progress, prompt, random, request, taglib, tmp, url, _download, _downloadAudio;

config = {
  audioFolder: __dirname + '/audio/',
  vk: {
    appId: 4509610,
    permissions: 'audio,offline',
    version: 5.24
  }
};

tmp = {};

random = function(min, max) {
  return Math.floor(Math.random() * (max - min + 1) + min);
};

http = require('http');

fs = require('fs');

url = require('url');

open = require('open');

auth = function(callback) {
  if (!tmp.userId || !tmp.token) {
    open("https://oauth.vk.com/authorize?client_id=" + config.vk.appId + "&scope=" + config.vk.permissions + "&display=page&v=" + config.vk.version + "&response_type=token&redirect_uri=http://127.0.0.1:8080/?do=getTokenHtml");
    return http.createServer(function(req, res) {
      var query;
      query = url.parse(req.url, true).query;
      switch (query["do"]) {
        case 'getToken':
          tmp.userId = query.userId;
          tmp.token = query.token;
          console.log('Auth completed successfully.');
          callback();
          return res.end();
        case 'getTokenHtml':
          return fs.readFile(__dirname + '/token.html', function(e, html) {
            if (e) {
              console.error(e);
            }
            res.writeHead(200, {
              'Content-Type': 'text/html'
            });
            res.write(html);
            return res.end();
          });
      }
    }).listen(8080);
  }
};

request = require('request');

taglib = require('taglib');

database = {
  update: function(callback) {
    var id, token;
    id = tmp.userId;
    token = tmp.token;
    if (!id || !token) {
      console.error('Sync failed because auth is not loaded now.\nTrying to restart sync...');
      return setTimeout(function() {
        return database.update();
      }, 1000);
    } else {
      console.log('Download song\'s list from VK...');
      return request("https://api.vk.com/method/audio.get?owner_id=" + id + "&access_token=" + token + "&v=" + config.vk.version, function(error, response, body) {
        var j, json, _i, _len, _ref;
        if (!error && response.statusCode === 200) {
          json = JSON.parse(body);
          tmp.audio = [];
          _ref = json.response.items;
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            j = _ref[_i];
            tmp.audio.push({
              id: j.id,
              artist: j.artist.replace(/—/, '-'),
              title: j.title.replace(/—/, '-'),
              isCached: false
            });
          }
          console.log('Song\'s list downloaded successfully.');
          database.renameDuplicates();
          return database.cache.get(function(data) {
            database.cache.write(data);
            return callback();
          });
        } else {
          return console.error(error);
        }
      });
    }
  },
  cache: {
    _get: function(i, cachedList, result, callback) {
      var a, artist, item, path, tag, title, _meta;
      a = cachedList[i];
      _meta = a.substr(0, a.length - 4).split(' — ');
      artist = _meta[0];
      title = _meta[1];
      path = config.audioFolder + a;
      tag = taglib.tagSync(path);
      item = {
        artist: artist,
        title: title
      };
      item.id = tag.comment ? tag.comment.replace(/\n\n.*/, '').replace(/VK id: ([0-9]+)/, '$1') : '';
      result.push(item);
      if (result.length === cachedList.length) {
        return callback(result);
      } else {
        return database.cache._get(++i, cachedList, result, callback);
      }
    },
    get: function(callback) {
      var cachedList, key, value;
      cachedList = fs.readdirSync(config.audioFolder);
      for (key in cachedList) {
        value = cachedList[key];
        if (value === 'data.json') {
          cachedList.splice(key, 1);
        }
      }
      if (cachedList.length !== 0) {
        return database.cache._get(0, cachedList, [], callback);
      } else {
        return callback([]);
      }
    },
    write: function(cached) {
      var a, b, _i, _j, _len, _len1, _ref;
      if (cached.length !== 0) {
        _ref = tmp.audio;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          a = _ref[_i];
          for (_j = 0, _len1 = cached.length; _j < _len1; _j++) {
            b = cached[_j];
            if (a.artist === b.artist && a.title === a.title && a.id == b.id) {
              console.log("“" + a.artist + " — " + a.title + "” is cached.");
              a.isCached = true;
              continue;
            }
          }
        }
        return console.log('Wrote cached audio to database.');
      } else {
        return console.log('There\'s no cached audio.');
      }
    }
  },
  renameDuplicates: function() {
    var a, b, r, _i, _len, _ref, _results;
    r = /\s\[([0-9]+)\]$/;
    _ref = tmp.audio;
    _results = [];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      a = _ref[_i];
      _results.push((function() {
        var _j, _len1, _ref1, _results1;
        _ref1 = tmp.audio;
        _results1 = [];
        for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
          b = _ref1[_j];
          if (("" + a.artist + " — " + a.title) === ("" + b.artist + " — " + b.title) && a.id !== b.id) {
            if (b.title.match(r)) {
              b.title = b.title.replace(r, function(s, p) {
                var i;
                i = parseInt(p);
                i++;
                return " [" + i + "]";
              });
            } else {
              b.title += ' [1]';
            }
          }
          continue;
        }
        return _results1;
      })());
    }
    return _results;
  }
};

progress = require('request-progress');

_download = function(link, name, id, userInfo, callback) {
  var path;
  console.clear();
  path = config.audioFolder + name + '.mp3';
  userInfo[0]++;
  userInfo[1] += 2;
  return progress(request(link, function() {
    return {
      throttle: 100
    };
  })).on('progress', function(state) {
    var a, b, line, stripe, _a, _i, _j, _ref;
    process.stdout.cursorTo(0, 0);
    stripe = '';
    a = process.stdout.columns;
    _a = a - 3;
    b = (_a * (state.percent / 100)).toFixed();
    stripe += '[';
    for (_i = 1; 1 <= b ? _i <= b : _i >= b; 1 <= b ? _i++ : _i--) {
      stripe += '=';
    }
    stripe += '>';
    for (_j = 1, _ref = _a - b; 1 <= _ref ? _j <= _ref : _j >= _ref; 1 <= _ref ? _j++ : _j--) {
      stripe += ' ';
    }
    stripe += ']';
    process.stdout.write(stripe);
    process.stdout.cursorTo(0, 1);
    line = "" + ((state.received / (1024 * 1000)).toFixed(2)) + " mb / " + ((state.total / (1024 * 1000)).toFixed(2)) + " mb\n" + state.percent + "%\n" + userInfo[0] + " of " + userInfo[1] + "\n" + name;
    return process.stdout.write(line);
  }).on('error', function(err) {
    return console.error(err);
  }).pipe(fs.createWriteStream(path)).on('error', function(err) {
    return console.error(err);
  }).on('close', function(err) {
    var tag;
    console.clear();
    tag = taglib.tagSync(path);
    tag.comment = "VK id: " + id + "\n\n";
    tag.saveSync();
    console.log("" + name + " saved successful.");
    return callback();
  });
};

download = function(id, name, userInfo, callback) {
  var token, userId;
  userId = tmp.userId;
  token = tmp.token;
  if (!userId || !token) {
    console.error('Download song failed because auth is not loaded now.\nTrying to restart download...');
    return setTimeout(function() {
      return download(id, callback);
    }, 1000);
  } else {
    return request("https://api.vk.com/method/audio.getById?audios=" + userId + "_" + id + "&access_token=" + token + "&v=" + config.vk.version, function(error, response, body) {
      var j, json;
      if (!error && response.statusCode === 200) {
        json = JSON.parse(body);
        j = json.response[0];
        return _download(j.url, name, id, userInfo, callback);
      } else {
        return console.error(error);
      }
    });
  }
};

console = require('better-console');

prompt = require('prompt');

prompt.colors = false;

prompt.message = prompt.delimiter = '';

prompt.start();

prompt.get({
  name: 'folder',
  description: 'Enter audio folder (with /):'
}, function(e, result) {
  if (e) {
    return console.error(e);
  } else {
    config.audioFolder = result.folder;
    if (!fs.existsSync(config.audioFolder)) {
      fs.mkdir(config.audioFolder, function(e) {
        return console.error(e);
      });
      console.log(config.audioFolder + ' created.');
    }
    return auth(function() {
      return database.update(function() {
        return _downloadAudio(0);
      });
    });
  }
});

_downloadAudio = function(i) {
  if (tmp.audio[i].isCached === true) {
    console.log("“" + tmp.audio[i].artist + " — " + tmp.audio[i].title + "” is cached.");
    i++;
    return _downloadAudio(i);
  } else {
    return download(tmp.audio[i].id, tmp.audio[i].artist.replace(/—/, '-') + ' — ' + tmp.audio[i].title.replace(/—/, '-'), [i, tmp.audio.length], function() {
      if (i !== tmp.audio.length - 1) {
        i++;
        return _downloadAudio(i);
      } else {
        return console.log('All songs downloaded.');
      }
    });
  }
};

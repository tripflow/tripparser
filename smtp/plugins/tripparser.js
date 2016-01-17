// tripparser

// documentation via: haraka -c /Users/janstransky/Projects/tripparser -h plugins/tripparser

// Put your plugin code here
// type: `haraka -h Plugins` for documentation on how to create a plugin

exports.hook_queue = function (next, connection) {
  //debug(connection.transaction);
  next();
}

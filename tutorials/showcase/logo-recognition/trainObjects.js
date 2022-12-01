// - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// Dependencies
// - - - - - - - - - - - - - - - - - - - - - - - - - - - -
const http = require('http'),
	path = require('path');

// - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// Options
// - - - - - - - - - - - - - - - - - - - - - - - - - - - -
const opts = {
  mediaServer: {
    host : '127.0.0.1',
    port : 14000,
    db   : 'Football'
  },
  objectDir: path.resolve('.'),
  objects: [
    { label: 'MasterCard',   group: 'billboard', imageFiles: [ 'mastercard.png' ] },
    { label: 'Nissan',       group: 'billboard', imageFiles: [ 'nissan.png' ] },
    { label: 'PlayStation',  group: 'billboard', imageFiles: [ 'playstation.png', 'playstation-inverse.png' ] },
    { label: 'Unicredit',    group: 'billboard', imageFiles: [ 'unicredit.png' ] },
    { label: 'PSG',          group: 'shirt',     imageFiles: [ 'psg.png' ] },
    { label: 'Emirates',     group: 'shirt',     imageFiles: [ 'fly-emirates.jpg' ] },
    { label: 'Barca',        group: 'shirt',     imageFiles: [ 'barcelona-crest.png', 'bcnpsg009.png' ] },
    { label: 'QatarAirways', group: 'shirt',     imageFiles: [ 'qatar-airways.jpg' ] }
  ]
};

// - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// Functions
// - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function getAutnResponse(action, options, callback) {
	http.get(options, response => {
    let body = '';
    response.on('data', data => {
      body += data;
    });
    response.on('end', data => {
      const json = JSON.parse(body);
      console.log(action, json.autnresponse.response.$);
      callback(json);
    });

  }).on('error', e => {
    console.log(`Cannot connect to IDOL Media Server on ${opts.mediaServer.host}:${opts.mediaServer.port}`);
  });
}

function setupDb(action, callback) {
  const options = {
    host: opts.mediaServer.host,
    port: opts.mediaServer.port,
    path: `/a=${action}&database=${opts.mediaServer.db}&responseFormat=json`
  };

  getAutnResponse(action, options, callback);
}

function removeDb(callback) {
  setupDb('removeObjectDatabase', () => callback());
}

function createDb(callback) {
  setupDb('createObjectDatabase', () => callback());
}

function trainObject(identifier, imagePaths, imageLabels, metadataList) {
  var action = 'trainObject',
    options = {
      host: opts.mediaServer.host,
      port: opts.mediaServer.port,
      path: `/a=${action}&database=${opts.mediaServer.db}&identifier=${identifier}` +
        `&imagepath=${imagePaths.join(',')}&imagelabels=${imageLabels.join(',')}&metadata=${metadataList.join(',')}` +
        '&responseFormat=json'
    };

  getAutnResponse(action, options, () => { /* DO NOTHING */ });
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// Main
// - - - - - - - - - - - - - - - - - - - - - - - - - - - -
removeDb(() => {
  createDb(() => {

		opts.objects.forEach(o => {
      const imagePaths = o.imageFiles
        .map(f => path.join(opts.objectDir, o.group, f))
        .map(p => encodeURIComponent(p));

      const imageLabels = o.imageFiles
        .map(f => encodeURIComponent(f));

      const metadataList = [o.group]
        .map(g => `group:${g}`)
        .map(g => encodeURIComponent(g));

			trainObject(o.label, imagePaths, imageLabels, metadataList);
    });
    
	});
});

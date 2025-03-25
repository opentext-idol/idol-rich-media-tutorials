/*
 * Listen for face-tracking alerts from Knowledge Discovery Media Server and produce a count of people.
 */

//  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//  d e p e n d e n c i e s
//  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
const fs = require('fs'),
  http = require('http'),
  os = require('os'),
  url = require('url'),
  opts = require('./options.js');

//  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//  v a r i a b l e s
//  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
let currentToken = null,
  currentStatus = null,
  cumulative = 0,
  trackingNow = 0,
  averageElapsedMSec = 0.0;

//  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//  m e t h o d s
//  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
const logger = {
  /**
   * Provide simple logging methods.
   */
  init: () => {
    fs.writeFileSync(opts.files.log, "");
  },
  info: (identifier, msg) => {
    const dateString = new Date().toISOString() // '2001-01-01T20:01:01.001Z'
      .split('T').join(' ')
      .split('Z').join('');
  
    msg = dateString + ' [' + identifier + '] ' + msg;
    console.log(msg);
    fs.appendFileSync(opts.files.log, msg + '\r\n');
  },
  debug: (identifier, msg) => {
    const dateString = new Date().toISOString() // '2001-01-01T20:01:01.001Z'
      .split('T').join(' ')
      .split('Z').join('');
  
    msg = dateString + ' [' + identifier + '] ' + msg;
    fs.appendFileSync(opts.files.log, msg + '\r\n');
  }
};

const doGracefulExit = () => {
  logger.debug('doGracefulExit', 'Sending stop signal...');
  mediaServer.stopProcess((d) => { process.exit(); });
};

const aciServer = {
  /**
   * Provide actions to interact with any ACI server.
   */
  getAutnResponse: (action, options, callback) => {
    http.get(options, (response) => {
      let body = '';
      response.on('data', (data) => { body += data; });
      response.on('end', (data) => {
        const json = JSON.parse(body);
        logger.debug(action, json.autnresponse.response.$);
        callback(json);
      });

    }).on('error', (e) => {
      logger.debug(action, 'Cannot connect to Knowledge Discovery Media Server on '+opts.mediaserver.host+':'+opts.mediaserver.port);
    });
  }
}

const mediaServer = {
  /**
   * Provide actions to interact with Knowledge Discovery Media Server.
   */
  startProcess: (cfg, callback) => {
    logger.debug('startProcess', 'Processing ' + opts.source);

  	const bsf = new Buffer.from(cfg).toString('base64'),
      action = 'process';

    let uri = '/action=' + action +
        '&source=' + encodeURIComponent(opts.source) +
        '&config=' + encodeURIComponent(bsf) +
        '&responseFormat=JSON';

    if (!opts.isVideoFile) {
      uri = uri + '&persist=true';
    }

    const options = {
      host: opts.mediaserver.host,
      port: opts.mediaserver.port,
      path: uri
    };

    aciServer.getAutnResponse(action, options, (d) => {
      currentToken = d.autnresponse.responsedata.token.$;
      callback();
    });
  },
  checkProgress: (callback) => {
    const action = 'queueinfo',
      options = {
        host: opts.mediaserver.host,
        port: opts.mediaserver.port,
        path: '/action=' + action +
          '&queueaction=getstatus' +
          '&queuename=process' +
          '&token=' + currentToken +
          '&responseFormat=JSON'
      };
  
    aciServer.getAutnResponse(action, options, (d) => {
      newStatus = d.autnresponse.responsedata.actions.action[0].status.$;
      
      if ('Finished' === newStatus) {
        logger.debug('checkProgress', 'Knowledge Discovery Media Server process finished.  Exiting...');
        process.exit();
        
      } else if ('Error' === newStatus) {
        const errorMessage = d.autnresponse.responsedata.actions.action[0].error.$;
        logger.debug('checkProgress', `Knowledge Discovery Media Server process failed with error:\n\'${errorMessage}\'.\nExiting...`);
        process.exit();
        
      } else {
        if (newStatus === currentStatus) {
          logger.debug('checkProgress', `Knowledge Discovery Media Server process state: \'${newStatus}\'`);
        } else {
          logger.info('checkProgress', `Knowledge Discovery Media Server process state: \'${newStatus}\'`);
          currentStatus = newStatus;
        }
        callback();
      }
    });
  },
  stopProcess: (callback) => {
    const action = 'queueinfo',
      options = {
        host: opts.mediaserver.host,
        port: opts.mediaserver.port,
        path: '/action=' + action +
          '&queueaction=stop' +
          '&queuename=process' +
          '&token=' + currentToken +
          '&responseFormat=JSON'
      };

    aciServer.getAutnResponse(action, options, callback);
  }
};

const parseProcessConfig = () => {
  /**
   * Process the templated Knowledge Discovery Media Server session configuration file.
   */
  const cfgTmpl = fs.readFileSync(opts.cfgFile, 'utf8'),
    isVideoFile = opts.isVideoFile,
    isDevice = opts.isDevice,
    deviceFormat = os.platform() === 'win32' ? 'dshow' : 'v4l2', // Otherwise assume Ubuntu
    sampleIntervalMSec = opts.sampleInterval,
    numParallel = opts.numParallel,
    minSize = opts.minSize,
    colorAnalysis = opts.colorAnalysis,
    detectTilted = opts.detectTilted,
    faceDirection = opts.faceDirection,
    region = opts.region,
    orientation = opts.orientation,
    appHost = opts.listener.host,
    appPort = opts.listener.port;

  const cfg = eval(`\`${cfgTmpl}\``);
  logger.debug('parseProcessConfig', cfg);

  return cfg;
};

const stockResponses = {
  /**
   * Provide standard messages in response to HTTP request.
   */
	rejectedRequest: (requestPath) => {
    return {
			body: JSON.stringify({ requestPath: requestPath, response: 'REQUEST REJECTED' }),
			contentType: 'application/json',
			statusCode: '400' // BAD REQUEST
		};
	},
	acceptedRequest: (requestPath) => {
		return {
			body: JSON.stringify({ requestPath: requestPath, response: 'REQUEST RECEIVED' }),
			contentType: 'application/json',
			statusCode: '200' // OK
		};
	}
};

const routeRequest = (req, res, body, callback) => {
  /**
   * Route received HTTP request.
   */
  const requestUri = url.parse(req.url);
  if ('/api/v1' === requestUri.pathname && 'addFaceTrackingEvent' === requestUri.query) {
    countPeople(requestUri.path, body, callback);
  } else {
    callback(stockResponses.rejectedRequest(requestPath));
  }
};

const onRequest = (req, res) => {
  /**
   * Process HTTP request.
   */
  logger.debug('onRequest', 'Connection received from Knowledge Discovery Media Server');

  if ('POST' !== req.method) {
    res.writeHead(405, { 'Content-Type': 'text/plain', 'Allow': 'POST' }); // 405 Method Not Allowed
    res.end();

  } else {
    let body = '';
    req.on('data', (data) => {
      body += data;
      if (body.length > 1e7) { req.connection.destroy(); }
    });

    req.on('end', () => {
      routeRequest(req, res, body, (answer) => {
        res.writeHead(answer.statusCode, { 'Content-Type': answer.contentType });
				res.write(answer.body);
				res.end();
      });
    });
  }
};

const countPeople = (requestPath, body, callback) => {
  callback(stockResponses.acceptedRequest(requestPath));
  
  const data = JSON.parse(body);
  try {
    if(data.eventType.toLowerCase() === 'start') {
      trackingNow++;
      cumulative++;

    } else if(data.eventType.toLowerCase() === 'result') {
      trackingNow--;
      const sumElapsedMSec = averageElapsedMSec * (cumulative - 1);
      averageElapsedMSec = (sumElapsedMSec + data.elapsedMSec) / cumulative;
    }

    logger.info('count', '> > > > > > > > > > > UPDATE > > > > > > > > > > >');
    logger.info('count', 'Cumulative count: ' + cumulative);
    logger.info('count', 'Tracking now: ' + trackingNow);
    logger.info('count', 'Average duration (seconds): ' + (averageElapsedMSec / 1000).toFixed(1));

  } catch (e) {
    logger.debug('count', 'Unexpected data received: ' + body);
  }
};

//  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//  m a i n   e x e c u t i o n
//  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

// Prepare app server
logger.init();
process.on('SIGINT', doGracefulExit);
http.createServer(onRequest).listen(opts.listener.port);
logger.info('listener', opts.serverName + ' has started on port ' + opts.listener.port.toString() + '.');

// Launch Knowledge Discovery Media Server processing
const doChecking = () => {
  setTimeout(() => {
    mediaServer.checkProgress(() => { doChecking(); });
  }, opts.checkProgressIntervalMSec);
};
mediaServer.startProcess(parseProcessConfig(), () => { doChecking(); });


var cluster = require('cluster');
var kaltura = require('./lib/KalturaServer');

var KalturaProcess = null;

Error.stackTraceLimit = Infinity;

if (cluster.isMaster) {
	KalturaProcess = new kaltura.KalturaMainProcess();
}
else{
	KalturaProcess = new kaltura.KalturaChildProcess();
}


/*
   Copyright 2015 Evothings AB

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
*/

var exec = cordova.require('cordova/exec');

/*********************************************************/
/******************** Kontakt.io API *********************/
/*********************************************************/

// cordova create kontakt-explorer com.evothings.kontaktexplorer KontaktExplorer

/**
 * Object that is exported.
 */
var kontaktio = {};

module.exports = kontaktio;

/**
 * Print an object. Useful for debugging. You can for example
 * display log output in the Evothings Workbench Tools window
 * if you run the app from Evothings Workbench.
 *
 * @param {object} obj Object to print.
 * @param {function} [printFun=console.log] Print function,
 * defaults to console.log (optional).
 *
 * @example Example calls:
 *   kontaktio.printObject(obj)
 *   kontaktio.printObject(obj, console.log)
 */
kontaktio.printObject = function(obj, printFun)
{
	if (!printFun) { printFun = console.log; }
	function print(obj, level)
	{
		var indent = new Array(level + 1).join('  ');
		for (var prop in obj)
		{
			if (obj.hasOwnProperty(prop))
			{
				var value = obj[prop];
				if (typeof value == 'object')
				{
					printFun(indent + prop + ':');
					print(value, level + 1);
				}
				else
				{
					printFun(indent + prop + ': ' + value);
				}
			}
		}
	}
	print(obj, 0);
};

/**
 * Start monitoring one or more beacon regions. Ranging events and
 * region enter/exit events are delivered to the respective callback
 * function.
 *
 * @param regions An array of {@link Region} objects. Empty region
 * defaults to Kontakt.io factory UUID and matches all
 * major and minor values.
 * @param rangeBeaconsCallback Called when ranging beacons. Called with an
 * array of {@link Beacon} objects as parameter.
 * @param enterRegionCallback Called when entering a region. Called with a
 * {@link Region} object parameter.
 * @param exitRegionCallback Called when exiting a region. Called with a
 * {@link Region} object parameter.
 * @param errorCallback Called when an error occurs. Called with a
 * string parameter with the error message.
 *
 * @example Start monitoring all beacons within range:
 *   kontaktio.startMonitoringBeacons(
 *       [{}],
 *       function(beacons) {
 *            console.log('Ranged beacons:')
 *            kontaktio.printObject(beacons) },
 *       function(region) {
 *            console.log('Entered region:')
 *            kontaktio.printObject(region) },
 *       function(region) {
 *            console.log('Exited region:')
 *            kontaktio.printObject(region) },
 *       function(error) {
 *            console.log('Error: ' + error)
 *            kontaktio.printObject(region) })
 */
kontaktio.startMonitoringBeacons = function(
	regions,
	rangeBeaconsCallback,
	enterRegionCallback,
	exitRegionCallback,
	errorCallback)
{
	function internalSuccessCallback(result)
	{
		if ('didRangeBeacons' == result.eventType)
		{
			rangeBeaconsCallback && rangeBeaconsCallback(result.beacons);
		}
		else if ('didEnterRegion' == result.eventType)
		{
			rangeBeaconsCallback && enterRegionCallback(result.region);
		}
		else if ('didExitRegion' == result.eventType)
		{
			rangeBeaconsCallback && exitRegionCallback(result.region);
		}
	}

	exec(internalSuccessCallback,
		errorCallback,
		'CordovaKontaktio',
		'jsapi_startMonitoringBeacons',
		[regions]
	);

	return true;
};

/**
 * Region object.
 * @typedef {Object} Region
 * @property {string} uuid - UUID of the region.
 * @property {number} major Major value of the region.
 * @property {number} minor Minor value of the region.
 */

/**
 * Beacon object.
 * @typedef {Object} Beacon
 * @property {string} uuid - UUID of the beacon.
 * @property {number} major Major value of the beacon.
 * @property {number} minor Minor value of the beacon.
 * @property {number} proximity Proximity value.
 * @property {number} accuracy - Accuracy value.
 * @property {number} rssi - The Received Signal Strength Indication.
 * @see {@link https://developer.apple.com/library/prerelease/ios/documentation/CoreLocation/Reference/CLBeacon_class/index.html|Full documentation of beacon properties}
 */

/**
 * Stop monitoring beacons.
 *
 * @param successCallback Called when successfully stopped monitoring.
 * Takes no parameters.
 * @param errorCallback Called when an error occurs. Called with a string
 * parameter with the error message.
 *
 * @example Start monitoring all beacons within range:
 *   kontaktio.stopMonitoringBeacons(
 *       function() {
 *            console.log('Stopped monitoring beacons:')
 *            kontaktio.printObject(region) },
 *       function(error) {
 *            console.log('Error: ' + error) })
 */
kontaktio.stopMonitoringBeacons = function(successCallback, errorCallback)
{
	exec(successCallback,
		errorCallback,
		'CordovaKontaktio',
		'jsapi_stopMonitoringBeacons',
		[]
	);

	return true;
};

# Cordova Kontakt.io Plugin

This is an Apache Cordova plugin for the Kontakt.io Beacon API.

Currently supported platform is iOS. Android support is planned.

## Plugin functions

With this plugin you can create apps in JavaScript that monitor Kontakt.io beacons.

Currently implemented functions are:

    kontaktio.startMonitoringBeacons(
        regions,
        rangeBeaconsCallback,
        enterRegionCallback,
        exitRegionCallback,
        errorCallback)

    kontaktio.stopMonitoringBeacons(
        successCallback,
        errorCallback)

Example calls:

    kontaktio.startMonitoringBeacons(
        [{}], // Monitor all factory set beacons.
        function(beacons) {
             console.log('Ranged beacons:')
             kontaktio.printObject(beacons) },
        function(region) {
             console.log('Entered region:')
             kontaktio.printObject(region) },
        function(region) {
             console.log('Exited region:')
             kontaktio.printObject(region) },
        function(error) {
             console.log('Error: ' + error)
             kontaktio.printObject(region) })

    kontaktio.stopMonitoringBeacons()

For further details, see documentation comments in file cordova-kontaktio-plugin/src/js/CordovaKontaktio.js (TODO: Add link)

## Example apps

Example apps for ranging and monitoring beacons are found in GitHub repository cordova-kontaktio-examples. (TODO: Add link)

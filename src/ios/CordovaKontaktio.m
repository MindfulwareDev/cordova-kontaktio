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

#import <Cordova/CDV.h>
#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "CordovaKontaktio.h"
#import "KontaktSDK.h"

/*********************************************************/
/*********** Kontaktio Cordova Imlementation *************/
/*********************************************************/

@interface CordovaKontaktio () <KTKLocationManagerDelegate>

/**
 * The Kontakt.io beacon location manager.
 */
@property KTKLocationManager* locationManager;

/**
 * Callback id for startMonitoringBeacons.
 */
@property NSString* callbackId_monitoringBeacons;

@end

@implementation CordovaKontaktio

/*********************************************************/
/****************** Initialise/Reset *********************/
/*********************************************************/

#pragma mark - Initialization

- (CordovaKontaktio*) pluginInitialize
{
	NSLog(@"OBJC pluginInitialize");

	// Crete location manager instance.
    self.locationManager = [KTKLocationManager new];
    self.locationManager.delegate = self;
	self.callbackId_monitoringBeacons = nil;

	return self;
}

/**
 * From interface CDVPlugin.
 * Called when the WebView navigates or refreshes.
 */
- (void) onReset
{
	// Clear callback and stop any ongoing monitoring.
	self.callbackId_monitoringBeacons = nil;
	[self.locationManager stopMonitoringBeacons];
}

/*********************************************************/
/********************  Implementation ********************/
/*********************************************************/

#pragma mark - Helper methods

/**
 * Create a region array from data passed from JavaScript.
 */
- (NSArray*) createRegionsFromJSArray: (NSArray*)regionArrayJS
{
	NSMutableArray* regions = [NSMutableArray array];
	for (NSDictionary* regionJS in regionArrayJS)
	{
		[regions addObject: [self createRegionFromJSDictionary: regionJS]];
	}

	return regions;
}

/**
 * Create a region from data passed from JavaScript.
 */
- (KTKRegion*) createRegionFromJSDictionary: (NSDictionary*)dictionary
{
	KTKRegion* region = [KTKRegion new];

	// Set default UUID. May be overwritten below.
    region.uuid = @"f7826da6-4fa2-4e98-8024-bc5b71e0893e";

	// Get values.
	for (id key in dictionary)
	{
		if ([key isEqualToString: @"uuid"])
		{
			region.uuid = dictionary[key];
		}
		else if ([key isEqualToString: @"major"])
		{
			region.major = dictionary[key];
		}
		else if ([key isEqualToString: @"minor"])
		{
			region.minor = dictionary[key];
		}
	}

	return region;
}

/**
 * Create a dictionary object from a region.
 */
- (NSDictionary*) regionToJSDictionary:(KTKRegion*)region
{
	NSMutableDictionary* dictionary = [NSMutableDictionary dictionaryWithCapacity: 4];

	[dictionary setValue: region.uuid forKey: @"uuid"];
	[dictionary setValue: region.major forKey: @"major"];
	[dictionary setValue: region.minor forKey: @"minor"];

	return dictionary;
}

/**
 * Create an array of beacon dictionary object from a beacon array.
 */
- (NSArray*) beaconsToJSArray:(NSArray*)beacons
{
	NSMutableArray* array = [NSMutableArray array];

	for (CLBeacon* beacon in beacons)
	{
		[array addObject: [self beaconToJSDictionary: beacon]];
	}

	return array;
}

/**
 * Create a dictionary object from a beacon.
 */
- (NSDictionary*) beaconToJSDictionary:(CLBeacon*)beacon
{
	NSMutableDictionary* dictionary = [NSMutableDictionary dictionaryWithCapacity: 8];

	[dictionary setValue: beacon.proximityUUID.UUIDString forKey: @"uuid"];
	[dictionary setValue: beacon.major forKey: @"major"];
	[dictionary setValue: beacon.minor forKey: @"minor"];
	[dictionary setValue: [NSNumber numberWithInt: beacon.proximity] forKey: @"proximity"];
	[dictionary setValue: [NSNumber numberWithLong: beacon.rssi] forKey: @"rssi"];
	[dictionary setValue: [NSNumber numberWithDouble: beacon.accuracy] forKey: @"accuracy"];

	return dictionary;
}

#pragma mark - Beacon monitoring

/**
 * Start monitoring beacons.
 */
- (void) jsapi_startMonitoringBeacons: (CDVInvokedUrlCommand*)command
{
	NSLog(@"OBJC jsapi_startMonitoringBeacons");

	// Error checking.
    if (![KTKLocationManager canMonitorBeacons])
    {
		NSLog(@"OBJC ![KTKLocationManager canMonitorBeacons]");

		// Pass error to JavaScript.
		[self.commandDelegate
			sendPluginResult: [CDVPluginResult
				resultWithStatus: CDVCommandStatus_ERROR
				messageAsString: @"Error start monitoring beacons"]
			callbackId: command.callbackId];

		return;
    }

	// Get region array passed from JavaScript and create region objects.
	NSArray* regionArray = [command argumentAtIndex: 0];
	NSArray* regions = [self createRegionsFromJSArray: regionArray];

	// Stop any ongoing monitoring.
	[self helper_stopMonitoringBeacons: command];

	// Save callback id.
	self.callbackId_monitoringBeacons = command.callbackId;

	// Set regions.
    [self.locationManager setRegions: regions];

    // Start monitoring.
    [self.locationManager startMonitoringBeacons];
}

/**
 * Stop monitoring beacons.
 */
- (void) jsapi_stopMonitoringBeacons: (CDVInvokedUrlCommand*)command
{
	// Stop monitoring.
	[self helper_stopMonitoringBeacons: command];

	// Respond to JavaScript with OK if a Cordova command object was passed.
	if (nil != command)
	{
		[self.commandDelegate
			sendPluginResult:[CDVPluginResult resultWithStatus: CDVCommandStatus_OK]
			callbackId: command.callbackId];
	}
}

- (void) helper_stopMonitoringBeacons: (CDVInvokedUrlCommand*)command
{
	// Stop any ongoing monitoring.
	[self.locationManager stopMonitoringBeacons];

	// Clear any existing callback.
	if (self.callbackId_monitoringBeacons)
	{
		// Clear callback on the JS side.
		CDVPluginResult* result = [CDVPluginResult
			resultWithStatus: CDVCommandStatus_NO_RESULT];
		[result setKeepCallbackAsBool: NO];
		[self.commandDelegate
			sendPluginResult:result
			callbackId: self.callbackId_monitoringBeacons];

		// Clear callback id.
		self.callbackId_monitoringBeacons = nil;
	}
}

#pragma mark - KTKLocationManagerDelegate

- (void) locationManager: (KTKLocationManager*)locationManager
	didChangeState: (KTKLocationManagerState)state
	withError: (NSError*)error
{
    if (state == KTKLocationManagerStateFailed)
    {
        NSLog(@"Something went wrong with your Location Services settings. Check OS settings.");

		if (self.callbackId_monitoringBeacons)
		{
			NSString* errorMessage = [NSString
				stringWithFormat: @"Location manager error %@", error];

			// Pass error to JavaScript.
			[self.commandDelegate
				sendPluginResult: [CDVPluginResult
					resultWithStatus: CDVCommandStatus_ERROR
					messageAsString: errorMessage]
				callbackId: self.callbackId_monitoringBeacons];
    	}
	}
}

- (void) locationManager:(KTKLocationManager*)locationManager
	didEnterRegion: (KTKRegion*)region
{
    NSLog(@"Enter region %@", region.uuid);

	if (nil != self.callbackId_monitoringBeacons)
	{
		// Create region object.
		NSDictionary* regionDictionary = [self regionToJSDictionary: region];

		// Create dictionary to pass result to JavaScript.
		NSMutableDictionary* resultDictionary =
			[NSMutableDictionary dictionaryWithCapacity: 4];
		[resultDictionary setValue: @"didEnterRegion" forKey: @"eventType"];
		[resultDictionary setValue: regionDictionary forKey: @"region"];

		// Pass result to JavaScript callback.
		CDVPluginResult* result = [CDVPluginResult
			resultWithStatus: CDVCommandStatus_OK
			messageAsDictionary: resultDictionary];
		[result setKeepCallbackAsBool: YES];
		[self.commandDelegate
			sendPluginResult: result
			callbackId: self.callbackId_monitoringBeacons];
	}
}

- (void) locationManager:(KTKLocationManager*) locationManager
	didExitRegion: (KTKRegion*)region
{
    NSLog(@"Exit region %@", region.uuid);

	if (nil != self.callbackId_monitoringBeacons)
	{
		// Create region object.
		NSDictionary* regionDictionary = [self regionToJSDictionary: region];

		// Create dictionary to pass result to JavaScript.
		NSMutableDictionary* resultDictionary =
			[NSMutableDictionary dictionaryWithCapacity: 4];
		[resultDictionary setValue: @"didExitRegion" forKey: @"eventType"];
		[resultDictionary setValue: regionDictionary forKey: @"region"];

		// Pass result to JavaScript callback.
		CDVPluginResult* result = [CDVPluginResult
			resultWithStatus: CDVCommandStatus_OK
			messageAsDictionary: resultDictionary];
		[result setKeepCallbackAsBool: YES];
		[self.commandDelegate
			sendPluginResult: result
			callbackId: self.callbackId_monitoringBeacons];
	}
}

- (void) locationManager:(KTKLocationManager*)locationManager
	didRangeBeacons: (NSArray*)beacons
{
    NSLog(@"Ranged beacons count: %lu", (unsigned long)[beacons count]);

	for (id beacon in beacons)
	{
		NSLog(@"   Beacon: %@", beacon);
	}

	if (nil != self.callbackId_monitoringBeacons)
	{
		// Create array with becons.
		NSArray* beaconArray = [self beaconsToJSArray: beacons];

		// Create dictionary to pass result to JavaScript.
		NSMutableDictionary* resultDictionary =
			[NSMutableDictionary dictionaryWithCapacity: 4];
		[resultDictionary setValue: @"didRangeBeacons" forKey: @"eventType"];
		[resultDictionary setValue: beaconArray forKey: @"beacons"];

		// Pass result to JavaScript callback.
		CDVPluginResult* result = [CDVPluginResult
			resultWithStatus: CDVCommandStatus_OK
			messageAsDictionary: resultDictionary];
		[result setKeepCallbackAsBool: YES];
		[self.commandDelegate
			sendPluginResult: result
			callbackId: self.callbackId_monitoringBeacons];
	}
}

@end

//
//  KTKBeaconDevice.h
//  kontakt-ios-sdk
//
//  Created by Krzysiek Cieplucha on 20/12/13.
//  Copyright (c) 2013 kontakt. All rights reserved.
//

#import "KTKBluetoothDevice.h"

@class KTKBluetoothManager;

/**
 Represents Kontakt beacon device.
 */
@interface KTKBeaconDevice : KTKBluetoothDevice

#pragma mark - properties

/**
 Logic value indicating if beacon is in DFU.
 */
@property (nonatomic) BOOL isInDfuMode;

/**
 Logic value indicating if beacon is locked.
 */
@property (assign, nonatomic, readonly) BOOL locked;

/**
 Unique identifier of a beacon.
 */
@property (copy, nonatomic, readonly) NSString *uniqueID;

#pragma mark - public methods

/**
 Connects to device with specified password
 
 @param password beacon's security password
 
 @return YES if connection operation suceeded - NO if not
 */
- (BOOL)connectWithPassword:(NSString *)password andError:(NSError **)error;

/**
 Can be used for pre-checking if password format is valid
 
 @param password beacon's security password
 
 @return YES if password format is valid - NO if not
 */
- (BOOL)isPasswordFormatValid:(NSString *)password;

/**
 Disconnects from device.
 */
- (void)disconnect;

/**
 Authorizes connection to the beacon using password set by setPassword: method.
 
 @warning   Don't use it - DEPRECATED
 @see       connectWithPassword:andError:
 
 @return error if opertion fails
 */
- (NSError *)authorize __deprecated_msg("Use - (BOOL)connectWithPassword:(NSString *)password andError:(NSError **)error");

/**
 Sets password used to authorize connection to the beacon.
 
 @warning   Don't use it - DEPRECATED
 @see       connectWithPassword:andError:
 
 @param password password for the beacon
 @return error if operation fails
 */
- (NSError *)setPassword:(NSString *)password __deprecated_msg("Use - (BOOL)connectWithPassword:(NSString *)password andError:(NSError **)error");

/**
 Returns characteristic descriptor for a specific characteristic kind.
 
 @param type type of characteristic
 @return characteristic descriptor
 */
- (KTKCharacteristicDescriptor *)characteristicDescriptorWithType:(NSString *)type;

/**
 Returns service descriptor for a specific service kind.
 
 @param type type of service
 @return service descriptor
 */
- (KTKServiceDescriptor *)serviceDescriptorWithType:(NSString *)type;

@end

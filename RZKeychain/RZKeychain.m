//
//  RZKeychain.m
//  RZKeychain
//
//

#import "RZKeychain.h"

@implementation RZKeychain


// Returns the keychain request dictionary for a SimpleKeychain entry.
+ (NSMutableDictionary *)getKeychainQuery:(NSString *)service {
    return [NSMutableDictionary dictionaryWithObjectsAndKeys:
            (id)kSecClassGenericPassword, (id)kSecClass,
            service, (id)kSecAttrService,
            service, (id)kSecAttrAccount,
            (id)kSecAttrAccessibleAfterFirstUnlock, (id)kSecAttrAccessible, // Keychain must be unlocked to access this value.
            nil];
}

// Accepts service name and NSCoding-complaint data object.
+ (void)save:(NSString *)service data:(id)data {
    NSMutableDictionary *keychainQuery = [self getKeychainQuery:service];
    SecItemDelete((CFDictionaryRef)keychainQuery);
    [keychainQuery setObject:[NSKeyedArchiver archivedDataWithRootObject:data] forKey:(id)kSecValueData];
    SecItemAdd((CFDictionaryRef)keychainQuery, NULL);
}

// Returns an object inflated from the data stored in the keychain entry for the given service.
+ (id)load:(NSString *)service {
    id ret = nil;
    NSMutableDictionary *keychainQuery = [self getKeychainQuery:service];
    [keychainQuery setObject:(id)kCFBooleanTrue forKey:(id)kSecReturnData];
    [keychainQuery setObject:(id)kSecMatchLimitOne forKey:(id)kSecMatchLimit];
    CFDataRef keyData = NULL;
    if (SecItemCopyMatching((CFDictionaryRef)keychainQuery, (CFTypeRef *)&keyData) == noErr) {
        @try {
            ret = [NSKeyedUnarchiver unarchiveObjectWithData:(NSData *)keyData];
        }
        @catch (NSException *e) {
            NSLog(@"Unarchive of %@ failed: %@", service, e);
        }
        @finally {}
    }
    if (keyData) CFRelease(keyData);
    return ret;
}

// Removes the entry for the given service from keychain.
+ (void)delete:(NSString *)service {
    NSMutableDictionary *keychainQuery = [self getKeychainQuery:service];
    SecItemDelete((CFDictionaryRef)keychainQuery);
}

+ (void) setValue:(id)value forKey:(NSString*)key inService:(NSString*)service
{
    // load the service
    id serviceObj = [self load:service];
    
    // if there is no object, create one. 
    if (nil == serviceObj) {
        serviceObj = [[[NSDictionary alloc] init] autorelease];
    }
    
    if ([serviceObj isKindOfClass:[NSDictionary class]]) {
        serviceObj = [[[NSMutableDictionary alloc] initWithDictionary:serviceObj copyItems:NO] autorelease];
        [serviceObj setValue:value forKey:key];
    }
    
    [self save:service data:serviceObj];
}

+ (void) removeValueForKey:(NSString*)key inService:(NSString*)service
{    
    // load the service
    id serviceObj = [self load:service];

    if ([serviceObj isKindOfClass:[NSDictionary class]]) {
    
        NSMutableDictionary* mutableDict = [[[NSMutableDictionary alloc] initWithDictionary:serviceObj copyItems:NO] autorelease];
        [mutableDict removeObjectForKey:key];

        [self save:service data:mutableDict];
    }
}

+ (id) valueForKey:(NSString*)key inService:(NSString*)service
{
    id val = nil;
    
    id serviceObj = [self load:service];
    if ([serviceObj isKindOfClass:[NSDictionary class]]) {
        val = [serviceObj valueForKey:key];
    }
    
    return val;
}

@end

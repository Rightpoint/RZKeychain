//
//  RZKeychainTests.m
//  RZKeychainTests
//
//  Created by Craig Spitzkoff on 1/6/12.
//  Copyright (c) 2012 Raizlabs Corporation. All rights reserved.
//

#import "RZKeychainTests.h"
#import "RZKeychain.h"

@implementation RZKeychainTests

- (void)setUp
{
    [super setUp];
}

- (void)tearDown
{
    [super tearDown];
}

- (void)test01
{
    static NSString* const service = @"RZKeychainTest";
    
    NSDictionary* testData = [NSDictionary dictionaryWithObjectsAndKeys:@"testUsername", @"username", @"testPassword", @"password", nil];
    
    [RZKeychain save:service data:testData];
    
    NSDictionary* readTestData = [RZKeychain load:service];
   
    // make sure the data we read in was same data that we wrote.
    for (NSString* key in testData.allKeys) {
        NSString* writtenValue = [testData objectForKey:key];
        NSString* readValue = [readTestData objectForKey:key];
        
        STAssertTrue([writtenValue isEqualToString:readValue], @"Data read from the keychain did not match data written to the keychain");
    }

    
    // delete the info and make sure it is deleted
    [RZKeychain delete:service];
    
    readTestData = [RZKeychain load:service];
    
    STAssertNil(readTestData, @"Data was not removed from the keychain");
}

@end

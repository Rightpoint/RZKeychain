//
//  RZKeychain.h
//  RZKeychain
//
//  Original solution by StackOverflow user Anomie: http://stackoverflow.com/q/5251820

#import <Foundation/Foundation.h>

@interface RZKeychain : NSObject

+ (void)save:(NSString *)service data:(id)data;
+ (id)load:(NSString *)service;
+ (void)delete:(NSString *)service;

@end

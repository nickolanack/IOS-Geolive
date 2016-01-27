//
//  StoredParameters.h
//  Abbisure
//
//  Created by Nick Blackwell on 2013-05-13.
//
//

#import <Foundation/Foundation.h>
#import "JsonSocket.h"
#import "Database.h"
#import "GeoliveServer.h"

@interface StoredParameters : NSObject

+(void)SetDatabase:(Database *)database;

+(bool)HasKey:(NSString *)key;
+(bool)HasVariableKey:(NSString *)key;
+(bool)HasCachedKey:(NSString *)key;

+(bool)SetObject:(id)object ForKey:(NSString *)key;
+(bool)CacheObject:(id)object ForKey:(NSString *)key;
+(bool)SetAndCacheObject:(id)object ForKey:(NSString *)key;

+(bool)ClearVariableKey:(NSString *)key;
+(bool)ClearCacheKey:(NSString *)key;
+(bool)ClearKey:(NSString *)key;


+(id)GetObjectForKey:(NSString *)key;









@end

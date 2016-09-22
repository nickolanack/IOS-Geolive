
//
//  Created by Nick Blackwell on 2013-05-13.
//
//

#import "StoredParameters.h"
#import "ResultSet.h"


@implementation StoredParameters

+(bool)ClearVariableKey:(NSString *)key{

    NSMutableDictionary *dictionary=[StoredParameters GetDictionary];
    [dictionary removeObjectForKey:key];
    return true;
    
}

+(bool)ClearCacheKey:(NSString *)key{
    
    if([StoredParameters HasCachedKey:key]){
        return [((id<PermanentObjectStorage>)[StoredParameters GetObjectForKey:@"CacheDatabase"]) removeObjectForName:key];
    }
    return false;
    
}

+(bool)ClearKey:(NSString *)key{
    
    bool success=true;
    success=[StoredParameters ClearVariableKey:key]&&success;
    success=[StoredParameters ClearCacheKey:key]&&success;
    return success;
    
}

+(bool)HasVariableKey:(NSString *)key{
    NSMutableDictionary *dictionary=[StoredParameters GetDictionary];
    if([dictionary objectForKey:key]==nil)return false;
    return true;
}

+(bool)HasCachedKey:(NSString *)key{
    if([StoredParameters HasVariableKey:@"CacheDatabase"]){
        return [((id<PermanentObjectStorage>)[StoredParameters GetObjectForKey:@"CacheDatabase"]) hasObjectForName:key];
    }
    return false;
}

+(bool)HasKey:(NSString *)key{
    return ([StoredParameters HasVariableKey:key]||[StoredParameters HasCachedKey:key]);
}


+(bool)SetObject:(id)object ForKey:(NSString *)key{
    NSMutableDictionary *dictionary=[StoredParameters GetDictionary];
    [dictionary setObject:object forKey:key];
    return true;
}

+(bool)CacheObject:(id) object ForKey:(NSString *)key{
    if([StoredParameters HasKey:@"CacheDatabase"]){
        
        return [((id<PermanentObjectStorage>)[StoredParameters GetObjectForKey:@"CacheDatabase"]) setObject:object ForName:key];

    }else{
        //NSLog(@"%@",key);
        @throw [[NSException alloc] initWithName:[NSString stringWithFormat:@"%s Exception: Cache Database Not Found",__PRETTY_FUNCTION__] reason:@"there is no cache table available" userInfo: [[NSDictionary alloc] initWithObjectsAndKeys: key, @"key", nil]];
    }
}

+(bool)SetAndCacheObject:(id)object ForKey:(NSString *)key{
    return([StoredParameters SetObject:object ForKey:key]&&[StoredParameters CacheObject:object ForKey:key]);
}

+(void)SetPermanentStorageHandler:(NSObject<PermanentObjectStorage> *)handler{
    [self SetObject:handler ForKey:@"CacheDatabase"];
}



+(id)GetObjectForKey:(NSString *)key{
    if([StoredParameters HasVariableKey:key]){
        NSMutableDictionary *dictionary=[StoredParameters GetDictionary];
        return [dictionary objectForKey:key];
    }else{
        if([StoredParameters HasCachedKey:key]){
            NSLog(@"%s: Retrieved Cache Item: %@", __PRETTY_FUNCTION__, key);
            id object=[StoredParameters GetCachedObjectForKey:key];
            [StoredParameters SetObject:object ForKey:key];
            return object;
        }
    }
    return nil;
}





+(id)GetCachedObjectForKey:(NSString *)key{
    
    if([StoredParameters HasVariableKey:@"CacheDatabase"]){
        
        return [((id<PermanentObjectStorage>)[StoredParameters GetObjectForKey:@"CacheDatabase"]) getObjectForName:key];
        
    }else{
        @throw [[NSException alloc] initWithName:[NSString stringWithFormat:@"%s Exception: Cache Database Not Found",__PRETTY_FUNCTION__] reason:@"there is no cache table available" userInfo: [[NSDictionary alloc] init]];
    }
    
}





#pragma mark -
#pragma mark Private Class Methods.

/*
 * A dictionary to hold application data that is used alot.
 */
+(NSMutableDictionary *)GetDictionary{
    static NSMutableDictionary *dictionary=nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dictionary = [[NSMutableDictionary alloc] init];
    });
    return dictionary;
}



@end

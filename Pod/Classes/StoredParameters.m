;//
//  StoredParameters.m
//  Abbisure
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
        Database *d=(Database *)[StoredParameters GetObjectForKey:@"CacheDatabase"];
        return [d execute:[NSString stringWithFormat:@"DELETE FROM variable WHERE name='%@'",key]];
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
        Database *d=(Database *)[StoredParameters GetObjectForKey:@"CacheDatabase"];
        ResultSet *r=[d query:[NSString stringWithFormat:@"SELECT count(*) FROM variable WHERE name='%@'",key]];
        NSNumber *n=(NSNumber *)[r firstValue];
        
        if([n intValue]>0){
            return true;
        }
        
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
        Database *d=(Database *)[StoredParameters GetObjectForKey:@"CacheDatabase"];
        ResultSet *r=[d query:[NSString stringWithFormat:@"SELECT count(*) FROM variable WHERE name='%@'",key]];
        NSNumber *n=(NSNumber *)[r firstValue];
        //NSLog(@"%@: Caching Object [%@]: %@: %@",[self class], key, [object class], object);
        NSString *jsonObjectString=[StoredParameters JsonEncode:object];
        
        if([n intValue]>0){
            [d execute:[NSString stringWithFormat:@"DELETE FROM variable WHERE name='%@'",key]];
        }
        //NSLog(@"INSERT INTO variables (name, data) VALUES('%@', '%@')", key, jsonObjectString);
        return [d execute:[NSString stringWithFormat:@"INSERT INTO variable (name, data) VALUES('%@', '%@')", key, jsonObjectString]];
    }else{
        //NSLog(@"%@",key);
        @throw [[NSException alloc] initWithName:[NSString stringWithFormat:@"%s Exception: Cache Database Not Found",__PRETTY_FUNCTION__] reason:@"there is no cache table available" userInfo: [[NSDictionary alloc] initWithObjectsAndKeys: key, @"key", nil]];
    }
}

+(bool)SetAndCacheObject:(id)object ForKey:(NSString *)key{
    return([StoredParameters SetObject:object ForKey:key]&&[StoredParameters CacheObject:object ForKey:key]);
}

+(void)SetDatabase:(Database *)database{
    [self SetObject:database ForKey:@"CacheDatabase"];
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
        
        Database *d=(Database *)[StoredParameters GetObjectForKey:@"CacheDatabase"];
        ResultSet *r=[d query:[NSString stringWithFormat:@"SELECT data FROM variable WHERE name='%@'",key]];
        NSString *jsonObjectString=[r firstValue];
        return [StoredParameters JsonDecode:jsonObjectString];
        
    }else{
        @throw [[NSException alloc] initWithName:[NSString stringWithFormat:@"%s Exception: Cache Database Not Found",__PRETTY_FUNCTION__] reason:@"there is no cache table available" userInfo: [[NSDictionary alloc] init]];
    }
    
}



+(id)JsonDecode:(NSString *) string{
    NSError *decodeError=nil;
    NSDictionary *json =[NSJSONSerialization JSONObjectWithData:[string dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableLeaves error:&decodeError];
    
    if(decodeError.code==0){
        id primative;
        if(
           [json  isKindOfClass:[NSDictionary class]]&&
           (primative=[((NSDictionary *)json) objectForKey:@"_object_"])!=nil){
            return primative;
        }
        return json;
    }else{
        @throw [[NSException alloc] initWithName:[NSString stringWithFormat:@"%s: Json Decode Exception: %@",__PRETTY_FUNCTION__, decodeError.domain] reason:decodeError.description userInfo: decodeError.userInfo];
    }

}

+(id)JsonEncode:(id) object{
    NSError *encodeError=nil;
    id item;
    
    if([object isKindOfClass:[NSString class]]||[object  isKindOfClass:[NSNumber class]]){
        item=(id)[[NSDictionary alloc] initWithObjectsAndKeys:object,@"_object_", nil];
    }else{
        item=object;
    }
    
    NSData *data=[NSJSONSerialization dataWithJSONObject:item options:NSJSONWritingPrettyPrinted error:&encodeError];    if(encodeError.code==0){
        return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    }else{
        @throw [[NSException alloc] initWithName:[NSString stringWithFormat:@"%s: Json Decode Exception: %@",__PRETTY_FUNCTION__, encodeError.domain] reason:encodeError.description userInfo: encodeError.userInfo];
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

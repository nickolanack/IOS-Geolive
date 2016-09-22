//
//  DatabaseStorage.m
//  Pods
//
//  Created by Nick Blackwell on 2016-01-27.
//
//

#import "DatabaseStorage.h"
#import "StoredParameters.h"
#import "ResultSet.h"
@interface DatabaseStorage()

@property  Database * database;
@property  NSString * table;

@end

@implementation DatabaseStorage


-(instancetype)initWithDatabase:(Database *)d AndTable:(NSString *) table{
    
    self=[super init];
    
    self.database=d;
    self.table=table;
    
    return self;
}

-(bool)hasObjectForName:(NSString *)name{
    ResultSet *r=[_database query:[NSString stringWithFormat:@"SELECT count(*) FROM %@ WHERE name='%@'",_table, name]];
    NSNumber *n=(NSNumber *)[r firstValue];
    
    if([n intValue]>0){
        return true;
    }
    
    return false;
    
}
-(id)getObjectForName:(NSString *)name{
    
    
    ResultSet *r=[_database query:[NSString stringWithFormat:@"SELECT data FROM %@ WHERE name='%@'",_table, name]];
    NSString *jsonObjectString=[r firstValue];
    return [DatabaseStorage JsonDecode:jsonObjectString];
    
    
    
}

-(bool)setObject:(id) object ForName:(NSString *)name{
    
    ResultSet *r=[_database query:[NSString stringWithFormat:@"SELECT count(*) FROM %@ WHERE name='%@'",_table, name]];
    NSNumber *n=(NSNumber *)[r firstValue];
    
    NSString *jsonObjectString=[DatabaseStorage JsonEncode:object];
    
    if([n intValue]>0){
        [_database execute:[NSString stringWithFormat:@"DELETE FROM %@ WHERE name='%@'",_table, name]];
    }
    
    return [_database execute:[NSString stringWithFormat:@"INSERT INTO %@ (name, data) VALUES('%@', '%@')", _table, name, jsonObjectString]];
    
    
    
    
}
-(bool)removeObjectForName:(NSString *)name{
    
    
    if([self hasObjectForName:name]){
        return [_database execute:[NSString stringWithFormat:@"DELETE FROM %@ WHERE name='%@'",_table,  name]];
    }
    return false;
    
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

@end

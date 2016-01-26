//
//  GeolMarker.m
//  Geolive 1.0
//
//  Created by Nicholas Blackwell on 2012-11-06.
//  Copyright (c) 2012 Nicholas Blackwell. All rights reserved.
//

#import "GeolMarker.h"
#import <CoreLocation/CoreLocation.h>
#import "GeolLayer.h"
#import "GeolRenderer.h"
#import <GeoliveFramework/Variables.h>

@implementation GeolMarker
@synthesize latlng;


-(NSString *)getItemTypeName{
    return @"marker";
}

-(bool) save{
    NSMutableDictionary *markerJson=[[NSMutableDictionary alloc ] initWithDictionary:@{@"name":[self getName], @"description":[self getDescription], @"coordinates":@[[NSNumber numberWithDouble:[self getLatlng].latitude], [NSNumber numberWithDouble:[self getLatlng].longitude]], @"published":[NSNumber numberWithBool:[self getPublished]]}];
    if([self getIcon]!=nil){
        [markerJson setValue:[self getIcon] forKey:@"style"];
    }
    NSMutableDictionary *json=[[NSMutableDictionary alloc ] initWithDictionary:@{@"marker":markerJson, @"layerId":[[self getLayer] getID]}];
    if([self hasGeoliveID]){
        [json setValue:[self getID] forKey:@"mapitemId"];
    }
    
    
   
    
    NSDictionary *result=[[[Variables GetObjectForKey:@"System"] getJson] queryTask:([self hasGeoliveID]?@"marker_save":@"marker_new") WithJson:json];
    NSLog(@"%@",result);
    
    if(result!=nil&&[[result valueForKey:@"success"] boolValue]){
        if(![self hasGeoliveID])self.ID=[NSString stringWithFormat:@"%@",[result valueForKey:@"id"]];
    }else{
        NSString *lastResponse=[[[Variables GetObjectForKey:@"System"] getJson] lastResponse];
        NSLog(@"%s: %@",__PRETTY_FUNCTION__, lastResponse);
    }
    return true;
}

-(NSDictionary *)getAttributeValueTable:(NSString *)table field:(NSString *)field{
    NSDictionary *result=[[[Variables GetObjectForKey:@"System"] getJson] queryTask:@"get_attribute_value" WithJson:@{@"plugin":@"Attributes", @"table":table, @"field":field, @"itemType":@"marker", @"itemId":[self getID]}];
    if([[result objectForKey:@"success"] boolValue]){
        
        return result;
    
    }
    NSString *lastResult=[[[Variables GetObjectForKey:@"System"] getJson] lastQuery];
    NSLog(@"%@",lastResult);
    return nil;
}
-(NSDictionary *)getAttributesTable:(NSString *)table{
    NSLog(@"%s: item[%@] has no getAttributes method",__PRETTY_FUNCTION__, [self class]);
    return nil;
}
-(bool)setAttributeValue:(id)value table:(NSString *)table field:(NSString *)field{
    if(!([value isKindOfClass:[NSString class]]||[value isKindOfClass:[NSArray class]])){
        
        @throw [[NSException alloc] initWithName:@"Marker Set Attributes Exception" reason:@"Attribute value can only be a string or an array of strings" userInfo:nil];
        
    }
    NSDictionary *result=[[[Variables GetObjectForKey:@"System"] getJson] queryTask:@"save_attributes" WithJson:@{@"plugin":@"Attributes", @"table":table, @"fieldValues":@{field:value}, @"itemId":[self getID], @"itemType":@"marker"}];
    if([[result objectForKey:@"success"] boolValue]){
        return true;
    }
    return false;
}
-(bool)setAttributesArray:(NSDictionary *)values table:(NSString *)table{
   
    NSDictionary *result=[[[Variables GetObjectForKey:@"System"] getJson] queryTask:@"save_attribute_value_list" WithJson:@{@"plugin":@"Attributes", @"table":table, @"fieldValues":values, @"itemType":@"marker", @"itemId":[self getID]}];
    if([[result objectForKey:@"success"] boolValue]){
        return true;
    }
    NSString *lastQuery=[[[Variables GetObjectForKey:@"System"] getJson] lastQuery];
    NSString *lastResponse=[[[Variables GetObjectForKey:@"System"] getJson] lastResponse];
    NSLog(@"%@ : %@", lastQuery, lastResponse);
    return false;
}



-(bool)addAttributeValue:(id)value table:(NSString *)table field:(NSString *)field{
    if(!([value isKindOfClass:[NSString class]]||[value isKindOfClass:[NSArray class]])){
        
        @throw [[NSException alloc] initWithName:@"Marker Set Attributes Exception" reason:@"Attribute value can only be a string or an array of strings" userInfo:nil];
        
    }
    NSDictionary *result=[[[Variables GetObjectForKey:@"System"] getJson] queryTask:@"add_attribute" WithJson:@{@"plugin":@"Attributes", @"table":table, @"attribute":field, @"value":value, @"itemType":@"marker", @"itemId":[self getID]}];
    if([[result objectForKey:@"success"] boolValue]){
        return true;
    }
    NSString *lastResult=[[[Variables GetObjectForKey:@"System"] getJson] lastResponse];
    NSLog(@"%@",lastResult);
    
    return false;
}
-(bool)removeAttributeValue:(id)value table:(NSString *)table field:(NSString *)field{
    if(!([value isKindOfClass:[NSString class]]||[value isKindOfClass:[NSArray class]])){
        
        @throw [[NSException alloc] initWithName:@"Marker Set Attributes Exception" reason:@"Attribute value can only be a string or an array of strings" userInfo:nil];
        
    }
    NSDictionary *result=[[[Variables GetObjectForKey:@"System"] getJson] queryTask:@"remove_attribute" WithJson:@{@"plugin":@"Attributes", @"table":table, @"attributes":@{field:value}, @"itemType":@"marker", @"itemId":[self getID]}];
    if([[result objectForKey:@"success"] boolValue]){
        return true;
    }
    NSString *lastResult=[[[Variables GetObjectForKey:@"System"] getJson] lastResponse];
    NSLog(@"%@",lastResult);
    return false;
}
-(int)countAttributesTable:(NSString *)table field:(NSString *)field{
    NSDictionary *result=[[[Variables GetObjectForKey:@"System"] getJson] queryTask:@"count_attribute_values" WithJson:@{@"plugin":@"Attributes", @"table":table, @"field":field, @"itemType":@"marker", @"itemId":[self getID]}];
    if([[result objectForKey:@"success"] boolValue]){
        
        return [[result objectForKey:@"count"] intValue];
        
    }
    NSString *lastResult=[[[Variables GetObjectForKey:@"System"] getJson] lastResponse];
    NSLog(@"%@",lastResult);
    return -1;
}


-(bool) remove{
    return false;
}

@end

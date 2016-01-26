//
//  GeolMapItem.m
//  Geolive 1.0
//
//  Created by Nick Blackwell on 2012-11-04.
//  Copyright (c) 2012 Nicholas Blackwell. All rights reserved.
//

#import "GeolMapItem.h"
#import "GeolItem.h"
#import "GeolMap.h"
#import "GeolLayer.h"


@interface GeolMapItem()

@property int visibility;

@end

@implementation GeolMapItem


@synthesize renderableItem, published, map, layer;

-(id)init{
    
    self=[super init];
    
    _visibility=GEOLIVE_ITEM_HIDDEN;
    return self;
}

-(void)hide{
    if(_visibility==GEOLIVE_ITEM_VISIBLE){
        id<GeolRenderer> renderer= [[self getLayer] getRendererForItem:self];
        if(renderer == nil){
            NSLog(@"no renderer");
        }
        [renderer removeRenderable:(id<GeolMapRenderable>)self];
        _visibility=GEOLIVE_ITEM_HIDDEN;
    }
}
-(void)show{
    if(_visibility==GEOLIVE_ITEM_HIDDEN){
        id<GeolRenderer> renderer= [[self getLayer] getRendererForItem:self];
        [renderer addRenderable:(id<GeolMapRenderable>)self];
        _visibility=GEOLIVE_ITEM_VISIBLE;
    }
}

-(void)redraw{
    [self hide];
    [self show];
}

-(bool)save{
    NSLog(@"%s: item[%@] has no save method",__PRETTY_FUNCTION__, [self class]);
    return false;
}
-(bool)remove{
    NSLog(@"%s: item[%@] has no remove method",__PRETTY_FUNCTION__, [self class]);
    return false;
}

-(NSDictionary *)getAttributeValueTable:(NSString *)table field:(NSString *)field{
    NSLog(@"%s: item[%@] has no getAttributeValue method",__PRETTY_FUNCTION__, [self class]);
    return nil;
}
-(NSDictionary *)getAttributesTable:(NSString *)table{
    NSLog(@"%s: item[%@] has no getAttributes method",__PRETTY_FUNCTION__, [self class]);
    return nil;
}
-(bool)setAttributeValue:(id)value table:(NSString *)table field:(NSString *)field{
    NSLog(@"%s: item[%@] has no setAttributeValue method",__PRETTY_FUNCTION__, [self class]);
    return false;
}

-(bool)setAttributesArray:(NSDictionary *)values table:(NSString *)table{
    NSLog(@"%s: item[%@] has no setAttributeArray method",__PRETTY_FUNCTION__, [self class]);
    return false;
}


-(bool)addAttributeValue:(id)value table:(NSString *)table field:(NSString *)field{
    NSLog(@"%s: item[%@] has no addAttributeValue method",__PRETTY_FUNCTION__, [self class]);
    return false;
}
-(bool)removeAttributeValue:(id)value table:(NSString *)table field:(NSString *)field{
    NSLog(@"%s: item[%@] has no removeAttributeValue method",__PRETTY_FUNCTION__, [self class]);
    return false;
}
-(int)countAttributesTable:(NSString *)table field:(NSString *)field{
    NSLog(@"%s: item[%@] has no countAttributesTable method",__PRETTY_FUNCTION__, [self class]);
    return -1;
}

-(void) enableDragging{
    
    id<GeolMapRenderableItem> item=[self getRenderableItem];
    if ([item conformsToProtocol:@protocol(GeolDraggableItem)])
    {
        [((id<GeolDraggableItem>)item) enableDragging];
    }
    
}
-(void) disableDragging{

    id<GeolMapRenderableItem> item=[self getRenderableItem];
    if ([item conformsToProtocol:@protocol(GeolDraggableItem)])
    {
        [((id<GeolDraggableItem>)item) disableDragging];
    }

}







-(NSString *)getItemTypeName{
    return @"map item";
}

@end

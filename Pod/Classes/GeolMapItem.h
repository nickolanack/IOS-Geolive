//
//  GeolMapItem.h
//  Geolive 1.0
//
//  Created by Nick Blackwell on 2012-11-04.
//  Copyright (c) 2012 Nicholas Blackwell. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GeolItem.h"
#import "GeolMapRenderable.h"
#import "GeolDraggableItem.h"

@class GeolLayer;
@class GeolMap;


 
@interface GeolMapItem : GeolItem<GeolMapRenderable, GeolDraggableItem>



@property (getter = getMap) GeolMap *map;
@property (getter = getLayer) GeolLayer *layer;
@property (getter = getRenderableItem)id<GeolMapRenderableItem> renderableItem;
@property (getter = getPublished)bool published;


-(void) hide;
-(void) show;
-(void) redraw;


//returns the item type, for this instance. GeolMapItem is abstract.
//examples: "Marker", "Polygon", "Line" ...
//use this method for messages.
-(NSString *)getItemTypeName;


-(bool)save;
-(bool)remove;

-(NSDictionary *)getAttributeValueTable:(NSString *)table field:(NSString *)field;
-(NSDictionary *)getAttributesTable:(NSString *)table;
-(bool)setAttributeValue:(id)value table:(NSString *)table field:(NSString *)field;
-(bool)setAttributesArray:(NSDictionary *)values table:(NSString *)table;

-(bool)addAttributeValue:(id)value table:(NSString *)table field:(NSString *)field;
-(bool)removeAttributeValue:(id)value table:(NSString *)table field:(NSString *)field;
-(int)countAttributesTable:(NSString *)table field:(NSString *)field;

@end

//
//  GeolLayer.m
//  Geolive 1.0
//
//  Created by Nick Blackwell on 2012-11-02.
//  Copyright (c) 2012 Nicholas Blackwell. All rights reserved.
//

#import "GeolLayer.h"
#import "GeolMapItem.h"
#import "GeolMarker.h"
#import "GeolPolygon.h"
#import "GeolLine.h"
#import "GeolRenderer.h"

@interface GeolLayer()

 @property GeolVisibilityState visibility;

@end

@implementation GeolLayer


@synthesize map;

-(id)init{
    
    self=[super init];
    
    self.markers=[[NSMutableArray alloc] init];
    self.polygons=[[NSMutableArray alloc] init];
    self.lines=[[NSMutableArray alloc] init];
    self.visibility=GEOLIVE_ITEM_VISIBLE;
    self.layerEventDelegates=[NSMutableArray array];
    
    
    return self;
}

-(id<GeolRenderer>) getRendererForItem:(GeolMapItem *) item{
    return (id<GeolRenderer>)[self.map getMapPane];
}
-(void) setRenderer:(GeolRenderer *) renderer ForItem:(GeolMapItem *)item{

}

-(void)setMap:(GeolMap *)themap{
    map=themap;
    [map addLayer:self];
}

-(NSArray *) getMapItemsRecurse:(BOOL) recurse{
    NSMutableSet *set = [NSMutableSet setWithArray:self.markers];
    [set addObjectsFromArray:self.lines];
    [set addObjectsFromArray:self.polygons];
    return [set allObjects];
}
-(NSArray *) getMarkersRecurse:(BOOL) recurse{
    return [NSArray arrayWithArray:self.markers];
}
-(NSArray *) getLinesRecurse:(BOOL) recurse{
    return [NSArray arrayWithArray:self.lines];
}
-(NSArray *) getPolygonsRecurse:(BOOL) recurse{
    return [NSArray arrayWithArray:self.polygons];
}

-(void) hideRecurse:(BOOL) recurse{
    NSEnumerator *e = [[self getMapItemsRecurse:recurse] objectEnumerator];
    GeolMapItem * item;
    while (item = (GeolMapItem *)[e nextObject]) {
        [item hide];
    }
    
    if(recurse){
        self.visibility=GEOLIVE_ITEM_HIDDEN;
    }else{
        //TODO: if there are folders, check if any are visible
        
        self.visibility=GEOLIVE_ITEM_HIDDEN;
    
    }
}
-(void) showRecurse:(BOOL) recurse{
    NSEnumerator *e = [[self getMapItemsRecurse:recurse] objectEnumerator];
    GeolMapItem * item;
    while (item = (GeolMapItem *)[e nextObject]) {
        [item show];
    }
    
    if(recurse){
        self.visibility=GEOLIVE_ITEM_VISIBLE;
        //TODO: if there are folders, check if any are hidden
    }else{
        self.visibility=GEOLIVE_ITEM_HIDDEN;
        
    }
    
}

-(void) resetRecurse:(BOOL) recurse{
    NSEnumerator *e = [[self getMapItemsRecurse:recurse] objectEnumerator];
    GeolMapItem * item;
    if(/*check initialState*/true){
        while (item = (GeolMapItem *)[e nextObject]) { [item show]; }
    }else{
        while (item = (GeolMapItem *)[e nextObject]) { [item hide]; }
    }
    
}

-(GeolVisibilityState)isVisible{
    return self.visibility;
}


-(void) addMapItem:(GeolMapItem *)mapItem{
    
    NSMutableArray *array;
    
    
    if([mapItem isKindOfClass:[GeolPolygon class]] ){
        array=self.polygons;
    }else if([mapItem isKindOfClass:[GeolLine class]] ){
        array=self.lines;
    }else if([mapItem isKindOfClass:[GeolMarker class]] ){
        array=self.markers;
       
    }

    GeolLayer *layer=[mapItem getLayer];
    [mapItem  setLayer:self];
    if( layer != self){
        [layer removeMapItem:mapItem];
    }
    
    if(array != nil){
        [array addObject:mapItem];
        [mapItem show];
        [self layerDidAddItem:mapItem];
        
    }else{
        NSLog(@"%s: Don't know what %@ is",__PRETTY_FUNCTION__, [mapItem class]);
    }
    
    
}
-(void) addMapItems:(NSArray *)mapItems{
    //TODO:
    
    
}
-(void) removeMapItem:(GeolMapItem *)mapItem{
   
     NSMutableArray *array;
    
    if([mapItem isKindOfClass:[GeolPolygon class]] ){
        array=self.polygons;
    }else if([mapItem isKindOfClass:[GeolLine class]] ){
        array=self.lines;
    }else if([mapItem isKindOfClass:[GeolMarker class]] ){
        array=self.markers;
        
    }
    
    GeolLayer *layer=[mapItem getLayer];
    
    
    if(array != nil&&layer==self){
        
        [array removeObject:mapItem];
        [mapItem hide];
        
       
        [mapItem setLayer:nil];
        
        [self layerDidRemoveItem:mapItem];
        
    }else{
        NSLog(@"%s: Failed to remove mapItem from layer", __PRETTY_FUNCTION__);
    }
    
    
}
-(void) removeMapItems:(NSArray *)mapItems{
    //TODO:
    
    
}




#pragma mark -
#pragma mark LayerEventDelegate

-(void)addLayerEventDelegate:(id<GeolLayerEventDelegate>)delegate{
    if([self.layerEventDelegates indexOfObject:delegate]==NSNotFound){
        [self.layerEventDelegates addObject:delegate];
    }else{
        
    }
}
-(void)removeLayerEventDelegate:(id<GeolLayerEventDelegate>)delegate{
    //NSLog(@"%@: Removing Delegate %@", [self class], [delegate class]);
    [self.layerEventDelegates removeObject:delegate];
}


-(void)layerDidShow{
    NSEnumerator *e = [self.layerEventDelegates objectEnumerator];
    id<GeolLayerEventDelegate> item;
    while ((item = (id<GeolLayerEventDelegate>)[e nextObject])) {
        
        if([item respondsToSelector:@selector(layerDidShow)]){
            //NSLog(@"%@: Execute Map Type Change Delegate: %@",[self class], [item class]);
            [item performSelector:@selector(layerDidShow)];
        }
        
    }

}
-(void)layerDidHide{
    NSEnumerator *e = [self.layerEventDelegates objectEnumerator];
    id<GeolLayerEventDelegate> item;
    while ((item = (id<GeolLayerEventDelegate>)[e nextObject])) {
        
        if([item respondsToSelector:@selector(layerDidHide)]){
            //NSLog(@"%@: Execute Map Type Change Delegate: %@",[self class], [item class]);
            [item performSelector:@selector(layerDidHide)];
        }
        
    }

}
-(void)layerDidAddItem:(GeolMapItem *) geolitem{
    NSEnumerator *e = [self.layerEventDelegates objectEnumerator];
    id<GeolLayerEventDelegate> item;
    while ((item = (id<GeolLayerEventDelegate>)[e nextObject])) {
        
        if([item respondsToSelector:@selector(layerDidAddItem:)]){
            //NSLog(@"%@: Execute Map Type Change Delegate: %@",[self class], [item class]);
            [item performSelector:@selector(layerDidAddItem:) withObject:geolitem];
        }
        
    }

}
-(void)layerDidRemoveItem:(GeolMapItem *) geolitem{
    NSEnumerator *e = [self.layerEventDelegates objectEnumerator];
    id<GeolLayerEventDelegate> item;
    while ((item = (id<GeolLayerEventDelegate>)[e nextObject])) {
        
        if([item respondsToSelector:@selector(layerDidRemoveItem:)]){
            //NSLog(@"%@: Execute Map Type Change Delegate: %@",[self class], [item class]);
            [item performSelector:@selector(layerDidRemoveItem:) withObject:geolitem];
        }
        
    }

}

@end

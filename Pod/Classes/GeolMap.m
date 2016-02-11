//
//  GeolMap.m
//  Geolive 1.0
//
//  Created by Nick Blackwell on 2012-11-02.
//  Copyright (c) 2012 Nicholas Blackwell. All rights reserved.
// @deprecated
//

#import "GeolMap.h"
#import "GeolLayer.h"
#import "GeolMapPane.h"


@interface GeolMap()
#pragma mark -
#pragma mark Private Vars

@property NSMutableArray *layers;
@property NSMutableArray *mapEventDelegates;

@property int homeZoom;
@property CLLocationCoordinate2D homeCenter;



@end
@implementation GeolMap

#pragma mark -
#pragma mark Synthesizers

@synthesize mapPane;

- (id)init
{
    self = [super init];
    if (self) {
        self.layers=[NSMutableArray array];
        self.mapEventDelegates=[NSMutableArray array];
    }
    return self;
}

-(void)setMapPane:(GeolMapPane *)pane{
    mapPane=pane;
    [pane setMap:self];
    [self.mapPane setMapEventDelegate:self];
  
}
//synthesized!
//-(GeolMapPane *)getMapPane{
   // return mapPane;
//}




#pragma mark -
#pragma mark Private Methods

#pragma mark -
#pragma mark Public Methods


-(void) setZoom:(int)zoom{
    [self.mapPane setZoom:zoom];
    
}
-(void) setCenter:(CLLocationCoordinate2D) latlng{
    [self.mapPane setCenter:latlng];
    
}
-(void) setCenter: (CLLocationCoordinate2D)latlng AndZoom:(int) zoom {
    [self.mapPane setCenter:latlng AndZoom:zoom];
}
-(void) setCenter: (CLLocationCoordinate2D)latlng AndSpan:(MKCoordinateSpan)span{
    [self.mapPane setCenter:latlng AndSpan:span];
}
-(void) setSpan:(MKCoordinateSpan) span{
    [self.mapPane setSpan:span];
}
-(MKCoordinateSpan) getSpan{
    return [self.mapPane getSpan];
}


-(void)setHomeCenter: (CLLocationCoordinate2D)latlng AndZoom:(int) zoom{
    self.homeCenter=latlng;
    self.homeZoom=zoom;
}
-(void)goHome{
    [self setCenter:self.homeCenter AndZoom:self.homeZoom];
}

-(void) setMapType:(int)type{
    
    [self.mapPane setMapType:type];
}
-(int) getMapType{
    return [self.mapPane getMapType];
}

-(CLLocationCoordinate2D) getCenter{
    return [self.mapPane getCenter];
}
-(int) getZoom{
    return [self.mapPane getZoom];
}


-(BOOL) isTrackingUser{
    return [self.mapPane isTrackingUser];
}
-(void) startTrackingUser{
    return [self.mapPane startTrackingUser];
    
}
-(void) stopTrackingUser{
    return [self.mapPane stopTrackingUser];
}
-(CLLocation *) getUsersPosition{
    return [self.mapPane getUsersPosition];
}

#pragma mark -
#pragma mark Layerable

-(NSArray *) getMapItemsRecurse:(BOOL) recurse{
    NSEnumerator *e = [self.getLayers objectEnumerator];
    GeolLayer *layer;
    NSMutableSet *set = [[NSMutableSet alloc] init];
    while (layer = [e nextObject]) {
        [set addObjectsFromArray:[layer getMapItemsRecurse:recurse]];
    }
    return [set allObjects];
}
-(NSArray *) getMarkersRecurse:(BOOL) recurse{
    NSEnumerator *e = [self.getLayers objectEnumerator];
    GeolLayer *layer;
    NSMutableSet *set = [[NSMutableSet alloc] init];
    while (layer = [e nextObject]) {
        [set addObjectsFromArray:[layer getMarkersRecurse:recurse]];
    }
    return [set allObjects];
}
-(NSArray *) getLinesRecurse:(BOOL) recurse{
    NSEnumerator *e = [self.getLayers objectEnumerator];
    GeolLayer *layer;
    NSMutableSet *set = [[NSMutableSet alloc] init];
    while (layer = [e nextObject]) {
        [set addObjectsFromArray:[layer getLinesRecurse:recurse]];
    }
    return [set allObjects];
}
-(NSArray *) getPolygonsRecurse:(BOOL) recurse{
    NSEnumerator *e = [self.getLayers objectEnumerator];
    GeolLayer *layer;
    NSMutableSet *set = [[NSMutableSet alloc] init];
    while (layer = [e nextObject]) {
        [set addObjectsFromArray:[layer getPolygonsRecurse:recurse]];
    }
    return [set allObjects];
}

-(void) hideRecurse:(BOOL) recurse{
    NSEnumerator *e = [self.getLayers objectEnumerator];
    GeolLayer *layer;
    while (layer = (GeolLayer *)[e nextObject]) {
        [layer hideRecurse:recurse];
    }
    
}
-(void) showRecurse:(BOOL) recurse{
    NSEnumerator *e = [self.getLayers objectEnumerator];
    GeolLayer *layer;
    while (layer = (GeolLayer *)[e nextObject]) {
        [layer showRecurse:recurse];
    }
}

-(void) resetRecurse:(BOOL) recurse{
    NSEnumerator *e = [self.getLayers objectEnumerator];
    GeolLayer *layer;
    while (layer = (GeolLayer *)[e nextObject]) {
        [layer resetRecurse:recurse];
    }
}



#pragma mark -
#pragma mark LayerManager


-(NSArray *)getLayers{
    return [NSArray arrayWithArray:self.layers];
}

-(GeolLayer *) getLayerFromName:(NSString *)name{
    
    NSEnumerator *e = [[self getLayers ] objectEnumerator];
    GeolLayer *layer;
    while (layer = (GeolLayer *)[e nextObject]) {
        if([[layer getName] isEqualToString:name])return layer;
    }
    return nil;
    
}

-(GeolLayer *) getLayerFromID:(NSString *)ID{
    NSEnumerator *e = [self.layers objectEnumerator];
    GeolLayer *layer;
    while (layer = (GeolLayer *)[e nextObject]) {
        if([[layer getID] isEqualToString:ID])return layer;
    }
    return nil;
}


-(void)addLayer:(GeolLayer *)layer{
    NSString *ID=[layer getID];
    if(ID ==nil ||[ID isEqualToString:@""]){
        if([self.layers indexOfObject:layer]==NSNotFound){
            [self.layers addObject:layer];
            [layer addLayerEventDelegate:self];
            
            NSLog(@"%s: Added Anonymous Layer: %@",__PRETTY_FUNCTION__,[layer getName]);
        }
        
    }else if([self getLayerFromID:[layer getID]]==nil){
        [self.layers addObject:layer];
        NSLog(@"%s: Added Layer: %@|%@",__PRETTY_FUNCTION__, [layer getID], [layer getName]);

    }
    
}
-(void)removeLayer:(GeolLayer *)layer{
    if([self.layers indexOfObject:layer]!=NSNotFound){
        [layer removeLayerEventDelegate:self];
        //should do some cleanup...
        
    }
    
}

-(int)getMapTypeFromName:(NSString *)name{
    return [[self getMapPane] getMapTypeFromName:name];
    
}
-(NSString *)getMapTypeTitle:(int)type{
    return [[[self getMapPane] getMapTypeTitle:type] copy];
}

-(NSString *)getMapTypeDescription:(int)type{
    return [[[self getMapPane] getMapTypeDescription:type] copy];
}



-(NSArray *)getMapTypeNames{
    //NSArray *types=
    return [[[self getMapPane] getMapTypeNames] copy];
}


#pragma mark -
#pragma mark MapEventDelegate

-(void)addMapEventDelegate:(id<GeolMapEventDelegate>)delegate{
    if([self.mapEventDelegates indexOfObject:delegate]==NSNotFound){
        [self.mapEventDelegates addObject:delegate];
    }else{
        
    }
}
-(void)removeMapEventDelegate:(id<GeolMapEventDelegate>)delegate{
    //NSLog(@"%@: Removing Delegate %@", [self class], [delegate class]);
    [self.mapEventDelegates removeObject:delegate];
}

-(void)mapDidMove{
    NSEnumerator *e = [self.mapEventDelegates objectEnumerator];
    id<GeolMapEventDelegate> item;
    while ((item = (id<GeolMapEventDelegate>)[e nextObject])) {
        
        if([item respondsToSelector:@selector(mapDidMove)]){
            [item performSelector:@selector(mapDidMove)];
        }
    }
}
-(void)mapDidZoom{
    NSEnumerator *e = [self.mapEventDelegates objectEnumerator];
    id<GeolMapEventDelegate> item;
    while ((item = (id<GeolMapEventDelegate>)[e nextObject])) {
        
        if([item respondsToSelector:@selector(mapDidZoom)]){
            [item performSelector:@selector(mapDidZoom)];
        }
    }
}
-(void)mapTypeDidChange{

    NSEnumerator *e = [self.mapEventDelegates objectEnumerator];
    id<GeolMapEventDelegate> item;
    while ((item = (id<GeolMapEventDelegate>)[e nextObject])) {
        if([item respondsToSelector:@selector(mapTypeDidChange)]){
            [item performSelector:@selector(mapTypeDidChange)];
        }  
    }
}

-(void)mapLayer:(GeolLayer *) layer addedItem:(GeolMapItem *) geolitem{
    NSEnumerator *e = [self.mapEventDelegates objectEnumerator];
    id<GeolMapEventDelegate> item;
    while ((item = (id<GeolMapEventDelegate>)[e nextObject])) {
        if([item respondsToSelector:@selector(mapLayer:addedItem:)]){
            [item performSelector:@selector(mapLayer:addedItem:) withObject:layer withObject:geolitem];
        }   
    }
}

-(void)layerDidAddItem:(GeolMapItem *)item{
    NSLog(@"%s: Added Map Item", __PRETTY_FUNCTION__);
    [self mapLayer:[item getLayer] addedItem:item];
}


-(bool)doesMapItemHaveInfowindow:(GeolMapItem *)item{
    NSEnumerator *e = [self.mapEventDelegates objectEnumerator];
    id<GeolMapEventDelegate> delegate;
    while ((delegate = (id<GeolMapEventDelegate>)[e nextObject])) {
        if([delegate respondsToSelector:@selector(mapItemHasInfowindow:)]){
            bool result=[delegate performSelector:@selector(mapItemHasInfowindow:) withObject:item];
            if(result)return true;
        }
    }
    return false;
}

-(void)openInfowindow:(GeolMapItem *)item{

    NSEnumerator *e = [self.mapEventDelegates objectEnumerator];
    id<GeolMapEventDelegate> delegate;
    while ((delegate = (id<GeolMapEventDelegate>)[e nextObject])) {
        if([delegate respondsToSelector:@selector(mapItemHasInfowindow:)]){
            
            bool result=[delegate performSelector:@selector(mapItemHasInfowindow:) withObject:item];
            if(result){
            
                if([delegate respondsToSelector:@selector(viewForMapItem:)]){
                    
                    UIView *view=[delegate performSelector:@selector(viewForMapItem:) withObject:item];
                    if(view){
                        
                        [[item getRenderableItem] openView:view];
                       
                        break;
                    }
                }
                
                
            }
        }
    }
    

}

-(NSString *)markerIconForLayer:(GeolLayer *) layer{

    NSEnumerator *e = [self.mapEventDelegates objectEnumerator];
    id<GeolMapEventDelegate> delegate;
    while ((delegate = (id<GeolMapEventDelegate>)[e nextObject])) {
        if([delegate respondsToSelector:@selector(markerIconForLayer:)]){
            
            NSString *icon=[delegate performSelector:@selector(markerIconForLayer:) withObject:layer];
            if(icon!=nil){
                return icon;
            }
        }
    }
    
    return nil;
}


@end

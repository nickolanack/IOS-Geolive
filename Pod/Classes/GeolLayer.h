//
//  GeolLayer.h
//  Geolive 1.0
//
//  Created by Nick Blackwell on 2012-11-02.
//  Copyright (c) 2012 Nicholas Blackwell. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GeolMap.h"
#import "GeolItem.h"
#import "GeolLayerable.h"
#import "GeolMutableLayerable.h"
#import "GeolMapItem.h"
#import "GeolRenderer.h"
#import "GeolLayerEventDelegate.h"

@class GeolRenderer;



@interface GeolLayer : GeolItem<GFLayerable, GFMutableLayerable>


@property NSMutableArray *markers;
@property NSMutableArray *lines;
@property NSMutableArray *polygons;
@property NSMutableArray *layerEventDelegates;

@property (nonatomic, getter = getMap)GeolMap *map;


-(id<GeolRenderer>) getRendererForItem:(GeolMapItem *) item;
-(void) setRenderer:(GeolRenderer *) renderer ForItem:(GeolMapItem *)item;

-(void)addLayerEventDelegate:(id<GeolLayerEventDelegate>)delegate;
-(void)removeLayerEventDelegate:(id<GeolLayerEventDelegate>)delegate;

/*
 *resets the map to its initialial view, including layers if recurse is set to true.
 */

@end

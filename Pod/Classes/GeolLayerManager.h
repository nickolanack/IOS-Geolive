//
//  GeolLayerManager.h
//  Geolive 1.0
//
//  Created by Nicholas Blackwell on 2012-11-06.
//  Copyright (c) 2012 Nicholas Blackwell. All rights reserved.
//

#import <Foundation/Foundation.h>
@class GeolLayer;

@protocol GFLayerManager <NSObject>

-(NSArray *)getLayers;
-(GeolLayer *) getLayerFromName:(NSString *)name;
-(GeolLayer *) getLayerFromID:(NSString *)ID;
-(void) addLayer:(GeolLayer *) layer;
-(void) removeLayer:(GeolLayer *) layer;

@end

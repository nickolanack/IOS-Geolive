//
//  GeolMutableLayerable.h
//  Geolive 1.0
//
//  Created by Nicholas Blackwell on 2012-11-06.
//  Copyright (c) 2012 Nicholas Blackwell. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GeolLayerable.h"

@class GeolMapItem;
@protocol GFMutableLayerable <GFLayerable>
@required
-(void) addMapItem:(GeolMapItem *)mapItem;
-(void) addMapItems:(NSArray *)mapItems;
-(void) removeMapItem:(GeolMapItem *)mapItem;
-(void) removeMapItems:(NSArray *)mapItems;

@end

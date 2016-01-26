//
//  GeolLayerable.h
//  Geolive 1.0
//
//  Created by Nicholas Blackwell on 2012-11-06.
//  Copyright (c) 2012 Nicholas Blackwell. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol GFLayerable <NSObject>

/*
 * returns an NSArray with GeolMapItems if recurse is true, then the list contains items recursively from folders within layer as well.
 */
-(NSArray *) getMapItemsRecurse:(BOOL) recurse;
/*
 * returns an NSArray with GeolMarkers if recurse is true, then the list contains items recursively from folders within layer as well.
 */
-(NSArray *) getMarkersRecurse:(BOOL) recurse;
/*
 * returns an NSArray with GeolLines if recurse is true, then the list contains items recursively from folders within layer as well.
 */
-(NSArray *) getLinesRecurse:(BOOL) recurse;
/*
 * returns an NSArray with GeolPolygons if recurse is true, then the list contains items recursively from folders within layer as well.
 */
-(NSArray *) getPolygonsRecurse:(BOOL) recurse;
/*
 * hides all items if recurse is set to true, hides items in folders recursively
 */
-(void) hideRecurse:(BOOL) recurse;
/*
 * hides all items if recurse is set to true, hides items in folders recursively
 */
-(void) showRecurse:(BOOL) recurse;
/*
 * resets current state of layer, (shown or hidden) as well as folders if recurse.
 */
-(void) resetRecurse:(BOOL) recurse;

@end

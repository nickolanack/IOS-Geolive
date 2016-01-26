//
//  GeolMapPane.h
//  Geolive 1.0
//
//  Created by Nicholas Blackwell on 2012-11-06.
//  Copyright (c) 2012 Nicholas Blackwell. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import "GeolRenderer.h"
#import "GeolMapEventDelegate.h"
#import <MapKit/MapKit.h>
#import "GeolMap.h"

@interface GeolMapPane : NSObject<GeolRenderer>

@property (getter = getMapEventDelegate) id<GeolMapEventDelegate> mapEventDelegate;
@property (getter = getMap)  GeolMap * map;

-(void) setCenter:(CLLocationCoordinate2D) center;
-(CLLocationCoordinate2D) getCenter;

-(void) setMapType:(int) type;
-(int) getMapType;

-(NSArray *)getMapTypeNames;
-(NSString *)getMapTypeTitle:(int)type;
-(NSString *)getMapTypeDescription:(int)type;



-(int)getMapTypeFromName:(NSString *)name;

-(void) setZoom:(double) zoom;
-(int) getZoom;

-(MKCoordinateSpan) getSpan;
-(void)setSpan:(MKCoordinateSpan)span;

-(void) setCenter:(CLLocationCoordinate2D)center AndZoom:(double) zoom;
-(void) setCenter:(CLLocationCoordinate2D)center AndSpan:(MKCoordinateSpan) span;



-(BOOL) isTrackingUser;
-(void) startTrackingUser;
-(void) stopTrackingUser;
-(CLLocation *) getUsersPosition;

-(void) setMapEventDelegate:(id<GeolMapEventDelegate>)delegate;
@end

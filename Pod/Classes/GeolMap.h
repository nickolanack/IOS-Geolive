//
//  GeolMap.h
//  Geolive 1.0
//
//  Created by Nick Blackwell on 2012-11-02.
//  Copyright (c) 2012 Nicholas Blackwell. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "GeolLayerable.h"
#import "GeolLayerManager.h"
#import "GeolItem.h"
#import "GeolMapEventDelegate.h"
#import "GeolLayerEventDelegate.h"
#import <MapKit/MapKit.h>

@class GeolMapPane;

                                                                //becuase map pane has add mapEventDelegate
@interface GeolMap : GeolItem <GFLayerable, GFLayerManager, GeolMapEventDelegate, GeolLayerEventDelegate>

@property (nonatomic, getter = getMapPane)  GeolMapPane * mapPane;

//@property GeolItem *selectedMapItem; //might be nill;


-(void) setZoom:(int)zoom;
-(void) setCenter:(CLLocationCoordinate2D) latlng;
-(void) setSpan:(MKCoordinateSpan) span;

-(void) setCenter: (CLLocationCoordinate2D)latlng AndZoom:(int) zoom;
-(void) setCenter: (CLLocationCoordinate2D)latlng AndSpan:(MKCoordinateSpan) span;
-(CLLocationCoordinate2D) getCenter;
-(int) getZoom;
-(MKCoordinateSpan) getSpan;

-(void)setHomeCenter: (CLLocationCoordinate2D)latlng AndZoom:(int) zoom;
-(void)goHome;

-(void)addMapEventDelegate:(id<GeolMapEventDelegate>)delegate;
-(void)removeMapEventDelegate:(id<GeolMapEventDelegate>)delegate;

-(int) getMapType;
-(void) setMapType:(int)type;

-(int)getMapTypeFromName:(NSString *)name;
-(NSString *)getMapTypeTitle:(int)type;
-(NSString *)getMapTypeDescription:(int)type;

-(NSArray *)getMapTypeNames;


-(BOOL) isTrackingUser;
-(void) startTrackingUser;
-(void) stopTrackingUser;
-(CLLocation *) getUsersPosition;

-(bool)doesMapItemHaveInfowindow:(GeolMapItem *)item;
-(void)openInfowindow:(GeolMapItem *)item;


-(NSString *)markerIconForLayer:(GeolLayer *) layer;
@end

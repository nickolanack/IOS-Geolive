//
//  GeolMapPane.m
//  Geolive 1.0
//
//  Created by Nicholas Blackwell on 2012-11-06.
//  Copyright (c) 2012 Nicholas Blackwell. All rights reserved.
//

#import "GeolMapPane.h"
#import "GeolMapEventDelegate.h"

//this is an abstract class use GeolMKMapPane

@implementation GeolMapPane

@synthesize mapEventDelegate;
@synthesize map;

-(void) setCenter:(CLLocationCoordinate2D) center{ }
-(CLLocationCoordinate2D) getCenter{
    return CLLocationCoordinate2DMake(0, 0);
}


-(void) setMapType:(int) type{ }
-(int) getMapType{
    return 0;
}


-(NSArray *)getMapTypeNames{
    return nil;
}
-(NSString *)getMapTypeTitle:(int)type{
    return nil;
}
-(NSString *)getMapTypeDescription:(int)type{
    return nil;
}



-(int)getMapTypeFromName:(NSString *)name{
    return 0;
}


-(void) setZoom:(double) zoom{ }
-(int) getZoom{
    return 0;
}

-(MKCoordinateSpan) getSpan{
    return MKCoordinateSpanMake(0, 0);
}

-(void)setSpan:(MKCoordinateSpan)span{ }

-(void) setCenter:(CLLocationCoordinate2D)center AndZoom:(double) zoom{ }
-(void) setCenter:(CLLocationCoordinate2D)center AndSpan:(MKCoordinateSpan) span{ }



-(void) addRenderable:(GeolMapRenderable *) renderable{}
-(void) addRenderables:(NSArray *) renderables{}
-(void) removeRenderable:(GeolMapRenderable *) renderable{}
-(void) removeRenderables:(NSArray*) renderables{}

-(BOOL) isTrackingUser{return false;}
-(void) startTrackingUser{}
-(void) stopTrackingUser{}
-(CLLocation *) getUsersPosition{
    return nil;
}



@end

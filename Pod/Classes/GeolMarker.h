//
//  GeolMarker.h
//  Geolive 1.0
//
//  Created by Nicholas Blackwell on 2012-11-06.
//  Copyright (c) 2012 Nicholas Blackwell. All rights reserved.
//

#import "GeolMapItem.h"
#import <CoreLocation/CoreLocation.h>


@interface GeolMarker : GeolMapItem

@property (getter = getLatlng) CLLocationCoordinate2D latlng;


@end

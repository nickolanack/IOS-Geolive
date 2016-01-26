//
//  GeolPolygon.h
//  Geolive 1.0
//
//  Created by Nick Blackwell on 2012-11-06.
//  Copyright (c) 2012 Nicholas Blackwell. All rights reserved.
//

#import "GeolLine.h"

@interface GeolPolygon : GeolLine
@property (getter = getFill) UIColor *fill;
@property (getter = isOutlined, setter = drawOutline:) BOOL outline;
@end

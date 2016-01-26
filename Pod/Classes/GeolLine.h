//
//  GeolLine.h
//  Geolive 1.0
//
//  Created by Nick Blackwell on 2012-11-06.
//  Copyright (c) 2012 Nicholas Blackwell. All rights reserved.
//

#import "GeolMapItem.h"
#import <UIKit/UIKit.h>

@interface GeolLine : GeolMapItem

@property (getter = getLatlngs) NSArray *latlngs;
@property (getter = getColor) UIColor *color;
@property (getter = getWidth) float width;

@end

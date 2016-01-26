//
//  GeolPolygon.m
//  Geolive 1.0
//
//  Created by Nick Blackwell on 2012-11-06.
//  Copyright (c) 2012 Nicholas Blackwell. All rights reserved.
//

#import "GeolPolygon.h"


 
@implementation GeolPolygon
@synthesize fill, outline;

-(NSString *)getItemTypeName{
    return @"polygon";
}
@end



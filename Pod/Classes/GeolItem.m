//
//  GeolItem.m
//  Geolive 1.0
//
//  Created by Nicholas Blackwell on 2012-11-06.
//  Copyright (c) 2012 Nicholas Blackwell. All rights reserved.
//

#import "GeolItem.h"
#import "GeolMapRenderable.h"




@implementation GeolItem




@synthesize ID, name, description, icon, localID;


-(BOOL)isEditable{
    return false;
}
-(GeolVisibilityState)isVisible{
    return GEOLIVE_ITEM_VISIBLE;
}

-(bool)hasGeoliveID{
    if(self.ID==nil&&(![self.ID isEqualToString:@""]))return false;
    return true;
}

-(bool)hasLocalID{
    if(self.ID==nil&&(![self.ID isEqualToString:@""]))return false;
    return true;
}

@end

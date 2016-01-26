//
//  GeolItem.h
//  Geolive 1.0
//
//  Created by Nicholas Blackwell on 2012-11-06.
//  Copyright (c) 2012 Nicholas Blackwell. All rights reserved.
//

typedef enum GeolVisibilityState
{
    GEOLIVE_ITEM_HIDDEN,
    GEOLIVE_ITEM_VISIBLE,
    GEOLIVE_ITEM_PARTIALLYVISABLE
    
} GeolVisibilityState;


@interface GeolItem : NSObject

    @property (getter = getID) NSString *ID;
    @property (getter = getLocalID) NSString *localID;
    @property (getter = getName) NSString *name;
    @property (getter = getDescription) NSString *description;
    @property (getter = getIcon) NSString *icon;

    -(BOOL) isEditable;
    -(GeolVisibilityState) isVisible;


-(bool)hasGeoliveID;

-(bool)hasLocalID;

@end

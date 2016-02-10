//
//  GeolMapEventDelegate.h
//  Geolive 1.0
//
//  Created by Nicholas Blackwell on 2012-11-14.
//  Copyright (c) 2012 Nicholas Blackwell. All rights reserved.
//  @deprecated
//

#import <Foundation/Foundation.h>
#import "GeolMapItem.h"
@protocol GeolMapEventDelegate <NSObject>


@optional
-(void)mapDidMove;
-(void)mapDidZoom;
-(void)mapTypeDidChange;
-(void)mapLayer:(GeolLayer *) layer addedItem:(GeolMapItem *) item;


@end

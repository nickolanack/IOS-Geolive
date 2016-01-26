//
//  GeolMapRenderableItem.h
//  Geolive 1.0
//
//  Created by Nick Blackwell on 2012-11-06.
//  Copyright (c) 2012 Nicholas Blackwell. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@class GeolMapItem;

@protocol GeolMapRenderableItem <NSObject>

@required

-(GeolMapItem *)getMapItem;
-(void)setMapItem:(GeolMapItem *)mapItem;
-(void)openView:(UIView *) view;

@end

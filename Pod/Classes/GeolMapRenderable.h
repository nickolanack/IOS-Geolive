//
//  GeolMapRenderable.h
//  Geolive 1.0
//
//  Created by Nicholas Blackwell on 2012-11-06.
//  Copyright (c) 2012 Nicholas Blackwell. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GeolMapRenderableItem.h"

@protocol GeolMapRenderable <NSObject>



-(id<GeolMapRenderableItem>) getRenderableItem;
-(void) setRenderableItem:(id<GeolMapRenderableItem>)renderableItem;

@end

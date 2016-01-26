//
//  GeolRenderer.h
//  Geolive 1.0
//
//  Created by Nicholas Blackwell on 2012-11-06.
//  Copyright (c) 2012 Nicholas Blackwell. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GeolMapRenderable.h"
@class GeolMapRenderable;

@protocol GeolRenderer <NSObject>
@required
-(void) addRenderable:(id<GeolMapRenderable>) renderable;
-(void) addRenderables:(NSArray *) renderables;
-(void) removeRenderable:(id<GeolMapRenderable>) renderable;
-(void) removeRenderables:(NSArray*) renderables;
@end
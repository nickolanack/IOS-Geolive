
//
//  Created by Nick Blackwell on 2013-07-25.
//
//

#import <Foundation/Foundation.h>
#import "GeolMapItem.h"


@protocol GeolLayerEventDelegate <NSObject>

@optional
-(void)layerDidShow;
-(void)layerDidHide;
-(void)layerDidAddItem:(GeolMapItem *) item;
-(void)layerDidRemoveItem:(GeolMapItem *) item;
@end


//
//  Created by Nick Blackwell on 2013-07-21.
//
//

#import <Foundation/Foundation.h>


@protocol SystemEventDelegate <NSObject>

@optional

-(void) systemDidChangeConnectionStatus:(bool) connected;

-(void) systemDidChangeUserLoginStatus:(bool) loggedIn;

-(void) systemSetApplicationMode:(NSString *) mode;

-(void) systemClearedApplicationMode:(NSString *) mode;

@end

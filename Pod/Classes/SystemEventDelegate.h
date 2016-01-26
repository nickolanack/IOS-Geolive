//
//  SystemEventDelegate.h
//  Abbisure
//
//  Created by Nick Blackwell on 2013-07-21.
//
//

#import <Foundation/Foundation.h>


@protocol SystemEventDelegate <NSObject>

@optional

-(void) systemDidChangeConnectionStatus:(NSNumber *) connected;
-(void) systemDidChangeUserLoginStatus:(NSNumber *) loggedIn;

-(void) systemSetApplicationMode:(NSString *) mode;
-(void) systemClearedApplicationMode:(NSString *) mode;

@end

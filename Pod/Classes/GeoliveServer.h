//
//  Created by Nick Blackwell on 2013-05-12.
//
//

#import <Foundation/Foundation.h>
#import "Database.h"
#import "JsonSocket.h"
#import "SystemEventDelegate.h"

@interface GeoliveServer : NSObject

@property (readonly, getter = isConnected) bool  connected;
@property (readonly, getter = isLoggedIn) bool loggedIn;

@property (readonly) NSString *server;

-(id)initWithName:(NSString *)name;

-(Database *)getDBObject;


-(bool)attemptConnectionTo:(NSString *)server;
-(JsonSocket *) getJson;



-(bool) registerDevice;
-(bool) loginDevice;
-(bool) createAccount;



-(void)addSystemEventDelegate:(id<SystemEventDelegate>)delegate;
-(void)removeSystemEventDelegate:(id<SystemEventDelegate>)delegate;

-(void)setApplicationMode:(NSString *)mode;
-(void)clearApplicationMode:(NSString *)mode;
-(NSArray *)getApplicationModes;
-(bool)hasApplicationMode:(NSString *)mode;


+(GeoliveServer *) SharedInstance;

@end

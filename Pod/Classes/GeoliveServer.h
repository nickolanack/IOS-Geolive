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



-(void) registerDeviceWithCompletion:(void (^)(NSError * )) completion;
-(void) loginDeviceWithCompletion:(void (^)(NSError * )) completion;
-(void) createAccountWithCompletion:(void (^)(NSError * )) completion;



-(void)addSystemEventDelegate:(id<SystemEventDelegate>)delegate;
-(void)removeSystemEventDelegate:(id<SystemEventDelegate>)delegate;

-(void)performDefaultDeviceLogin:(NSString *) serverUrl withCompletion:(void (^)(NSError *)) completion;
-(bool)isPreparedToRunOffline;

+(GeoliveServer *) SharedInstance;



@end


//
//  Created by Nick Blackwell on 2013-05-12.
//
//

/*
 * Plans for this class.
 * the app delegate should tell this class how to connect and add databases to the global Variables object.
 */


#import "GeoliveServer.h"
#import "StoredParameters.h"
#import "UserDatabase.h"
#import "CacheDatabase.h"
#import "DatabaseStorage.h"
#import "GeoliveServerDelegate.h"
#import <UIKit/UIKit.h>


static GeoliveServer *instance;

@interface GeoliveServer()

@property  Database * database;
@property  JsonSocket *json;
@property id<GeoliveServerDelegate> delegate;
@property NSDictionary *applicationSettings;

/*
 *
 * contains strings defining modes that the application is in
 * depends on the application. an application can add and remove current modes.
 * events delegates are executed on mode changes.
 *
 */
@property NSMutableArray *applicationModes;


@property NSMutableArray *systemEventDelegates;
@property float connectionInterval;


@end



@implementation GeoliveServer

@synthesize connected, loggedIn, server;

-(id)initWithName:(NSString *)name{
    
    self=[super init];
    if(self){
        
        if([[UIApplication sharedApplication].delegate conformsToProtocol:@protocol(GeoliveServerDelegate)]){
            _delegate=[UIApplication sharedApplication].delegate;
        }
        
        if(!instance)instance=self;
        connected=false;
        self.database=[[Database alloc] init];
        self.systemEventDelegates= [[NSMutableArray alloc] init];
        
        
        //[self.database execute:@"DROP table users;"];
        [StoredParameters SetObject:[[UserDatabase alloc] initWithName:name] ForKey:@"UsersDatabase"];
        //create a cache database
        [StoredParameters SetPermanentStorageHandler:[[DatabaseStorage alloc] initWithDatabase:[[CacheDatabase alloc] initWithName:name] AndTable:@"variable"]];
        self.connectionInterval=10.0;
        
        NSLog(@"%s: Initialzing Database Tables: [User, Cache]", __PRETTY_FUNCTION__);
        //NSLog(@"%@: User ID: %d Name:%@, FullName: %@, DeviceId: %d GeoliveAccountId: %d", [self class], [self.userDatabase getCurrentUserId], [self.userDatabase getUsersName], [self.userDatabase getUsersFullname], [self.userDatabase getDeviceId], [self.userDatabase getUsersGeoliveId]);
        
        
        
        
    }
    return self;
}

-(void)connectionStatusUpdateLoop{
    
    // NSLog(@"%s Heartbeat: thu-thump", __PRETTY_FUNCTION__);
    [self confirmConnection];
}

-(bool)confirmConnection{
    @try{
        NSDictionary *dictionary = (NSDictionary *)[self.json requestJsonTask:@"echo" WithParameters:@{@"success": [NSNumber numberWithBool:true]}];
        //NSLog(@"%@", dictionary);
        NSNumber *echo;
        if((echo=[dictionary valueForKey:@"success"])!=nil&&[echo boolValue]!=connected){
            //if key exists 'success', then we are still connected as this method mirrors our ajax variables (adds a few info vars)
            connected=[echo boolValue];
            [self systemDidChangeConnectionStatus];
        }
        
    } @catch(NSException *e){
        //NSLog(@"%@: %@",[self class], e.userInfo);
        
        if(connected){
            NSLog(@"%s: %@",__PRETTY_FUNCTION__, @" Offline Error");
            connected=false;
            [self systemDidChangeConnectionStatus];
        }
        return false;
    }
}

-(bool)attemptConnectionTo:(NSString *)url{
    @try{
        self.json =[[JsonSocket alloc] initWithServer:url];
        NSLog(@"%s: Server connection appears successful",__PRETTY_FUNCTION__);
        connected=true;
        server=url;
    }
    @catch(NSException *e){
        NSLog(@"%s: %@",__PRETTY_FUNCTION__, e.userInfo);
        [[[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Unable to connect to server"] message:[NSString stringWithFormat:@"%@ Attempting to run in offline mode.", [e.userInfo valueForKey:@"NSLocalizedDescription"]] delegate:self cancelButtonTitle:@"continue" otherButtonTitles:nil] show];
        connected=false;
        [self systemDidChangeConnectionStatus];
        return false;
        server=nil;
    }
    [self systemDidChangeConnectionStatus];
    //connection was successful. start conenction loop.
    [NSTimer scheduledTimerWithTimeInterval:self.connectionInterval target:self selector:@selector(connectionStatusUpdateLoop) userInfo:nil repeats:YES];
    
    return true;
}


-(void) registerDeviceWithCompletion:(void (^)(NSError *))completion{
    
    
    UserDatabase *u=(UserDatabase *)[StoredParameters GetObjectForKey:@"UsersDatabase"];
    long myDeviceId=[u getDeviceId];
    //int myGeoliveId=[u getUsersGeoliveId];
    
    
    if(myDeviceId<=0){
        
        
        
        
        [[self getJson] requestJsonTask:@"register_device" WithParameters:@{@"plugin":@"IOSApplication", @"deviceName":[[UIDevice currentDevice]  name]} completion:^(NSDictionary * registration){
            
            // NSLog(@"%s: register_device response_json:%@ response_raw:%@ query:%@", __PRETTY_FUNCTION__, registration, [[self getJson]lastResponse ], [[self getJson] lastQuery]);
            NSArray *keys=[registration allKeys];
            if([keys indexOfObject:@"success"]!=NSNotFound){
                if([(NSNumber *)[registration valueForKey:@"success"] boolValue]){
                    long myNewDeviceId=[(NSNumber *) [registration valueForKey:@"id"] integerValue];
                    
                    if(![u setDeviceId:myNewDeviceId]){
                        NSLog(@"%s: sql error %@, %d",__PRETTY_FUNCTION__,[u error], [u errorNum]);
                    }
                    if(![u setUsersGeoliveId:-1]){
                        NSLog(@"%s: sql error",__PRETTY_FUNCTION__);
                    }
                    
                    completion(nil);
                }
                
            }else{
                NSLog(@"Register Fail: %@",registration);
                completion([[NSError alloc]initWithDomain:@"Failed to register" code:1 userInfo:nil]);
            }
        }];
        
        
        
    }else{
        completion(nil);
    }
    
    
}
-(void)createAccountWithCompletion:(void (^)(NSError *))completion{
    
    UserDatabase *u=(UserDatabase *)[StoredParameters GetObjectForKey:@"UsersDatabase"];
    long myDeviceId=[u getDeviceId];
    long myGeoliveId=[u getUsersGeoliveId];
    
    if(myGeoliveId<=0){
        
        [[self getJson] requestJsonTask:@"create_account" WithParameters:@{@"plugin":@"IOSApplication", @"deviceId":[NSNumber numberWithLong:myDeviceId]} completion:^(NSDictionary * registration) {
            
            NSLog(@"%s: %@", __PRETTY_FUNCTION__, registration);
            
            if(registration!=nil&&[(NSNumber *)[registration valueForKey:@"success"] boolValue]){
                
                long myNewGeoliveId=[(NSNumber *) [registration valueForKey:@"id"] integerValue];
                NSString *myNewUserName=(NSString *) [registration valueForKey:@"username"];
                NSString *myNewPassword=(NSString *) [registration valueForKey:@"password"];
                
                [u setUsersName:myNewUserName];
                [u setUsersPassword:myNewPassword];
                [u setUsersGeoliveId:myNewGeoliveId];
                
                NSLog(@"%s: Updated Account. You should attempt to login", __PRETTY_FUNCTION__);
                completion(nil);
            }else{
                NSLog(@"Create Acount Failed: %@", registration);
                completion([[NSError alloc] initWithDomain:@"Failed to create account" code:1 userInfo:nil]);
            }
       
        }];
        
        
    }else{
        
        NSLog(@"%s: Geoforms account already exists. You should attempt login.", __PRETTY_FUNCTION__);
        completion(nil);
        
    }
}
-(void)loginDeviceWithCompletion:(void (^)(NSError *))completion{
    
    UserDatabase *u=(UserDatabase *)[StoredParameters GetObjectForKey:@"UsersDatabase"];
    long myDeviceId=[u getDeviceId];
    long myGeoliveId=[u getUsersGeoliveId];
    
    NSLog(@"%s: Attempting Login [%ld, %ld]",__PRETTY_FUNCTION__,myDeviceId, myGeoliveId);
    if(myGeoliveId>=0){
     
        
        long myGeoliveId=[u getUsersGeoliveId];
        if(myDeviceId>0&&myGeoliveId>0){
            NSDictionary *json=@{@"plugin":@"IOSApplication", @"deviceId":[NSNumber numberWithLong:myDeviceId], @"accountId":[NSNumber numberWithLong:myGeoliveId], @"username":[((UserDatabase *)[StoredParameters GetObjectForKey:@"UsersDatabase"]) getUsersName], @"password":[((UserDatabase *)[StoredParameters GetObjectForKey:@"UsersDatabase"]) getUsersPassword]};
            
            
            
            if([[json objectForKey:@"username"] isEqualToString:@"empty"]){
                NSLog(@"Empty Username");
                //this probably means that the server failed to generate an acount for this device/localuser
                //the local user database creates a placeholder uname='empty' and then askes the server to provide usable values.
            }
            
            NSDictionary *login=[[self getJson] requestJsonTask:@"login_device" WithParameters: json];
            NSLog(@"%@",[[self getJson] lastQuery]);
            
            if(login!=nil&&[(NSNumber *)[login valueForKey:@"success"] boolValue]!=true){
                
                switch ([(NSNumber *)[login valueForKey:@"code"] integerValue]) {
                    case 2:
                    {
                        
                        completion([[NSError alloc] initWithDomain:@"Server Communication Error" code:2 userInfo:nil]);
                        
                    }
                        break;
                    case 3: //device mismatch
                        
                    {
                        
                        if(![u setUsersGeoliveId:-1]){
                            NSLog(@"%s: sql error",__PRETTY_FUNCTION__);
                        }
                        
                        if(![u setDeviceId:-1]){
                            NSLog(@"%s: sql error",__PRETTY_FUNCTION__);
                        }
                        
                        [self registerDeviceWithCompletion:^(NSError * err) {
                            //TODO: move code here
                            if(err){
                                completion(err);
                            }else{
                                //recurse
                                [self loginDeviceWithCompletion:completion];
                            }
                            
                        }];
                    }
                        
                        break;
                        
                    case 4:
                    {
                        [[self getJson] requestJsonTask:@"get_activation_type" WithParameters: @{@"plugin":@"IOSApplication"} completion:^(NSDictionary * activation) {
                            completion([self checkActivation:activation]);
                            
                        }];
                    }
                        break;
                    case 5:
                    {
                        
                        if(_delegate&&[_delegate respondsToSelector:@selector(geoliveUserAccountRequiresEmailVerification)]){
                            [_delegate geoliveUserAccountRequiresEmailVerification];
                            completion(nil);
                        }else{
                            [self showAlertViewForEmailVerification];
                            completion([[NSError alloc] initWithDomain:@"Requires Email Verification" code:5 userInfo:nil]);
                        }
                    }
                        break;
                    default:
                        
                        NSLog(@"%@",login);
                        completion([[NSError alloc] initWithDomain:@"Unknown Error" code:1 userInfo:nil]);
                        break;
                        
                        
                }
                
                
            }else if([(NSNumber *)[login valueForKey:@"success"] boolValue]){
                //request a new session key after login, this might have changed.
                NSLog(@"%s: You are logged in!",__PRETTY_FUNCTION__);
                loggedIn=true;
                [self systemDidChangeUserLoginStatus];
                [[self getJson] requestServerSession];
                completion(nil);
            }else{
                NSLog(@"%s: Failed Login Attempt %@, %@",__PRETTY_FUNCTION__ ,[[self getJson] lastQuery], [[self getJson] lastResponse]);
                completion([[NSError alloc] initWithDomain:@"Failed Login Attempt" code:1 userInfo:nil]);
            }
            
        }else{
            
            NSLog(@"%s: Cannot Login [%ld, %ld]",__PRETTY_FUNCTION__,[u getDeviceId], [u getUsersGeoliveId]);
            loggedIn=false;
            [self systemDidChangeUserLoginStatus];
            completion([[NSError alloc] initWithDomain:@"Cannot Login" code:1 userInfo:nil]);
            
        }
        
    }else{
        
        [self createAccountWithCompletion:^(NSError * err) {
            if(err){
                completion(err);
            }else{
                
                [self loginDeviceWithCompletion:completion];
            }
        }];
    }
    
    
    
    
    
}


-(NSError *)checkActivation:(NSDictionary *)activation{
    
    UserDatabase *u=(UserDatabase *)[StoredParameters GetObjectForKey:@"UsersDatabase"];
    long myDeviceId=[u getDeviceId];
    long myGeoliveId=[u getUsersGeoliveId];

    NSLog(@"%s: %@, %@", __PRETTY_FUNCTION__, [[self getJson] lastQuery],[[self getJson] lastResponse]);
    NSLog(@"Activation Type: %@",activation);
    if(activation!=nil&&[(NSNumber *)[activation valueForKey:@"success"] boolValue]==true){
        
        if([[activation valueForKey:@"activation"] isEqualToString:@"none"]){
            NSString *code;
            if([StoredParameters HasCachedKey:@"activation_code"]){
                code=[StoredParameters GetObjectForKey:@"activation_code"];
            }else{
                
                NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
                NSMutableString *one = [NSMutableString stringWithCapacity: 5];
                NSMutableString *two = [NSMutableString stringWithCapacity: 5];
                
                for (int i=0; i<5; i++) {
                    [one appendFormat: @"%C", [letters characterAtIndex: arc4random() % [letters length]]];
                    [two appendFormat: @"%C", [letters characterAtIndex: arc4random() % [letters length]]];
                }
                //really just disguising the activation code. the device and account should be activatable by an administrator with
                //the device id and the geolive id.
                code=[NSString stringWithFormat:@"%@.%ld_%ld.%@", one, myDeviceId, myGeoliveId,two];
                [StoredParameters SetAndCacheObject:code ForKey:@"activation_code"];
            }
            
            
            
            if(_delegate&&[_delegate respondsToSelector:@selector(geoliveUserAccountRequiresAdministratorActivationWithCode:)]){
                [_delegate geoliveUserAccountRequiresAdministratorActivationWithCode:code];
                return nil;
            }else{
                [self showAlertViewForActivationWithCode:code];
                return [[NSError alloc] initWithDomain:@"Requires Administrator Activation" code:4 userInfo:nil];
            }
            
            
        }
        if([[activation valueForKey:@"activation"] isEqualToString:@"email"]){
            
            if(_delegate&&[_delegate respondsToSelector:@selector(geoliveUserAccountRequiresEmailActivation)]){
                [_delegate geoliveUserAccountRequiresEmailActivation];
                return nil;
            }else{
                [self showAlertViewForEmailActivationWithEmailAddress:@""];
                return [[NSError alloc] initWithDomain:@"Requires Email Activation" code:4 userInfo:nil];
            }
            
            
            
            
        }
        
        
        
    }else{
        NSLog(@"%s: %@, %@", __PRETTY_FUNCTION__, [[self getJson] lastQuery],[[self getJson] lastResponse]);
    }
    
    
    return nil;

}



- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    
    NSString *buttonTitle=[alertView buttonTitleAtIndex:buttonIndex];
    if([buttonTitle isEqualToString:@"activate"]) {
        NSString *email=[alertView textFieldAtIndex:0].text;

        [self activateAccountWithEmailAddress:email withCompletion:^(NSError * err) {
            if(err){
            
                [self showInvalidAlertViewForEmailActivationWithEmailAddress:email];
            
            }else{
            
                [self showSuccessAlertViewForEmailActivationWithEmailAddress:email];
            
            
            }
        }];
        
        
    }
    if([buttonTitle isEqualToString:@"send again"]) {
        [self showAlertViewForEmailActivationWithEmailAddress:@""];
    }
    
    
}

-(void)showAlertViewForEmailActivationWithEmailAddress:(NSString *)email{
    //notify user that application has not been authenticated
    UIAlertView *message=[[UIAlertView alloc] initWithTitle:@"Activate This Device" message:@"please enter your email address" delegate:self cancelButtonTitle:@"later" otherButtonTitles:@"activate",nil];
    [message setAlertViewStyle:UIAlertViewStylePlainTextInput];
    [message textFieldAtIndex:0].text=@"nickblackwell82@gmail.com";
    [message show];

}

-(void)showInvalidAlertViewForEmailActivationWithEmailAddress:(NSString *)email{
    //notify user that application has not been authenticated
    UIAlertView *message=[[UIAlertView alloc] initWithTitle:@"Activate This Device" message:@"the email address entered is invalid. try again?" delegate:self cancelButtonTitle:@"later" otherButtonTitles:@"activate",nil];
    [message setAlertViewStyle:UIAlertViewStylePlainTextInput];
    [message textFieldAtIndex:0].text=email;
    
    [message show];
    
}

-(void)showSuccessAlertViewForEmailActivationWithEmailAddress:(NSString *)email{
    UIAlertView *message=[[UIAlertView alloc] initWithTitle:@"" message:[NSString stringWithFormat:@"activation was successful please check your email: (%@) to verify your account",email] delegate:self cancelButtonTitle:@"great" otherButtonTitles:nil];
    [message show];
    
}

-(void)showAlertViewForEmailVerification{
    UIAlertView *message=[[UIAlertView alloc] initWithTitle:@"Activation Email Sent" message:@"go to your email inbox and activate this device" delegate:self cancelButtonTitle:@"close" otherButtonTitles:@"send again",nil];
    [message show];
}


-(void)showAlertViewForActivationWithCode:(NSString *)code{
    //notify user that application has not been authenticated
    UIAlertView *message=[[UIAlertView alloc] initWithTitle:@"This Device Requires Activation" message:[NSString stringWithFormat:@"Activation Code: %@",code] delegate:nil cancelButtonTitle:@"close" otherButtonTitles:nil];
    [message show];
    
}


-(void)activateAccountWithEmailAddress:(NSString *)email withCompletion:(void (^)(NSError *))completion{
    //notify user that application has not been authenticated
    long myDeviceId=[((UserDatabase *)[StoredParameters GetObjectForKey:@"UsersDatabase"]) getDeviceId]; //[[self getUserDatabase] getDeviceId];
    long myGeoliveId=[((UserDatabase *)[StoredParameters GetObjectForKey:@"UsersDatabase"]) getUsersGeoliveId];
    
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    if([emailTest evaluateWithObject:email]){
        [[self getJson] requestJsonTask:@"activate" WithParameters: @{@"plugin":@"IOSApplication", @"email":email, @"deviceId":[NSNumber numberWithLong:myDeviceId], @"accountId":[NSNumber numberWithLong:myGeoliveId]} completion:^(NSDictionary * activation) {
            
            NSLog(@"%@", activation);
            completion(nil);
            
        }];
    }else{
        completion([[NSError alloc] initWithDomain:@"Invalid Email" code:2 userInfo:nil]);
    }
    

}



-(Database *)getDBObject{
    return self.database;
}


-(JsonSocket *) getJson{
    return self.json;
}


-(void)addSystemEventDelegate:(id<SystemEventDelegate>)delegate{
    
    if([self.systemEventDelegates indexOfObject:delegate]==NSNotFound){
        [self.systemEventDelegates addObject:delegate];
    }else{
        
    }
    
}
-(void)removeSystemEventDelegate:(id<SystemEventDelegate>)delegate{
    [self.systemEventDelegates removeObject:delegate];
}

-(void)systemDidChangeUserLoginStatus{
    NSEnumerator *e = [self.systemEventDelegates objectEnumerator];
    id<SystemEventDelegate> item;
    while ((item = (id<SystemEventDelegate>)[e nextObject])) {
        NSLog(@"%s: %@",__PRETTY_FUNCTION__, [e class]);
        if([item respondsToSelector:@selector(systemDidChangeUserLoginStatus:)]){
            //NSLog(@"%@: Execute Map Type Change Delegate: %@",[self class], [item class]);
            [item performSelector:@selector(systemDidChangeUserLoginStatus:) withObject:[NSNumber numberWithBool: loggedIn]];
        }
    }
    
    
}

-(void) systemDidChangeConnectionStatus{
    NSEnumerator *e = [self.systemEventDelegates objectEnumerator];
    id<SystemEventDelegate> item;
    while ((item = (id<SystemEventDelegate>)[e nextObject])) {
        //NSLog(@"%s: %@",__PRETTY_FUNCTION__, [e class]);
        if([item respondsToSelector:@selector(systemDidChangeConnectionStatus:)]){
            //NSLog(@"%@: Execute Map Type Change Delegate: %@",[self class], [item class]);
            [item performSelector:@selector(systemDidChangeConnectionStatus:) withObject:[NSNumber numberWithBool: connected]];
        }
    }
}



-(void)performDefaultDeviceLogin:(NSString *) serverUrl withCompletion:(void (^)(NSError *)) completion{
    if([self attemptConnectionTo:serverUrl]){
        //connect to the geolive server for this app, establish session. or try to go into offline mode.
        [self registerDeviceWithCompletion:^(NSError * err) {
            if(err){
                completion(err);
            }else{
                
                [self loginDeviceWithCompletion:^(NSError * err) {
                    if(err){
                        completion(err);
                        
                    }else{
                        NSLog(@"%s: %@", __PRETTY_FUNCTION__, [[self getJson] lastQuery]);
                        NSLog(@"%s: %@", __PRETTY_FUNCTION__,[[self getJson] lastResponse]);
                        completion(nil);
                    }
                }];
            }
        }];
        
        
    }else{
        completion([[NSError alloc] initWithDomain:@"Failed connection to server" code:1 userInfo:nil]);
    }
    
}

-(void)loadDefaultApplicationSettingsWithCompletion:(void (^)(NSError *, NSDictionary *)) completion{
    [[self getJson] requestJsonTask:@"get_application_settings" WithParameters: @{@"plugin":@"IOSApplication"} completion:^(NSDictionary * settings) {
    
        NSLog(@"%@", settings);
        if(settings&&[settings isKindOfClass:[NSDictionary class]]&&[[settings objectForKey:@"settings"] isKindOfClass:[NSDictionary class]]){
            _applicationSettings=[self formatApplicationSettings:[settings objectForKey:@"settings"]];
            completion(nil, [settings objectForKey:@"settings"]);
            return;
        }
    
        completion([[NSError alloc] initWithDomain:@"Invalid Settings From Server" code:1 userInfo:nil],nil);
    }];

}

-(NSDictionary *)formatApplicationSettings:(NSDictionary *)settings{
    //should ensure that settings formatted correctly. add missing default values.
    return settings;
}




-(void)setApplicationSettings:(NSDictionary *) settings{
    _applicationSettings=settings;
}

-(NSString *)getDefaultLayer{
    return @"11";
}


-(NSString *)getDefaultIcon{
    
    if(_applicationSettings&&[_applicationSettings objectForKey:@"form"]){
    
        return [[_applicationSettings objectForKey:@"form"] objectForKey:@"icon"];
    
    }
    
    return @"DEFAULT";
}

-(NSArray *)getDefaultAttributeFields{
    return @[];
}

-(NSString *)getDefaultAttributeTable{
    return nil;
}

-(bool)isPreparedToRunOffline{
    //TODO: should check that user should be able to login.
    // should check that network is actually unavailable.
    // should check that details are cached.
    return true;
    
}


+(GeoliveServer *) SharedInstance{
    if(!instance){
        @throw [[NSException alloc] initWithName:@"No GeoliveServer Instance" reason:@"Expected GeoliveServer to be instantiated by Application Delegate" userInfo:nil];
    }
    return instance;
}

@end

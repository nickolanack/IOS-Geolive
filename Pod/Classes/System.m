//
//  System.m
//  Abbisure
//
//  Created by Nick Blackwell on 2013-05-12.
//
//

/*
 * Plans for this class.
 * the app delegate should tell this class how to connect and add databases to the global Variables object.
 */


#import "System.h"
#import "Variables.h"
#import "UserDatabase.h"
#import "CacheDatabase.h"
#import <UIKit/UIKit.h>


static System *instance;

@interface System()

@property  Database * database;
@property  JsonSocket *json;

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



@implementation System

@synthesize connected, loggedIn, server;

-(id)initWithName:(NSString *)name{
    
    self=[super init];
    if(self){
        if(!instance)instance=self;
        connected=false;
        self.database=[[Database alloc] init];
        self.systemEventDelegates= [[NSMutableArray alloc] init];
        
        
        //[self.database execute:@"DROP table users;"];
        [Variables SetObject:[[UserDatabase alloc] initWithName:name] ForKey:@"UsersDatabase"];
        //create a cache database
        [Variables SetDatabase:[[CacheDatabase alloc] initWithName:name]];
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
        NSDictionary *dictionary = (NSDictionary *)[self.json queryTask:@"echo" WithJson:@{@"success": [NSNumber numberWithBool:true]}];
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
        [[[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Unable to connect to: %@",server] message:[NSString stringWithFormat:@"%@ Attempting to run in offline mode.", [e.userInfo valueForKey:@"NSLocalizedDescription"]] delegate:self cancelButtonTitle:@"continue" otherButtonTitles:nil] show];
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



-(bool) registerDevice{
    
    
    UserDatabase *u=(UserDatabase *)[Variables GetObjectForKey:@"UsersDatabase"];
    long myDeviceId=[u getDeviceId];
    //int myGeoliveId=[u getUsersGeoliveId];

    
    if(myDeviceId<=0){
        
        NSDictionary * registration = [[self getJson] queryTask:@"register_device" WithJson:@{@"plugin":@"IOSApplication", @"deviceName":[[UIDevice currentDevice]  name]}];
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
                
                return true;
            }
            
        }
        NSLog(@"Register Fail: %@",registration);
        
        
    }else{
        return true;
    }
    
    return false;
    
}
-(bool)createAccount{
    
    UserDatabase *u=(UserDatabase *)[Variables GetObjectForKey:@"UsersDatabase"];
    long myDeviceId=[u getDeviceId];
    long myGeoliveId=[u getUsersGeoliveId];
    
    if(myGeoliveId<=0){
        
        NSDictionary * registration =[[self getJson] queryTask:@"create_account" WithJson:@{@"plugin":@"IOSApplication", @"deviceId":[NSNumber numberWithLong:myDeviceId]}];
        NSLog(@"%s: %@", __PRETTY_FUNCTION__, registration);
        
        if(registration!=nil&&[(NSNumber *)[registration valueForKey:@"success"] boolValue]){
            
            long myNewGeoliveId=[(NSNumber *) [registration valueForKey:@"id"] integerValue];
            NSString *myNewUserName=(NSString *) [registration valueForKey:@"username"];
            NSString *myNewPassword=(NSString *) [registration valueForKey:@"password"];
            
            [u setUsersName:myNewUserName];
            [u setUsersPassword:myNewPassword];
            [u setUsersGeoliveId:myNewGeoliveId];
            
            NSLog(@"%s: Updated Account. You should attempt to login", __PRETTY_FUNCTION__);
            return true;
        }else{
            NSLog(@"Create Acount Failed: %@", registration);
        }
        
    }else{
        
        NSLog(@"%s: Geoforms account already exists. You should attempt login.", __PRETTY_FUNCTION__);
        return true;
        
    }
    return false;
}
-(bool)loginDevice{
    
    UserDatabase *u=(UserDatabase *)[Variables GetObjectForKey:@"UsersDatabase"];
    long myDeviceId=[u getDeviceId];
    long myGeoliveId=[u getUsersGeoliveId];
    
    NSLog(@"%s: Attempting Login [%ld, %ld]",__PRETTY_FUNCTION__,myDeviceId, myGeoliveId);
    if(myGeoliveId>=0||[self createAccount]){
        long myGeoliveId=[u getUsersGeoliveId];
        if(myDeviceId>0&&myGeoliveId>0){
            NSDictionary *json=@{@"plugin":@"IOSApplication", @"deviceId":[NSNumber numberWithLong:myDeviceId], @"accountId":[NSNumber numberWithLong:myGeoliveId], @"username":[((UserDatabase *)[Variables GetObjectForKey:@"UsersDatabase"]) getUsersName], @"password":[((UserDatabase *)[Variables GetObjectForKey:@"UsersDatabase"]) getUsersPassword]};
           
            
            
            if([[json objectForKey:@"username"] isEqualToString:@"empty"]){
                NSLog(@"Empty Username");
                //this probably means that the server failed to generate an acount for this device/localuser
                //the local user database creates a placeholder uname='empty' and then askes the server to provide usable values.
            }
            
            NSDictionary *login=[[self getJson] queryTask:@"login_device" WithJson: json];
            NSLog(@"%@",[[self getJson] lastQuery]);
            
            if(login!=nil&&[(NSNumber *)[login valueForKey:@"success"] boolValue]!=true){
                
                switch ([(NSNumber *)[login valueForKey:@"code"] integerValue]) {
                    case 2:
                    {
                        UIAlertView *message=[[UIAlertView alloc] initWithTitle:@"Server Communication Error" message:[NSString stringWithFormat:@"%@",[login valueForKey:@"error"]] delegate:nil cancelButtonTitle:@"close" otherButtonTitles:nil];
                        [message show];
                    }
                        break;
                    case 3:
                        
                    {
                        if(![u setUsersGeoliveId:-1]){
                            NSLog(@"%s: sql error",__PRETTY_FUNCTION__);
                        }
                        
                        if(![u setDeviceId:-1]){
                            NSLog(@"%s: sql error",__PRETTY_FUNCTION__);
                        }
                        
                        [self registerDevice];
                    }
                        
                        break;
                        
                    case 4:
                    {
                        [[self getJson] queryTask:@"get_activation_type" WithJson: @{@"plugin":@"IOSApplication"} completion:^(NSDictionary * activation) {
                            NSLog(@"%s: %@, %@", __PRETTY_FUNCTION__, [[self getJson] lastQuery],[[self getJson] lastResponse]);
                            NSLog(@"Activation Type: %@",activation);
                            if(activation!=nil&&[(NSNumber *)[activation valueForKey:@"success"] boolValue]==true){
                                
                                if([[activation valueForKey:@"activation"] isEqualToString:@"none"]){
                                    NSString *code;
                                    if([Variables HasCachedKey:@"activation_code"]){
                                        code=[Variables GetObjectForKey:@"activation_code"];
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
                                        code=[NSString stringWithFormat:@"%@.%ld_%ld.%@", one,myDeviceId, myGeoliveId,two];
                                        [Variables SetAndCacheObject:code ForKey:@"activation_code"];
                                    }
                                    
                                    
                                    
                                    //notify user that application has not been authenticated
                                    UIAlertView *message=[[UIAlertView alloc] initWithTitle:@"This Device Requires Activation" message:[NSString stringWithFormat:@"Activation Code: %@",code] delegate:nil cancelButtonTitle:@"close" otherButtonTitles:nil];
                                    [message show];
                                    
                                }
                                if([[activation valueForKey:@"activation"] isEqualToString:@"email"]){
                                    
                                    //notify user that application has not been authenticated
                                    UIAlertView *message=[[UIAlertView alloc] initWithTitle:@"Activate This Device" message:@"please enter your email address" delegate:self cancelButtonTitle:@"later" otherButtonTitles:@"activate",nil];
                                    [message setAlertViewStyle:UIAlertViewStylePlainTextInput];
                                    [message textFieldAtIndex:0].text=@"nickblackwell82@gmail.com";
                                    [message show];
                                    
                                }
                                
                            }else{
                                NSLog(@"%s: %@, %@", __PRETTY_FUNCTION__, [[self getJson] lastQuery],[[self getJson] lastResponse]);
                            }
                            
                            
                        }];
                    }
                        break;
                    case 5:
                    {
                        
                        UIAlertView *message=[[UIAlertView alloc] initWithTitle:@"Activation Email Sent" message:@"go to your email inbox and activate this device" delegate:self cancelButtonTitle:@"close" otherButtonTitles:@"send again",nil];
                        [message show];
                    }
                        break;
                    default:
                        
                        NSLog(@"%@",login);
                        
                        break;
                        
                        
                }
                
                
            }else if([(NSNumber *)[login valueForKey:@"success"] boolValue]){
                //request a new session key after login, this might have changed.
                NSLog(@"%s: You are logged in!",__PRETTY_FUNCTION__);
                loggedIn=true;
                [self systemDidChangeUserLoginStatus];
                [[self getJson] requestServerSession];
                return true;
            }else{
                NSLog(@"%s: Failed Login Attempt %@, %@",__PRETTY_FUNCTION__ ,[[self getJson] lastQuery], [[self getJson] lastResponse]);
            }
            
        }else{
            
            
            
            if(myDeviceId>0&&myGeoliveId<=0&&[self createAccount]){
                return [self loginDevice];
            }else{
            
                if(myDeviceId<=0)NSLog(@"Invalid Device ID: %ld", myDeviceId);
                if(myGeoliveId<=0)NSLog(@"Invalid Geolive ID: %ld", myGeoliveId);
                NSLog(@"%s: Failed Login Invalid IDs",__PRETTY_FUNCTION__);
                loggedIn=false;
                [self systemDidChangeUserLoginStatus];
                
            }
            
           
            
        }
    }
    
    NSLog(@"%s: Cannot Login [%ld, %ld]",__PRETTY_FUNCTION__,[u getDeviceId], [u getUsersGeoliveId]);
    loggedIn=false;
    [self systemDidChangeUserLoginStatus];
    
    return false;
    
    
}



- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    
    NSString *buttonTitle=[alertView buttonTitleAtIndex:buttonIndex];
    if([buttonTitle isEqualToString:@"activate"]) {
        NSString *email=[alertView textFieldAtIndex:0].text;
        //notify user that application has not been authenticated
        long myDeviceId=[((UserDatabase *)[Variables GetObjectForKey:@"UsersDatabase"]) getDeviceId]; //[[self getUserDatabase] getDeviceId];
        long myGeoliveId=[((UserDatabase *)[Variables GetObjectForKey:@"UsersDatabase"]) getUsersGeoliveId];
        
        NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
        NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
        if([emailTest evaluateWithObject:email]){
            [[self getJson] queryTask:@"activate" WithJson: @{@"plugin":@"IOSApplication", @"email":email, @"deviceId":[NSNumber numberWithLong:myDeviceId], @"accountId":[NSNumber numberWithLong:myGeoliveId]} completion:^(NSDictionary * activation) {
                UIAlertView *message=[[UIAlertView alloc] initWithTitle:@"" message:[NSString stringWithFormat:@"%@",activation] delegate:self cancelButtonTitle:@"cool" otherButtonTitles:nil];
                [message show];
                //UIAlertView *message=[[UIAlertView alloc] initWithTitle:@"Activation Submitted" message:@"do you want to go to your inbox?" delegate:self cancelButtonTitle:@"later" otherButtonTitles:@"email",nil];
                //[message show];
                
            }];
        }else{
            
            //notify user that application has not been authenticated
            UIAlertView *message=[[UIAlertView alloc] initWithTitle:@"Activate This Device" message:@"the email address entered is invalid. try again?" delegate:self cancelButtonTitle:@"later" otherButtonTitles:@"activate",nil];
            [message setAlertViewStyle:UIAlertViewStylePlainTextInput];
            [message textFieldAtIndex:0].text=email;
            
            [message show];
        }
        
    }
    if([buttonTitle isEqualToString:@"send again"]) {
        
        UIAlertView *message=[[UIAlertView alloc] initWithTitle:@"Activate This Device" message:@"please enter your email address" delegate:self cancelButtonTitle:@"later" otherButtonTitles:@"activate",nil];
        [message setAlertViewStyle:UIAlertViewStylePlainTextInput];
        [message textFieldAtIndex:0].text=@"nickblackwell82@gmail.com";
        [message show];
        
    }
    
    
}
+(System *) GetInstance{
    return instance;
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



-(void)setApplicationMode:(NSString *)mode{
    if(![self hasApplicationMode:mode]){

        [self.applicationModes addObject:[NSString stringWithString:mode]];
        NSEnumerator *e = [self.systemEventDelegates objectEnumerator];
        id<SystemEventDelegate> item;
        while ((item = (id<SystemEventDelegate>)[e nextObject])) {
            //NSLog(@"%s: %@",__PRETTY_FUNCTION__, [e class]);
            if([item respondsToSelector:@selector(systemSetApplicationMode:)]){
                //NSLog(@"%@: Execute Map Type Change Delegate: %@",[self class], [item class]);
                [item performSelector:@selector(systemSetApplicationMode:) withObject:[NSString stringWithString:mode]];
            }
        }
    }
}


-(void)clearApplicationMode:(NSString *)mode{
    if([self hasApplicationMode:mode]){
        [self.applicationModes removeObject:[NSString stringWithString:mode]];
        NSEnumerator *e = [self.systemEventDelegates objectEnumerator];
        id<SystemEventDelegate> item;
        while ((item = (id<SystemEventDelegate>)[e nextObject])) {
            //NSLog(@"%s: %@",__PRETTY_FUNCTION__, [e class]);
            if([item respondsToSelector:@selector(systemClearedApplicationMode:)]){
                //NSLog(@"%@: Execute Map Type Change Delegate: %@",[self class], [item class]);
                [item performSelector:@selector(systemClearedApplicationMode:) withObject:[NSString stringWithString:mode]];
            }
        }
    
    }

}
-(NSArray *)getApplicationModes{
    return [NSArray arrayWithArray:self.applicationModes];

}
-(bool)hasApplicationMode:(NSString *)mode{
    return ([self.applicationModes indexOfObject: mode]!=NSNotFound);
}

@end

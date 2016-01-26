//
//  AGlUserDatabase.m
//  Abbisure
//
//  Created by Nick Blackwell on 2013-05-12.
//
//

#import "UserDatabase.h"
#import "ResultSet.h"
#import <UIKit/UIKit.h>
@interface UserDatabase()

@property int userId;

@end

@implementation UserDatabase

-(id) initWithName:(NSString *)name{
    
    self=[super init];
    if(self){
        
        self.tableDefinitions=@{
                                @"users":
                                    @"CREATE TABLE IF NOT EXISTS users (userid INTEGER PRIMARY KEY AUTOINCREMENT, geolid INTEGER DEFAULT -1, deviceid INTEGER DEFAULT -1,  uname TEXT, fullname TEXT, password TEXT, data TEXT, passcode TEXT, email TEXT);",
                                @"usersSession":
                                    @"CREATE TABLE IF NOT EXISTS usersSession (userid INTEGER, geolid INTEGER, loggedInTime TIMESTAMP DEFAULT CURRENT_TIMESTAMP, token TEXT, tokenValue TEXT, data TEXT);",
                                @"usersVariables":
                                    @"CREATE TABLE IF NOT EXISTS usersVariables (userid INTEGER, geolid INTEGER, data TEXT, type TEXT);"
                                };
     
        
        [self open:name];
        [self checkTables];
        self.userId=-1;
        [self getCurrentUserId]; //initializes current user
        
    }
    return self;
    
}



-(int)countUsers{
    return (int)[(NSNumber *)[[self query:@"SELECT count(*) FROM users;"] firstValue] integerValue];
}

-(NSArray *)listUserIDs{
    NSMutableArray *ids=[[NSMutableArray alloc] init];
    ResultSet *r=[self query:@"SELECT userid FROM users"];
    while([r hasNext]){
        [ids addObject:[[r next] objectAtIndex:0]];
    }
    return [[NSArray alloc] initWithArray:ids];
}
-(long)getCurrentUserId{
    
    if(self.userId>=0)return self.userId;
    int count=[self countUsers];
    if(count==1){
        self.userId=(int)[(NSNumber *)[[self query:@"SELECT userid FROM users"] firstValue] integerValue];
        return self.userId;
    }
    if(count==0){
        [self createAccountUser:@"empty" Password:@""];
        [self setUsersFullname:[Database Strip:[[UIDevice currentDevice] name]]];
        return [self getCurrentUserId];
    }
    
    
    return -1;
}
-(void)setCurrentUserId:(long)userId{
    if([(NSNumber *)[[self query:[NSString stringWithFormat:@"Select count(*) FROM users WHERE userid=%ld",userId]] firstValue] integerValue]==0){
        //throw exception nonexistant user.
        
    }else{
        self.userId=(int)userId;
    }
    
}
-(bool)createAccountUser:(NSString *)name Password:(NSString *)password{
    
    [self execute:[NSString stringWithFormat:@"INSERT INTO users (uname, password) VALUES ('%@','%@')",name, password]];
    self.userId=(int)[self lastInsertId];
    return true;
    
}

-(NSString *) getUsersName{
    NSString *username=[self getUsersName:[self getCurrentUserId]];
    return username;
}

-(NSString *) getUsersName:(long)userId{

    if(userId>=1){
        NSString *name= (NSString *)[[self query:[NSString stringWithFormat:@"SELECT uname FROM users WHERE userid=%ld",userId]] firstValue];
        return name;
    }else{
        //exception no user.
    }
    return nil;
}

-(bool)setUsersName:(NSString *)name{
    
    long userid=[self getCurrentUserId];
    return [self execute:[NSString stringWithFormat:@"UPDATE users SET uname='%@' WHERE userid=%ld",[Database Escape:name],userid]];
    
}

-(bool)userHasPasscode{
    return [self userHasPasscode:self.userId];
}
-(bool)userHasPasscode:(long)userId{
    NSString *pass=[[self query:[NSString stringWithFormat:@"SELECT passcode FROM users WHERE userid=%ld",userId]] firstValue];
    if(pass==nil||[pass isEqualToString:@""])return false;
    return true;
}

-(NSString *) getUsersFullname{
    return [self getUsersFullname:[self getCurrentUserId]];
}
-(NSString *) getUsersFullname:(long)userId{

    if(userId>=1){
        return (NSString *)[[self query:[NSString stringWithFormat:@"SELECT fullname FROM users WHERE userid=%ld",userId]] firstValue];
    }else{
        //exception no user.
    }
    return nil;

}
-(bool)setUsersFullname:(NSString *)fullname{
    
    long userid=[self getCurrentUserId];
    return [self execute:[NSString stringWithFormat:@"UPDATE users SET fullname='%@' WHERE userid=%ld",fullname,userid]];
}



-(long)getDeviceId:(long)userId{

    long uid= [(NSNumber *)[[self query:[NSString stringWithFormat:@"SELECT deviceid FROM users WHERE userid=%ld",userId]] firstValue] integerValue];
    return uid;
}
-(long)getDeviceId{
    long uid=  [self getDeviceId:self.userId];
    
    if(uid<=0){
        uid= [(NSNumber *)[[self query:[NSString stringWithFormat:@"SELECT deviceid FROM users WHERE deviceid>0"]] firstValue] integerValue];
        if(uid>0){
            [self setDeviceId:uid];
        }
    }

    
    return uid;
}

-(bool)setDeviceId:(long)deviceid{
    
    bool success= [self execute:[NSString stringWithFormat:@"UPDATE users SET deviceid=%ld",deviceid]];
    return success;
}



-(bool)setUsersGeoliveId:(long)geoliveid{
    long userid=[self getCurrentUserId];
    bool success=[self execute:[NSString stringWithFormat:@"UPDATE users SET geolid=%ld WHERE userid=%ld",geoliveid,userid]];
    return success;
}

-(long)getUsersGeoliveId:(long)userId{
    long guid= [(NSNumber *)[[self query:[NSString stringWithFormat:@"SELECT geolid FROM users WHERE userid=%ld",userId]] firstValue] integerValue];
    return guid;
}

-(long)getUsersGeoliveId{
    long guid= [self getUsersGeoliveId:self.userId];
    return guid;
}

-(bool)setUsersPassword:(NSString *)password{
    long userid=[self getCurrentUserId];
    return [self execute:[NSString stringWithFormat:@"UPDATE users SET password='%@' WHERE userid=%ld",password,userid]];
}

-(NSString *)getUsersPassword{
    return [self getUsersPassword:[self getCurrentUserId]];
}

-(NSString *)getUsersPassword:(long)userId{
    if(userId>=1){
        return (NSString *)[[self query:[NSString stringWithFormat:@"SELECT password FROM users WHERE userid=%ld",userId]] firstValue];
    }else{
        //exception no user.
    }
    return nil;
}

-(bool)deleteUser:(long)userId{
    if(userId>=1){
        return [self execute:[NSString stringWithFormat:@"DELETE FROM users WHERE userid=%ld",userId]];
    }else{
        //exception no user.
    }
    return false;
}

@end

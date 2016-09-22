
//
//  Created by Nick Blackwell on 2013-05-12.
//
//

#import "Database.h"

@interface UserDatabase : Database

-(id) initWithName:(NSString *)name;

-(int)countUsers;
-(NSArray *)listUserIDs;
-(long)getCurrentUserId;
-(void)setCurrentUserId:(long)userId;
//create an account can set name and password to empty strings
-(bool)createAccountUser:(NSString *)name Password:(NSString *)password;

-(NSString *) getUsersName;
-(NSString *) getUsersName:(long)userId;

-(bool)setUsersName:(NSString *)name;
    
-(NSString *) getUsersFullname;
-(NSString *) getUsersFullname:(long)userId;
-(bool)setUsersFullname:(NSString *)fullname;


-(bool)setDeviceId:(long)deviceid;
-(long)getDeviceId;
-(long)getDeviceId:(long)userId;

-(bool)setUsersGeoliveId:(long)geoliveid;
-(long)getUsersGeoliveId;
-(long)getUsersGeoliveId:(long)userId;

-(bool)setUsersPassword:(NSString *)password;
-(NSString *)getUsersPassword;
-(NSString *)getUsersPassword:(long)userId;

-(bool)userHasPasscode;
-(bool)userHasPasscode:(long)userId;

-(bool)deleteUser:(long)userId;

@end

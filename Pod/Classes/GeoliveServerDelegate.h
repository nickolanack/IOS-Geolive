
//
//  Created by Nick Blackwell on 2013-07-25.
//
//

#import <Foundation/Foundation.h>



@protocol GeoliveServerDelegate <NSObject>

@optional

-(void)geoliveUserAccountRequiresEmailActivation;
-(void)geoliveUserAccountRequiresEmailVerification;
-(void)geoliveUserAccountRequiresAdministratorActivationWithCode:(NSString *) code;


@end

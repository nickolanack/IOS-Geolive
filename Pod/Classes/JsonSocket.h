
//
//  Created by Nick Blackwell on 2013-05-13.
//
//

#import <Foundation/Foundation.h>
#import "ConnectionListener.h"
#import <UIKit/UIKit.h>

@interface JsonSocket : NSObject

@property  (readonly) NSString *lastResponse;
@property  (readonly) NSString *lastQuery;
@property int timeout;

-(id) initWithServer:(NSString *)url;

- (NSDictionary *) requestJsonTask:(NSString *)task;
- (void) requestJsonTask:(NSString *)task completion: (void (^)(NSDictionary *))result;


- (NSDictionary *) requestJsonTask:(NSString *)task WithParameters:(NSDictionary *) json;
- (void) requestJsonTask:(NSString *)task WithParameters:(NSDictionary *) json completion: (void (^)(NSDictionary *))result;

- (NSString *) requestPlainTextTask:(NSString *)task WithParameters:(NSDictionary *) json;
- (void) requestPlainTextTask:(NSString *)task WithParameters:(NSDictionary *) json completion: (void (^)(NSString *))result;

- (bool) requestServerSession;

+(NSDictionary *) QueryServer:(NSString *)server Task:(NSString *)task WithParameters:(NSDictionary *)json;
+(NSDictionary *) QueryServer:(NSString *)server Task:(NSString *)task;

+(void)QueryServer:(NSString *)server Task:(NSString *)task WithParameters:(NSDictionary *)json Completion:(void (^)(NSDictionary *))result;
+(void)QueryServer:(NSString *)server Task:(NSString *)task Completion:(void (^)(NSDictionary *))result;


-(ConnectionListener *)uploadImage:(UIImage *)image;
-(ConnectionListener *)uploadVideo:(NSURL *)file;
@end


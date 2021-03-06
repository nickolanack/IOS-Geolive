//
//  ConnectionListener.h
//  GeoliveFramework
//
//  Created by Nick Blackwell on 2013-10-09.
//  Copyright (c) 2013 Nick Blackwell. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ConnectionListener : NSObject<NSURLConnectionDelegate>
@property (strong, nonatomic) void (^callback)(NSDictionary * response);
@property (strong, nonatomic) void (^progressHandler)(float percentFinished);
@property (strong, nonatomic) NSURLConnection *connection;

@property NSString *nameForQueue;

-(void)start;
-(void)startWithCompletion:(void (^)(NSDictionary * response)) completion;
-(void)startWithProgressHandler:(void (^)(float percentFinished)) progress andCompletion:(void (^)(NSDictionary * response)) completion;
@end

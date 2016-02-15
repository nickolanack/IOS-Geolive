//
//  ConnectionListener.m
//  GeoliveFramework
//
//  Created by Nick Blackwell on 2013-10-09.
//  Copyright (c) 2013 Nick Blackwell. All rights reserved.
//

#import "ConnectionListener.h"

static NSMutableArray *connections;

@interface ConnectionListener()

@property int sent;

@property bool shouldStart;


@end
@implementation ConnectionListener

@synthesize connection, callback, progressHandler, nameForQueue;

-(instancetype)init{

    self=[super init];
    
    
    if(!connections){
        //keep track of connections otherwise they will likely be deallocated before they are completed
        connections=[[NSMutableArray alloc] init];
    }
    
    [connections addObject:self];
    
    
    return self;


}


-(void)start{
    if(self.connection!=nil){
        
        if(self.nameForQueue==nil){
            self.nameForQueue=[NSString stringWithFormat:@"%@:Url Connection Listener Queue",[self class]];
        }
        
        NSOperationQueue *queue = [[NSOperationQueue alloc] init];
        queue.name = self.nameForQueue;
   
        [connection setDelegateQueue:queue];
        [connection start];
    }else{
        self.shouldStart=true;
    }
}
-(void)setConnection:(NSURLConnection *)con{
    connection=con;
    if(self.shouldStart)[self start];
}
-(void)startWithCompletion:(void (^)(NSDictionary * response)) completion{

    [self setCallback:completion];
    [self start];
}
-(void)startWithProgressHandler:(void (^)(float percentFinished)) progress andCompletion:(void (^)(NSDictionary * response)) completion {
    
    [self setCallback:completion];
    [self setProgressHandler:progress];
    [self start];

}
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    NSLog(@"%@",response);
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    NSString *dataString=[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"%@",dataString);
    
    
    NSError *decodeError=nil;
    NSDictionary *json =[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&decodeError];
    
    if(!decodeError){
        
        if(self.callback!=nil){
            ConnectionListener *c __weak =self;
            dispatch_async(dispatch_get_main_queue(), ^{
                c.callback(json);
                [connections removeObject:self];
            });
            
        }else{
            NSLog(@"%s: Finished without data handler",__PRETTY_FUNCTION__);
        }
        
        
    }else{
        //NSLog(@"%@: Response:  %@", [self class], [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding]);
        // NSLog(@"%@: Error %i %@ %@ for[%@]", [self class], [decodeError code],[decodeError description],[decodeError debugDescription],url );
        
        // @throw [[NSException alloc] initWithName:[NSString stringWithFormat:@"%@: Json Query Exception: %@ - %@",[self class], decodeError.domain, url] reason:decodeError.description userInfo: decodeError.userInfo];
    }
}


- (void)connection:(NSURLConnection *)connection   didSendBodyData:(NSInteger)bytesWritten
 totalBytesWritten:(NSInteger)totalBytesWritten
totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite{
    //NSLog(@"%ld, %ld, %ld", (long)bytesWritten, (long)totalBytesWritten, (long)totalBytesExpectedToWrite);
    int unit=100;
    int s=(int)round(((float)totalBytesWritten/(float)totalBytesExpectedToWrite)*unit);
    if(self.sent!=s){
        self.sent=s;
        if(self.progressHandler!=nil){
            
            ConnectionListener *c __weak =self;
            dispatch_async(dispatch_get_main_queue(), ^{
                c.progressHandler(s/(float)unit);
            });
        }
    }
}



- (void)connectionDidFinishLoading:(NSURLConnection *)connection{
    
}


@end


//
//  Created by Nick Blackwell on 2013-05-13.
//
//

#import "JsonSocket.h"


@interface JsonSocket()

@property NSString *sessionKey;
@property NSString *sessionKeyValue;
@property NSString *server;
@property bool online;
@property NSOperationQueue *q;


@end

@implementation JsonSocket


@synthesize lastQuery, lastResponse, timeout;


-(id) initWithServer:(NSString *)url{
    self=[super init];
    self.timeout=10;
    [self setServerRoot:url];
    self.timeout=60;
    
    return self;

}

-(bool) setServerRoot:(NSString *)url{
    self.server=url;
    self.online=false;
    bool connected=false;
    connected =[self requestServerSession]; //this may throw an exception. if so then self.online remains false.
    self.online=connected;
    return connected;
}

- (bool) requestServerSession{
    
    NSDictionary *json=[self requestJsonTask:@"session_key"];
    if(json){
        
        self.sessionKey=[json valueForKey:@"key"];
        self.sessionKeyValue=[json valueForKey:@"value"];
        
        return true;
    }
    NSLog(@"%s: %@, %@",__PRETTY_FUNCTION__, [self lastQuery], [self lastResponse]);
    return false;
    
}


-(NSOperationQueue *)getQueue{
    
    if(self.q==nil){
        
        self.q= [[NSOperationQueue alloc] init];
        self.q.name = [NSString stringWithFormat:@"%s: Load Asyncronous Json",__PRETTY_FUNCTION__];
        [self.q setMaxConcurrentOperationCount:10];
    }

    return self.q;
    
}

- (NSDictionary *) requestJsonTask:(NSString *)task{
    
    return [self requestJsonTask:task WithParameters:nil];
}
- (NSData *) executeTask:(NSString *)task WithParameters:(NSDictionary *) json{
    
    //NSLog(@"%s: %@ %@ %@",__PRETTY_FUNCTION__,task,json,[json class]);
    NSError *encodeError = nil;
    
    NSString *url=[NSString stringWithFormat:@"%@%@&task=%@", self.server,@"/index.php?option=com_geolive&forcedebug=off&format=ajax",task];
    
    if(self.sessionKey&&self.sessionKeyValue){
        url=[NSString stringWithFormat:@"%@&%@=%@", url, self.sessionKey,self.sessionKeyValue];
        //NSLog(@"SessionKey: %@ SessionKeyValue: %@",self.sessionKey,self.sessionKeyValue);
        
        
        
    }else if(![task isEqualToString:@"session_key"]){
        NSLog(@"Warn: session key not set");
    }
    
    if(json!=nil&&[json count]>0){
        
        NSData *data=[NSJSONSerialization dataWithJSONObject:[NSDictionary dictionaryWithDictionary:json] options:0 error:&encodeError];
        if(encodeError==0){
            if(data!=nil){
                //data=nil;
                NSString *j=[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                j=[self urlencode:j]; 
                if(j!=nil){
                    url=[NSString stringWithFormat:@"%@&json=%@", url, j];
                }else{
                    @throw [[NSException alloc] initWithName:[NSString stringWithFormat:@"%@: Json Convert Exception: Data conversion to string returned nil",[self class]] reason:@"Json data to string returned nil" userInfo: nil];
                }
            }else{
                @throw [[NSException alloc] initWithName:[NSString stringWithFormat:@"%@: Json Encode (%@) Exception: NSJSONSerialization returned nil",[self class], [json class]] reason:@"Json Encoder returned nil" userInfo: nil];
            }
            
        }else{
            @throw [[NSException alloc] initWithName:[NSString stringWithFormat:@"%@: Json Encode (%@) Exception: %@",[self class], [json class], encodeError.domain] reason:encodeError.description userInfo: encodeError.userInfo];
        }
        
        NSLog(@"%s: AJAX:  %@", __PRETTY_FUNCTION__, [[NSString alloc] initWithFormat:@"%@ %@", task, json]);
    }
    lastQuery=[NSString stringWithFormat:@"%@", url];
    //NSLog(@"%@",url);
    //NSLog(@"%@",encodeError);
    
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:timeout];
    // NSMutableURLRequest *request=[[NSMutableURLRequest alloc ] initWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10];
    
    
    [request setHTTPMethod:@"GET"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    
    NSError *queryError=nil;
    NSURLResponse *response=nil;
    
    NSData *responseData=[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&queryError];
    //[request drain]; //I'm worried about memory leaks, since when i profile it is telling me that NSMutableURLRequest is leaking.
    
    // NSLog(@"Response:  %@", [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding]);
   lastResponse=[[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
    
    if(queryError.code==0){
        
        return responseData;
        
    }else{
        //NSLog(@"%@: Error %i %@ %@ for[%@]", [self class], [queryError code],[queryError description],[queryError debugDescription],url);
        @throw [[NSException alloc] initWithName:[NSString stringWithFormat:@"%@: Json Query Exception: %@",[self class], queryError.domain] reason:queryError.description userInfo: queryError.userInfo];
    }
    
    
    
    
    return nil;
}
- (NSDictionary *) requestJsonTask:(NSString *)task WithParameters:(NSDictionary *) json{
    
    NSData *responseData=[self executeTask:task WithParameters:json];
  
        
    NSError *decodeError=nil;
    NSDictionary *response =[NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&decodeError];
    
    if(decodeError.code==0){
        return response;
    }else{
        NSLog(@"%s: Response:  %@", __PRETTY_FUNCTION__, [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding]);
        NSLog(@"%s: Error %li %@ %@ for[%@]", __PRETTY_FUNCTION__, (long)[decodeError code],[decodeError description],[decodeError debugDescription],lastQuery );
        
        // @throw [[NSException alloc] initWithName:[NSString stringWithFormat:@"%@: Json Query Exception: %@ - %@",[self class], decodeError.domain, url] reason:decodeError.description userInfo: decodeError.userInfo];
    }
   
    
    return nil;
}
- (NSString *) requestPlainTextTask:(NSString *)task WithParameters:(NSDictionary *) json{
    NSData *responseData=[self executeTask:task WithParameters:json];
    return [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
}
- (NSString *)urlencode:(NSString *)string {
    NSMutableString *output = [NSMutableString string];
    const unsigned char *source = (const unsigned char *)[string UTF8String];
    long sourceLen = strlen((const char *)source);
    for (int i = 0; i < sourceLen; ++i) {
        const unsigned char thisChar = source[i];
        if (thisChar == ' '){
            [output appendString:@"+"];
        } else if (thisChar == '.' || thisChar == '-' || thisChar == '_' || thisChar == '~' ||
                   (thisChar >= 'a' && thisChar <= 'z') ||
                   (thisChar >= 'A' && thisChar <= 'Z') ||
                   (thisChar >= '0' && thisChar <= '9')) {
            [output appendFormat:@"%c", thisChar];
        } else {
            [output appendFormat:@"%%%02X", thisChar];
        }
    }
    return output;
}
-(void)requestJsonTask:(NSString *)task completion:(void (^)(NSDictionary *))result{

    //[[self getQueue] addOperationWithBlock:^{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSDictionary *i=[self requestJsonTask:task];
        dispatch_async(dispatch_get_main_queue(), ^{
            result(i);
        });
    });
        
    
        
    //}];
    
    
}
-(void)requestJsonTask:(NSString *)task WithParameters:(NSDictionary *)json completion:(void (^)(NSDictionary *))result{
    
    //[[self getQueue]  addOperationWithBlock:^{

    JsonSocket * __weak me=self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSDictionary *i=[me requestJsonTask:task WithParameters:json];
        dispatch_async(dispatch_get_main_queue(), ^{
            result(i);
        });
    });
    //}];
    
    
}


-(void)requestPlainTextTask:(NSString *)task WithParameters:(NSDictionary *)json completion:(void (^)(NSString *))result{
    
    //[[self getQueue]  addOperationWithBlock:^{
    
    JsonSocket * __weak me=self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSString *i=[me requestPlainTextTask:task WithParameters:json];
        dispatch_async(dispatch_get_main_queue(), ^{
            result(i);
        });
    });
    //}];
    
    
}



+(void)QueryServer:(NSString *)server Task:(NSString *)task Completion:(void (^)(NSDictionary *))result{
    [JsonSocket QueryServer:server Task:task WithParameters:nil Completion:result];
}
+(void)QueryServer:(NSString *)server Task:(NSString *)task WithParameters:(NSDictionary *)json Completion:(void (^)(NSDictionary *))result{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSDictionary *i=[JsonSocket QueryServer:server Task:task WithParameters:json];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            result(i);
        });
    });
    
}

+(NSDictionary *) QueryServer:(NSString *)server Task:(NSString *)task{
    return [JsonSocket QueryServer:server Task:task WithParameters:nil];
}

/*
 *  Static method to execute json, must not require session, must not require custom timeout(30). and does not provide lastQuery lastResult
 */
+(NSDictionary *) QueryServer:(NSString *)server Task:(NSString *)task WithParameters:(NSDictionary *)json{
 
    NSError *encodeError = nil;
    NSString *url=[NSString stringWithFormat:@"%@%@&task=%@", server, @"/index.php?option=com_geolive&forcedebug=off&format=ajax",task];
    
    if(json!=nil&&[json count]>0){
        
        NSData *data=[NSJSONSerialization dataWithJSONObject:[NSDictionary dictionaryWithDictionary:json] options:NSJSONWritingPrettyPrinted error:&encodeError];
        if(encodeError==0){
            if(data!=nil){
                //data=nil;
                NSString *j=[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                j=[j stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                if(j!=nil){
                    url=[NSString stringWithFormat:@"%@&json=%@",url,j];
                }else{
                    @throw [[NSException alloc] initWithName:[NSString stringWithFormat:@"%@: Json Convert Exception: Data conversion to string returned nil",[self class]] reason:@"Json data to string returned nil" userInfo: nil];
                }
            }else{
                @throw [[NSException alloc] initWithName:[NSString stringWithFormat:@"%@: Json Encode (%@) Exception: NSJSONSerialization returned nil",[self class], [json class]] reason:@"Json Encoder returned nil" userInfo: nil];
            }
            
        }else{
            @throw [[NSException alloc] initWithName:[NSString stringWithFormat:@"%@: Json Encode (%@) Exception: %@",[self class], [json class], encodeError.domain] reason:encodeError.description userInfo: encodeError.userInfo];
        }
    }
    
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:30];

    [request setHTTPMethod:@"GET"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    
    NSError *queryError=nil;
    NSURLResponse *response=nil;
    
    NSData *responseData=[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&queryError];
    
    if(queryError.code==0){
        
        NSError *decodeError=nil;
        NSDictionary *json =[NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&decodeError];
        
        if(decodeError.code==0){
            return json;
        }else{

        }
        
    }else{
        @throw [[NSException alloc] initWithName:[NSString stringWithFormat:@"%@: Json Query Exception: %@",[self class], queryError.domain] reason:queryError.description userInfo: queryError.userInfo];
    }
    
    return nil;

}

-(ConnectionListener *)uploadImage:(UIImage *)image{
 
 
    ConnectionListener *listener =[[ConnectionListener alloc] init];
    // encode the image as PNG
    NSData *imageData = UIImagePNGRepresentation(image);
    
    // set up the request
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    NSString *url=[NSString stringWithFormat:@"%@%@&task=image_upload", self.server,@"/index.php?option=com_geolive&forcedebug=off&format=ajax"];
    if(self.sessionKey&&self.sessionKeyValue){
        url=[NSString stringWithFormat:@"%@&%@=%@", url, self.sessionKey,self.sessionKeyValue];
        //NSLog(@"SessionKey: %@ SessionKeyValue: %@",self.sessionKey,self.sessionKeyValue);
    }else{
        NSLog(@"Warn: session key not set");
    }
    
    [request setURL:[NSURL URLWithString:url]];
    
    
    
    // create a boundary to delineate the file
    NSString *boundary = [NSString stringWithFormat:@"%f",M_1_PI];
    // tell the server what to expect
    NSString *contentType =
    [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    [request addValue:contentType forHTTPHeaderField: @"Content-Type"];
    
    // make a buffer for the post body
    NSMutableData *body = [NSMutableData data];
    
    // add a boundary to show where the title starts
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", boundary]
                      dataUsingEncoding:NSASCIIStringEncoding]];
    
    // add the title
    [body appendData:[
                      @"Content-Disposition: form-data; name=\"title\"\r\n\r\n"
                      dataUsingEncoding:NSASCIIStringEncoding]];
    [body appendData:[@"image.png"
                      dataUsingEncoding:NSASCIIStringEncoding]];
    
    // add a boundary to show where the file starts
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", boundary]
                      dataUsingEncoding:NSASCIIStringEncoding]];
    
    // add a form field
    [body appendData:[
                      @"Content-Disposition: form-data; name=\"upload\"; filename=\"image.png\"\r\n"
                      dataUsingEncoding:NSASCIIStringEncoding]];
    
    // tell the server to expect some binary
    [body appendData:[
                      @"Content-Type: application/octet-stream\r\n"
                      dataUsingEncoding:NSASCIIStringEncoding]];
    [body appendData:[
                      @"Content-Transfer-Encoding: binary\r\n"
                      dataUsingEncoding:NSASCIIStringEncoding]];
    [body appendData:[[NSString stringWithFormat:
                       @"Content-Length: %lu\r\n\r\n", (unsigned long)imageData.length]
                      dataUsingEncoding:NSASCIIStringEncoding]];
    
    // add the payload
    [body appendData:[NSData dataWithData:imageData]];
    
    // tell the server the payload has ended
    [body appendData:
     [[NSString stringWithFormat:@"\r\n--%@--\r\n", boundary]
      dataUsingEncoding:NSASCIIStringEncoding]];
    
    // add the POST data as the request body
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:body];

    NSURLConnection *urlConnection = [[NSURLConnection alloc ] initWithRequest:request delegate:listener startImmediately:NO];
    [listener setNameForQueue:[NSString stringWithFormat:@"%@:Image Upload Queue",[self class]]];
    [listener setConnection:urlConnection];
    
    
    return listener;
}


-(ConnectionListener *)uploadVideo:(NSURL *)file{
     ConnectionListener *listener=[[ConnectionListener alloc] init];
        NSData *videoData = [NSData dataWithContentsOfURL:file];
        
        
        // encode the image as PNG
        //  NSData *imageData = UIImagePNGRepresentation(image);
        
        // set up the request
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        NSString *url=[NSString stringWithFormat:@"%@%@&task=video_upload", self.server,@"/index.php?option=com_geolive&forcedebug=off&format=ajax"];
        if(self.sessionKey&&self.sessionKeyValue){
            url=[NSString stringWithFormat:@"%@&%@=%@", url, self.sessionKey,self.sessionKeyValue];
            //NSLog(@"SessionKey: %@ SessionKeyValue: %@",self.sessionKey,self.sessionKeyValue);
        }else{
            NSLog(@"Warn: session key not set");
        }
        
        [request setURL:[NSURL URLWithString:url]];
        
        
        
        // create a boundary to delineate the file
        NSString *boundary = [NSString stringWithFormat:@"%f",M_1_PI];
        // tell the server what to expect
        NSString *contentType =
        [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
        [request addValue:contentType forHTTPHeaderField: @"Content-Type"];
        
        // make a buffer for the post body
        NSMutableData *body = [NSMutableData data];
        
        // add a boundary to show where the title starts
        [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", boundary]
                          dataUsingEncoding:NSASCIIStringEncoding]];
        
        // add the title
        [body appendData:[
                          @"Content-Disposition: form-data; name=\"title\"\r\n\r\n"
                          dataUsingEncoding:NSASCIIStringEncoding]];
        [body appendData:[@"video.mov"
                          dataUsingEncoding:NSASCIIStringEncoding]];
        
        // add a boundary to show where the file starts
        [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", boundary]
                          dataUsingEncoding:NSASCIIStringEncoding]];
        
        // add a form field
        [body appendData:[
                          @"Content-Disposition: form-data; name=\"upload\"; filename=\"video.mov\"\r\n"
                          dataUsingEncoding:NSASCIIStringEncoding]];
        
        // tell the server to expect some binary
        [body appendData:[
                          @"Content-Type: application/octet-stream\r\n"
                          dataUsingEncoding:NSASCIIStringEncoding]];
        [body appendData:[
                          @"Content-Transfer-Encoding: binary\r\n"
                          dataUsingEncoding:NSASCIIStringEncoding]];
        [body appendData:[[NSString stringWithFormat:
                           @"Content-Length: %lu\r\n\r\n", (unsigned long)videoData.length]
                          dataUsingEncoding:NSASCIIStringEncoding]];
        
        // add the payload
        [body appendData:[NSData dataWithData:videoData]];
        
        // tell the server the payload has ended
        [body appendData:
         [[NSString stringWithFormat:@"\r\n--%@--\r\n", boundary]
          dataUsingEncoding:NSASCIIStringEncoding]];
        
        // add the POST data as the request body
        [request setHTTPMethod:@"POST"];
        [request setHTTPBody:body];
        
        
        NSURLConnection *urlConnection = [[NSURLConnection alloc ] initWithRequest:request delegate:listener startImmediately:NO];
        [listener setNameForQueue:[NSString stringWithFormat:@"%@:Video Upload Queue",[self class]]];
        [listener setConnection:urlConnection];
 
    
    
    return listener;
}

@end

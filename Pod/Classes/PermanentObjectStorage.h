//
//  ObjectStorage.h
//  Pods
//
//  Created by Nick Blackwell on 2016-01-27.
//
//

@protocol PermanentObjectStorage <NSObject>

@required


-(bool)hasObjectForName:(NSString *)name;
-(id)getObjectForName:(NSString *)name;
-(bool)setObject:(id) object ForName:(NSString *)name;
-(bool)removeObjectForName:(NSString *)name;

@end

//
//  DatabaseStorage.h
//  Pods
//
//  Created by Nick Blackwell on 2016-01-27.
//
//

#import <Foundation/Foundation.h>
#import "PermanentObjectStorage.h"
#import "Database.h"

@interface DatabaseStorage : NSObject<PermanentObjectStorage>

-(instancetype)initWithDatabase:(Database *)d AndTable:(NSString *) table;

@end

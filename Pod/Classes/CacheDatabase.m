//
//  Created by Nick Blackwell on 2013-07-21.
//
//

#import "CacheDatabase.h"

@implementation CacheDatabase

-(id) initWithName:(NSString *) name{
    
    self=[super init];
    if(self){
        self.tableDefinitions=[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:
                                                                   
                                                                   @"CREATE TABLE IF NOT EXISTS variable(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, data TEXT, modified TIMESTAMP DEFAULT CURRENT_TIMESTAMP);",
                                                                   nil]
                                                          forKeys:[NSArray arrayWithObjects:
                                                                   @"variable",
                                                                   nil]];
        [self open:name];
        [self checkTables];
    }
    return self;
}

@end

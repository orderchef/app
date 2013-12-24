//
//  Staff.m
//  iOrder
//
//  Created by Matej Kramny on 09/12/2013.
//  Copyright (c) 2013 Matej Kramny. All rights reserved.
//

#import "Employee.h"
#import "Connection.h"

@implementation Employee

@synthesize code, _id, name, manager;

- (id)init {
    self = [super init];
    
    if (self) {
        name = @"";
        _id = @"";
        code = @"";
        manager = false;
    }
    
    return self;
}

- (void)loadFromJSON:(NSDictionary *)json {
    [self set_id:[json objectForKey:@"_id"]];
    [self setName:[json objectForKey:@"name"]];
    [self setCode:[json objectForKey:@"code"]];
    [self setManager:[[json objectForKey:@"manager"] boolValue]];
}

- (void)save {
    Connection *c = [Connection getConnection];
    SocketIO *socket = [c socket];
    
    @try {
        [socket sendEvent:@"save.employee" withData:@{
                                                     @"name": name,
                                                     @"code": code,
                                                     @"_id": _id,
                                                     @"manager": [NSNumber numberWithBool:manager]
                                                     }
         ];
    } @catch (NSException *e) {}
}

- (void)remove {
	if (!_id) {
		return;
	}
	
	[[[Connection getConnection] socket] sendEvent:@"remove.employee" withData:@{@"_id": _id}];
}

@end

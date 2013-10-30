//
//  ItemCategory.m
//  iOrder
//
//  Created by Matej Kramny on 30/10/2013.
//  Copyright (c) 2013 Matej Kramny. All rights reserved.
//

#import "ItemCategory.h"
#import "Item.h"
#import "Connection.h"

@implementation ItemCategory

@synthesize name;

- (id)init {
    self = [super init];
    
    if (self) {
        name = @"";
    }
    
    return self;
}

- (void)loadFromJSON:(NSDictionary *)json {
    [self set_id:[json objectForKey:@"_id"]];
    [self setName:[json objectForKey:@"name"]];
}

- (void)save {
    Connection *c = [Connection getConnection];
    SocketIO *socket = [c socket];
    [socket sendEvent:@"create.category" withData:@{@"name": name}];
}

@end

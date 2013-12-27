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
@synthesize _id;
@synthesize printers;

- (id)init {
    self = [super init];
    
    if (self) {
		_id = @"";
        name = @"";
		printers = [NSArray array];
    }
    
    return self;
}

- (void)loadFromJSON:(NSDictionary *)json {
    [self set_id:[json objectForKey:@"_id"]];
    [self setName:[json objectForKey:@"name"]];
	[self setPrinters:[json objectForKey:@"printers"]];
}

- (void)save {
    Connection *c = [Connection getConnection];
    SocketIO *socket = [c socket];
    [socket sendEvent:@"save.category" withData:@{
													@"name": name,
													@"_id": _id,
													@"printers": printers
													}];
}

- (void)deleteCategory {
	[[Connection getConnection].socket sendEvent:@"remove.category" withData:@{
																			  @"_id": _id
																			  }];
}

@end

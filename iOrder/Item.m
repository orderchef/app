//
//  Item.m
//  iOrder
//
//  Created by Matej Kramny on 30/10/2013.
//  Copyright (c) 2013 Matej Kramny. All rights reserved.
//

#import "Item.h"
#import "ItemCategory.h"
#import "Table.h"
#import "Connection.h"

@implementation Item

@synthesize _id;
@synthesize name;
@synthesize price;
@synthesize category;
@synthesize table;

- (id)init {
    self = [super init];
    
    if (self) {
		_id = @"";
        name = @"";
        price = [NSNumber numberWithFloat:0.f];
        category = nil;
        table = nil;
    }
    
    return self;
}

- (void)loadFromJSON:(NSDictionary *)json {
    [self set_id:[json objectForKey:@"_id"]];
    [self setName:[json objectForKey:@"name"]];
    [self setPrice:[json objectForKey:@"price"]];
    
    NSString *catId = [json objectForKey:@"category"];
    category = [[Storage getStorage] findCategoryById:catId];
}

- (void)save {
    Connection *c = [Connection getConnection];
    SocketIO *socket = [c socket];
    [socket sendEvent:@"create.item" withData:@{
												@"_id": _id,
												@"name": name,
												@"price": price,
												@"category": category._id
												}];
}

- (void)saveCategory:(ItemCategory *)theCategory {
    [[[Connection getConnection] socket] sendEvent:@"set.item category" withData:@{@"item": _id, @"category": theCategory._id }];
}

- (void)deleteItem {
	[[[Connection getConnection] socket] sendEvent:@"delete.item" withData:@{@"_id": _id }];
}

@end

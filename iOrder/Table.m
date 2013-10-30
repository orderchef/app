//
//  Table.m
//  iOrder
//
//  Created by Matej Kramny on 30/10/2013.
//  Copyright (c) 2013 Matej Kramny. All rights reserved.
//

#import "Table.h"
#import "Item.h"
#import "Connection.h"

@implementation Table

@synthesize _id;
@synthesize name;
@synthesize items;

- (id)init {
    self = [super init];
    
    if (self) {
        name = @"";
    }
    
    return self;
}

- (void)save {
    Connection *c = [Connection getConnection];
    SocketIO *socket = [c socket];
    [socket sendEvent:@"create.table" withData:@{@"name": name}];
}

- (void)loadFromJSON:(NSDictionary *)json {
    [self set_id:[json objectForKey:@"_id"]];
    [self setName:[json objectForKey:@"name"]];
}

- (void)loadItems {
    [[[Connection getConnection] socket] sendEvent:@"get.items table" withData:@{ @"table": _id }];
}

- (void)loadItems:(NSArray *)items {
    NSMutableArray *its = [[NSMutableArray alloc] init];
    for (NSDictionary *item in items) {
        Item *it = [[Item alloc] init];
        [it loadFromJSON:[item objectForKey:@"item"]];
        
        NSDictionary *itDict = @{@"item": it, @"quantity": [item objectForKey:@"quantity"]};
        [its addObject:itDict];
    }
    
    [self setItems:its];
}

- (void)addItem:(Item *)item {
    [[[Connection getConnection] socket] sendEvent:@"add.table item" withData:@{@"table": _id, @"item": item._id}];
}

@end

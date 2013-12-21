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
@synthesize items = _items;
@synthesize notes;
@synthesize delivery;
@synthesize takeaway;

- (id)init {
    self = [super init];
    
    if (self) {
        name = @"";
        notes = @"";
        _items = [NSArray array];
        _id = @"";
		
		delivery = false;
		takeaway = false;
    }
    
    return self;
}

- (void)save {
    Connection *c = [Connection getConnection];
    SocketIO *socket = [c socket];
    
    NSString *__id = _id;
    if (!__id) {
        __id = @"";
    }
	
	NSMutableArray *its = [[NSMutableArray alloc] initWithCapacity:[_items count]];
    for (NSDictionary *item in _items) {
		[its addObject:@{
						 @"_id": [item objectForKey:@"_id"],
						 @"quantity": [item objectForKey:@"quantity"],
						 @"notes": [item objectForKey:@"notes"]
						 }];
	}
	
    [socket sendEvent:@"create.table" withData:@{
                                                 @"_id": __id,
                                                 @"name": name,
                                                 @"notes": notes,
												 @"items": its,
												 @"delivery": [NSNumber numberWithBool:delivery],
												 @"takeaway": [NSNumber numberWithBool:takeaway]
                                                 }];
}

- (void)loadFromJSON:(NSDictionary *)json {
    [self set_id:[json objectForKey:@"_id"]];
    [self setName:[json objectForKey:@"name"]];
    [self setNotes:[json objectForKey:@"notes"]];
	[self setDelivery:[[json objectForKey:@"delivery"] boolValue]];
    [self setTakeaway:[[json objectForKey:@"takeaway"] boolValue]];
	
	if (notes == nil) {
		notes = @"";
	}
}

- (void)loadItems {
    [[[Connection getConnection] socket] sendEvent:@"get.items table" withData:@{ @"table": _id }];
}

- (void)loadItems:(NSArray *)items {
    NSMutableArray *its = [[NSMutableArray alloc] init];
    for (NSDictionary *item in items) {
        Item *it = [[Item alloc] init];
        [it loadFromJSON:[item objectForKey:@"item"]];
        
        NSDictionary *itDict = @{
								 @"item": it,
								 @"quantity": [item objectForKey:@"quantity"],
								 @"notes": [item objectForKey:@"notes"],
								 @"_id": [item objectForKey:@"_id"]
								};
        [its addObject:itDict];
    }
	
	[self setItems:[its sortedArrayUsingComparator:^NSComparisonResult(NSDictionary *a, NSDictionary *b) {
		Item *_a = (Item *)[a objectForKey:@"item"];
		Item *_b = (Item *)[b objectForKey:@"item"];
		
		return [_a.name compare:_b.name];
	}]];
}

- (void)clearTable {
    [[[Connection getConnection] socket] sendEvent:@"remove.table items" withData:@{@"table": _id}];
}

- (void)sendToKitchen {
    [[[Connection getConnection] socket] sendEvent:@"table.send kitchen" withData:@{@"table": _id}];
}

- (void)addItem:(Item *)item {
    [[[Connection getConnection] socket] sendEvent:@"add.table item" withData:@{@"table": _id, @"item": item._id}];
    [self loadItems];
}

- (void)removeItem:(Item *)item {
	[[[Connection getConnection] socket] sendEvent:@"remove.table item" withData:@{@"table": _id, @"item": item._id}];
	[self loadItems];
}

- (void)deleteTable {
	[[[Connection getConnection] socket] sendEvent:@"remove.table" withData:@{@"table": _id}];
}

@end

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
#import "OrderGroup.h"

@implementation Table

@synthesize _id;
@synthesize name;
@synthesize delivery;
@synthesize takeaway;
@synthesize group;
@synthesize orders, customerName;

- (id)init {
    self = [super init];
    
    if (self) {
        name = @"";
        _id = @"";
		
		delivery = false;
		takeaway = false;
		
		orders = 0;
		customerName = @"";
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
	
	[socket sendEvent:@"save.table" withData:@{
                                                 @"_id": __id,
                                                 @"name": name,
												 @"delivery": [NSNumber numberWithBool:delivery],
												 @"takeaway": [NSNumber numberWithBool:takeaway]
                                                 }];
}

- (void)loadFromJSON:(NSDictionary *)json {
    [self set_id:[json objectForKey:@"_id"]];
    [self setName:[json objectForKey:@"name"]];
	[self setDelivery:[[json objectForKey:@"delivery"] boolValue]];
    [self setTakeaway:[[json objectForKey:@"takeaway"] boolValue]];
	[self setOrders:[[json objectForKey:@"orders"] intValue]];
	[self setCustomerName:[json objectForKey:@"customerName"]];
	
	NSLog(@"%d, %@", orders, customerName);
	
	if (!orders) {
		orders = 0;
	}
	if (!customerName) {
		customerName = @"";
	}
}

- (void)loadItems {
    [[[Connection getConnection] socket] sendEvent:@"get.group active" withData:@{
																				  @"table": _id
																				  }];
}

- (void)sendToKitchen {
    [[[Connection getConnection] socket] sendEvent:@"table.send kitchen" withData:@{@"table": _id}];
}

- (void)deleteTable {
	[[[Connection getConnection] socket] sendEvent:@"remove.table" withData:@{@"table": _id}];
}

@end

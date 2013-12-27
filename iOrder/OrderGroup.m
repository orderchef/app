//
//  OrderGroup.m
//  iOrder
//
//  Created by Matej Kramny on 24/12/2013.
//  Copyright (c) 2013 Matej Kramny. All rights reserved.
//

#import "OrderGroup.h"
#import "Storage.h"
#import "Table.h"
#import "Order.h"
#import "Connection.h"

@implementation OrderGroup

@synthesize _id, created, cleared, clearedAt, orders;
@synthesize table;

- (id)init {
	self = [super init];
	
	if (self) {
		_id = @"";
		created = [NSDate date];
		table = nil;
		cleared = false;
		clearedAt = [NSDate date];
		orders = [NSArray array];
	}
	
	return self;
}

- (void)loadFromJSON:(NSDictionary *)json {
	NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
	[dateFormat setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_UK_POSIX"]];
	[dateFormat setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
	
	_id = [json objectForKey:@"_id"];
	created = [dateFormat dateFromString:[json objectForKey:@"created"]];
	cleared = [[json objectForKey:@"cleared"] boolValue];
	clearedAt = [dateFormat dateFromString:[json objectForKey:@"clearedAt"]];
	
	NSMutableArray *_orders = [[NSMutableArray alloc] init];
	for (NSDictionary *o in [json objectForKey:@"orders"]) {
		NSString *oid = [o objectForKey:@"_id"];
		Order *order;
		for (Order *_order in orders) {
			if ([_order._id isEqualToString:oid]) {
				order = _order;
				break;
			}
		}
		
		if (!order) {
			order = [[Order alloc] init];
		}
		
		order.group = self;
		[order loadFromJSON:o];
		
		[_orders addObject:order];
	}
	orders = [_orders copy];
	
	NSArray *tables = [Storage getStorage].tables;
	NSString *tid = [json objectForKey:@"table"];
	for (Table *t in tables) {
		if ([tid isEqualToString:t._id]) {
			table = t;
			break;
		}
	}
}

- (void)getOrders {
	[[[Connection getConnection] socket] sendEvent:@"get.group active" withData:@{@"_id": _id}];
}

- (void)save {
	NSString *tid = @"";
	if (self.table) {
		tid = table._id;
	}
	
	NSMutableArray *orderIds = [[NSMutableArray alloc] init];
	for (Order *o in orders) {
		[orderIds addObject:o._id];
	}
	
	[[[Connection getConnection] socket] sendEvent:@"save.group" withData:@{
																			@"_id": _id,
																			@"created": [NSNumber numberWithInt:[created timeIntervalSince1970]],
																			@"cleared": [NSNumber numberWithBool:cleared],
																			@"clearedAt": [NSNumber numberWithInt:[clearedAt timeIntervalSince1970]],
																			@"table": tid,
																			@"orders": orderIds
																			}];
}

@end

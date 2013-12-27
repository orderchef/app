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
	_id = [json objectForKey:@"_id"];
	created = [NSDate dateWithTimeIntervalSince1970:[[json objectForKey:@"created"] intValue]];
	cleared = [[json objectForKey:@"cleared"] boolValue];
	clearedAt = [NSDate dateWithTimeIntervalSince1970:[[json objectForKey:@"clearedAt"] intValue]];
	
	NSMutableArray *_orders = [[NSMutableArray alloc] init];
	for (NSDictionary *o in [json objectForKey:@"orders"]) {
		Order *order = [[Order alloc] init];
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

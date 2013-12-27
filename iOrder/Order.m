//
//  OrderGroup.m
//  iOrder
//
//  Created by Matej Kramny on 24/12/2013.
//  Copyright (c) 2013 Matej Kramny. All rights reserved.
//

#import "Order.h"
#import "Storage.h"
#import "Item.h"
#import "Connection.h"
#import "OrderGroup.h"
#import "Table.h"
#import "Employee.h"

@implementation Order

@synthesize _id, items,	printedAt, printed, notes, created;
@synthesize group;

- (id)init {
	self = [super init];
	
	if (self) {
		_id = @"";
		items = [NSArray array];
		printed = false;
		printedAt = [NSDate date];
		notes = @"";
		created = [[NSDate alloc] init];
	}
	
	return self;
}

- (void)loadFromJSON:(NSDictionary *)json {
	NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
	[dateFormat setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_UK_POSIX"]];
	[dateFormat setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
	
	_id = [json objectForKey:@"_id"];
	printed = [[json objectForKey:@"printed"] boolValue];
	printedAt = [dateFormat dateFromString:[json objectForKey:@"printedAt"]];
	created = [dateFormat dateFromString:[json objectForKey:@"created"]];
	notes = [json objectForKey:@"notes"];
	
	NSMutableArray *_items = [[NSMutableArray alloc] init];
	for (NSDictionary *it in [json objectForKey:@"items"]) {
		
		Item *i = nil;
		NSString *it_id = [it objectForKey:@"item"];
		for (Item *item in [Storage getStorage].items) {
			if ([item._id isEqualToString:it_id]) {
				i = item;
				break;
			}
		}
		
		if (!i) {
			i = (Item *)[NSNull null];
		}
		
		NSMutableDictionary *md = [[NSMutableDictionary alloc] initWithDictionary:it];
		[md setObject:i forKey:@"item"];
		
		[_items addObject:md];
	}
	[self setItems:_items];
}

- (void)save {
	NSMutableArray *_items = [[NSMutableArray alloc] init];
	for (NSDictionary *item in items) {
		[_items addObject:@{
						   @"item": [(Item *)[item objectForKey:@"item"] _id],
						   @"quantity": [item objectForKey:@"quantity"],
						   @"notes": [item objectForKey:@"notes"]
						   }];
	}
	
	[[Connection getConnection].socket sendEvent:@"save.order" withData:@{
																		 @"_id": _id,
																		 @"printed": [NSNumber numberWithBool:printed],
																		 @"printedAt": [NSNumber numberWithInt:[printedAt timeIntervalSince1970]],
																		 @"created": [NSNumber numberWithInt:[created timeIntervalSince1970]],
																		 @"notes": notes,
																		 @"items": _items
																		 } andAcknowledge:^(NSString *data) {
																			 _id = data;
																			 [group save];
																		 }];
}

- (void)addItem:(Item *)item {
	[[Connection getConnection].socket sendEvent:@"add.order item" withData:@{
																			  @"order": _id,
																			  @"item": item._id
																			  }];
}

- (void)print {
	printed = true;
	printedAt = [[NSDate alloc] init];
	[[Connection getConnection].socket sendEvent:@"print.order" withData:@{
																		   @"order": _id,
																		   @"table": group.table.name,
																		   @"employee": [Storage getStorage].employee.name
																		   }];
}

@end

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

@synthesize _id, items,	printedAt, printed, notes, created, postcode, postcodeDistance;
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
		postcode = @"";
		postcodeDistance = @"";
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
	postcode = [json objectForKey:@"postcode"];
	postcodeDistance = [json objectForKey:@"postcodeDistance"];
	
	if (postcode == nil) postcode = @"";
	if (postcodeDistance == nil) postcodeDistance = @"";
	
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
			// NULL items must not be present
			[[Connection getConnection].socket sendEvent:@"remove.order item" withData:@{
																						 @"order": _id,
																						 @"item": it_id
																						 }];
			continue;
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
	
	NSDictionary *data = @{
						   @"_id": _id,
						   @"printed": [NSNumber numberWithBool:printed],
						   @"printedAt": [NSNumber numberWithInt:[printedAt timeIntervalSince1970]],
						   @"created": [NSNumber numberWithInt:[created timeIntervalSince1970]],
						   @"notes": notes,
						   @"items": _items,
						   @"postcode": postcode,
						   @"postcodeDistance": postcodeDistance
						   };
	
	[[Connection getConnection].socket sendEvent:@"save.order" withData:data andAcknowledge:^(NSString *data) {
																			 _id = data;
																			 [group save];
																		 }];
}

- (void)addItem:(Item *)item {
	[[Connection getConnection].socket sendEvent:@"add.order item" withData:@{
																			  @"order": _id,
																			  @"item": item._id,
																			  @"tableid": self.group.table._id
																			  }];
	
	int found = -1;
	for (int i = 0; i < items.count; i++) {
		NSDictionary *it = [items objectAtIndex:i];
		Item *_i = [it objectForKey:@"item"];
		if ([_i._id isEqualToString:item._id]) {
			found = i;
			break;
		}
	}
	
	if (found != -1) {
		NSMutableDictionary *it = [items objectAtIndex:found];
		NSNumber *quantity = [it objectForKey:@"quantity"];
		quantity = [NSNumber numberWithInt:[quantity intValue] + 1];
		[it setObject:quantity forKey:@"quantity"];
	} else {
		NSMutableDictionary *it = [[NSMutableDictionary alloc] init];
		[it setObject:[NSNumber numberWithInt:1] forKey:@"quantity"];
		[it setObject:item forKey:@"item"];
		[it setObject:@"" forKey:@"notes"];
		
		NSMutableArray *_items = [items mutableCopy];
		[_items addObject:it];
		items = [_items copy];
	}
}

- (void)print {
	printed = true;
	printedAt = [[NSDate alloc] init];
	[[Connection getConnection].socket sendEvent:@"print.order" withData:@{
																		   @"order": _id,
																		   @"table": group.table.name,
																		   @"tableid": group.table._id,
																		   @"employee": [Storage getStorage].employee.name
																		   }];
}

- (void)remove {
	[[Connection getConnection].socket sendEvent:@"remove.order" withData:@{
																			  @"order": _id,
																			  @"group": group._id
																			  }];
}

- (void)removeItem:(Item *)item {
	[[Connection getConnection].socket sendEvent:@"remove.order item" withData:@{
																			  @"order": _id,
																			  @"item": item._id
																			  }];
	
	int found = -1;
	for (int i = 0; i < items.count; i++) {
		NSDictionary *it = [items objectAtIndex:i];
		Item *_i = [it objectForKey:@"item"];
		if ([_i._id isEqualToString:item._id]) {
			found = i;
			break;
		}
	}
	
	if (found == -1) return;
	
	NSMutableArray *_items = [items mutableCopy];
	[_items removeObjectAtIndex:found];
	items = _items;
}

@end

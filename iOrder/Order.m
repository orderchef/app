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
						   @"notes": [item objectForKey:@"notes"],
						   @"price": [item objectForKey:@"price"]
						   }];
	}
	
	NSString *_notes = notes;
	if (!_notes) {
		_notes = @"";
	}
	
	NSDictionary *data = @{
						   @"_id": _id,
						   @"printed": [NSNumber numberWithBool:printed],
						   @"printedAt": [NSNumber numberWithInt:[printedAt timeIntervalSince1970]],
						   @"created": [NSNumber numberWithInt:[created timeIntervalSince1970]],
						   @"notes": _notes,
						   @"items": _items
						   };
	
	[[Connection getConnection].socket sendEvent:@"save.order" withData:data andAcknowledge:^(NSString *data) {
																			 _id = data;
																			 [group save];
																		 }];
}

- (void)addItem:(Item *)item andAcknowledge:(void (^)(id))acknowledge {
	[[Connection getConnection].socket sendEvent:@"add.order item" withData:@{
																			  @"order": _id,
																			  @"item": item._id
																			  } andAcknowledge:acknowledge];
	
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
		[it setObject:item.price forKey:@"price"];
		
		NSMutableArray *_items = [items mutableCopy];
		[_items addObject:it];
		items = [_items copy];
	}
}

- (void)print {
	printed = true;
	printedAt = [[NSDate alloc] init];
	NSString *employeeName = [Storage getStorage].employee.name;
	if (!employeeName) {
		employeeName = @"";
	}
	
	[[Connection getConnection].socket sendEvent:@"print.order" withData:@{
																		   @"order": _id,
																		   @"employee": employeeName
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

//
//  Report.m
//  iOrder
//
//  Created by Matej Kramny on 15/12/2013.
//  Copyright (c) 2013 Matej Kramny. All rights reserved.
//

#import "Report.h"
#import "Connection.h"

@implementation Report

@synthesize _id, name, created, delivery, items, notes, quantity, takeaway, total;

- (id)init {
    self = [super init];
    
    if (self) {
        _id = @"";
		name = @"";
		created = [NSDate date];
		delivery = false;
		takeaway = false;
		items = [NSArray array];
		notes = @"";
		quantity = 0;
		total = 0.f;
    }
    
    return self;
}

- (void)loadFromJSON:(NSDictionary *)json {
	NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
	[dateFormat setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_UK_POSIX"]];
	[dateFormat setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
	
    [self set_id:[json objectForKey:@"_id"]];
	[self setCreated:[dateFormat dateFromString:[json objectForKey:@"created"]]];
    [self setItems:[json objectForKey:@"items"]];
	[self setTotal:[[json objectForKey:@"total"] floatValue]];
	[self setQuantity:[[json objectForKey:@"quantity"] intValue]];
	[self setName:[json objectForKey:@"name"]];
	[self setDelivery:[[json objectForKey:@"delivery"] boolValue]];
	[self setTakeaway:[[json objectForKey:@"takeaway"] boolValue]];
	[self setNotes:[json objectForKey:@"notes"]];
}

- (void)save {}

- (void)print {
	if (!_id) {
		return;
	}
	
	[[[Connection getConnection] socket] sendEvent:@"print.report" withData:@{@"_id": _id}];
}

@end

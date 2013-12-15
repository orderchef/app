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

@synthesize _id, created, tables, total, quantity;

- (id)init {
    self = [super init];
    
    if (self) {
        _id = @"";
        tables = [[NSArray alloc] init];
		total = 0.f;
		quantity = 0;
    }
    
    return self;
}

- (void)loadFromJSON:(NSDictionary *)json {
    [self set_id:[json objectForKey:@"_id"]];
	[self setCreated:[[NSDate alloc] initWithTimeIntervalSince1970:[[json objectForKey:@"created"] intValue]]];
    [self setTables:[json objectForKey:@"tables"]];
	[self setTotal:[[json objectForKey:@"total"] floatValue]];
	[self setQuantity:[[json objectForKey:@"quantity"] intValue]];
}

- (void)save {}

- (void)print {
	if (!_id) {
		return;
	}
	
	[[[Connection getConnection] socket] sendEvent:@"print.report" withData:@{@"_id": _id}];
}

@end

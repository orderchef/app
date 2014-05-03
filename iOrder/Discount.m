//
//  Staff.m
//  iOrder
//
//  Created by Matej Kramny on 09/12/2013.
//  Copyright (c) 2013 Matej Kramny. All rights reserved.
//

#import "Discount.h"
#import "Connection.h"
#import <Bugsnag/Bugsnag.h>

@implementation Discount

@synthesize _id, name, allCategories, categories, discountPercent, value;

- (id)init {
    self = [super init];
    
    if (self) {
		name = @"";
		_id = @"";
		allCategories = false;
		categories = [NSArray array];
		discountPercent = false;
		value = 0.0;
    }
    
    return self;
}

- (void)loadFromJSON:(NSDictionary *)json {
    [self set_id:[json objectForKey:@"_id"]];
    [self setName:[json objectForKey:@"name"]];
	[self setAllCategories:[[json objectForKey:@"allCategories"] boolValue]];
	[self setCategories:[json objectForKey:@"categories"]];
	[self setDiscountPercent:[[json objectForKey:@"discountPercent"] boolValue]];
	[self setValue:[[json objectForKey:@"value"] floatValue]];
}

- (void)save {
    Connection *c = [Connection getConnection];
    SocketIO *socket = [c socket];
    
    @try {
        [socket sendEvent:@"save.discount" withData:@{
													  @"_id": _id,
													  @"name": name,
													  @"allCategories": [NSNumber numberWithBool:allCategories],
													  @"categories": categories,
													  @"discountPercent": [NSNumber numberWithBool:discountPercent],
													  @"value": [NSNumber numberWithFloat:value]
													  }];
    } @catch (NSException *e) {
		[Bugsnag notify:e];
	}
}

- (void)remove {
	if (!_id) {
		return;
	}
	
	[[[Connection getConnection] socket] sendEvent:@"remove.discount" withData:@{@"_id": _id}];
}

@end

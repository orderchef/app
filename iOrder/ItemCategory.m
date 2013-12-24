//
//  ItemCategory.m
//  iOrder
//
//  Created by Matej Kramny on 30/10/2013.
//  Copyright (c) 2013 Matej Kramny. All rights reserved.
//

#import "ItemCategory.h"
#import "Item.h"
#import "Connection.h"

@implementation ItemCategory

@synthesize name;
@synthesize _id;
@synthesize drink, sushi, hotFood;

- (id)init {
    self = [super init];
    
    if (self) {
		_id = @"";
        name = @"";
		drink = false;
		sushi = false;
		hotFood = false;
    }
    
    return self;
}

- (void)loadFromJSON:(NSDictionary *)json {
    [self set_id:[json objectForKey:@"_id"]];
    [self setName:[json objectForKey:@"name"]];
	[self setDrink:[[json objectForKey:@"drink"] boolValue]];
	[self setHotFood:[[json objectForKey:@"hotFood"] boolValue]];
	[self setSushi:[[json objectForKey:@"sushi"] boolValue]];
}

- (void)save {
    Connection *c = [Connection getConnection];
    SocketIO *socket = [c socket];
    [socket sendEvent:@"save.category" withData:@{
													@"name": name,
													@"_id": _id,
													@"sushi": [NSNumber numberWithBool:sushi],
													@"drink": [NSNumber numberWithBool:drink],
													@"hotFood": [NSNumber numberWithBool:hotFood]
													}];
}

- (void)deleteCategory {
	[[Connection getConnection].socket sendEvent:@"remove.category" withData:@{
																			  @"_id": _id
																			  }];
}

@end

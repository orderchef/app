//
//  Item.m
//  iOrder
//
//  Created by Matej Kramny on 30/10/2013.
//  Copyright (c) 2013 Matej Kramny. All rights reserved.
//

#import "Item.h"
#import "ItemCategory.h"
#import "Table.h"

@implementation Item

@synthesize name;
@synthesize price;
@synthesize quantity;
@synthesize category;
@synthesize table;

- (id)init {
    self = [super init];
    
    if (self) {
        name = @"";
        price = 0;
        quantity = 0;
        category = nil;
        table = nil;
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    
    if (self) {
        name = [aDecoder decodeObjectForKey:@"name"];
        price = [aDecoder decodeObjectForKey:@"price"];
        quantity = [aDecoder decodeObjectForKey:@"quantity"];
        category = [aDecoder decodeObjectForKey:@"category"];
        table = [aDecoder decodeObjectForKey:@"table"];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:name forKey:@"name"];
    [aCoder encodeObject:price forKey:@"price"];
    [aCoder encodeObject:quantity forKey:@"quantity"];
    [aCoder encodeObject:category forKey:@"category"];
    [aCoder encodeObject:table forKey:@"table"];
}

@end

//
//  ItemCategory.m
//  iOrder
//
//  Created by Matej Kramny on 30/10/2013.
//  Copyright (c) 2013 Matej Kramny. All rights reserved.
//

#import "ItemCategory.h"
#import "Item.h"


@implementation ItemCategory

@synthesize name;
@synthesize items;

- (id)init {
    self = [super init];
    
    if (self) {
        name = @"";
        items = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    
    if (self) {
        name = [aDecoder decodeObjectForKey:@"name"];
        items = [aDecoder decodeObjectForKey:@"items"];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:name forKey:@"name"];
    [aCoder encodeObject:items forKey:@"items"];
}

@end

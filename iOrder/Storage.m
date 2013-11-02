//
//  Settings.m
//  iOrder
//
//  Created by Matej Kramny on 30/10/2013.
//  Copyright (c) 2013 Matej Kramny. All rights reserved.
//

#import "Storage.h"
#import "Connection.h"
#import <socket.IO/SocketIOPacket.h>
#import "Table.h"
#import "Item.h"
#import "ItemCategory.h"

@implementation Storage {
	NSString *documentsDirectory;
}

@synthesize tables, items, categories;

static NSString *tablesPath = @"Tables.plist";
static NSString *itemsPath = @"Items.plist";
static NSString *categoriesPath = @"Categories.plist";

+ (Storage *)getStorage {
    static Storage *storage;
    
    @synchronized(self) {
        if (!storage)
            storage = [[Storage alloc] init];
        
        return storage;
    }
}

- (id)init {
	self = [super init];
	
	if (self)
	{
		// Get the paths
		NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
		documentsDirectory = [paths objectAtIndex:0];
		
		[self loadData];
	}
	
	return self;
}

- (NSMutableArray *)loopAndLoad:(NSArray *)args object:(Class)target {
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    
    if ([args count] == 0) {
        return arr;
    }
    
    for (NSDictionary *x in [args objectAtIndex:0]) {
        id<NetworkLoadingProtocol> obj = [[target alloc] init];
        [obj loadFromJSON:x];
        
        [arr addObject:obj];
    }
    
    return arr;
}

- (void)forwardToTable:(NSArray *)args {
    NSDictionary *obj = [args objectAtIndex:0];
    NSString *_id = [obj objectForKey:@"table"];
    
    for (Table *table in tables) {
        if ([[table _id] isEqualToString:_id]) {
            [table loadItems:[obj objectForKey:@"items"]];
            break;
        }
    }
}

- (void)parseEvent:(SocketIOPacket *)packet {
    NSString *name = [packet name];
    if ([name isEqualToString:@"get.tables"]) {
        [self setTables:[self loopAndLoad:[packet args] object:[Table class]]];
    } else if ([name isEqualToString:@"get.categories"]) {
        [self setCategories:[self loopAndLoad:[packet args] object:[ItemCategory class]]];
    } else if ([name isEqualToString:@"get.items"]) {
        [self setItems:[self loopAndLoad:[packet args] object:[Item class]]];
    }
    
    // for specific table
    else if ([name isEqualToString:@"get.items table"]) {
        [self forwardToTable:[packet args]];
    }
}

- (void)loadData {
    SocketIO *socket = [[Connection getConnection] socket];
    
    [socket sendEvent:@"get.tables" withData:nil];
    [socket sendEvent:@"get.categories" withData:nil];
    [socket sendEvent:@"get.items" withData:nil];
}

@end

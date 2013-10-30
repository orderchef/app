//
//  Settings.m
//  iOrder
//
//  Created by Matej Kramny on 30/10/2013.
//  Copyright (c) 2013 Matej Kramny. All rights reserved.
//

#import "Storage.h"

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

#pragma mark - Data Saving

- (void)saveObject:(id)dataObject to:(NSString *)savePath {
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:dataObject];
    
    @try {
		// Write the data
		NSError *error = nil;
		[data writeToFile:savePath options:NSDataWritingAtomic error:&error];
	} @catch (id exception) {
		NSLog(@"Crashed while saving data %@", [(NSException *)exception description]);
	}
}

- (id)loadObject:(NSString *)savePath {
    NSData *objectData = [NSData dataWithContentsOfFile:savePath];
	
	id object = [NSKeyedUnarchiver unarchiveObjectWithData:objectData];
	
	return object;
}

- (void)saveData {
	// Data
    [self saveObject:tables to:[documentsDirectory stringByAppendingPathComponent:tablesPath]];
    [self saveObject:items to:[documentsDirectory stringByAppendingPathComponent:itemsPath]];
    [self saveObject:categories to:[documentsDirectory stringByAppendingPathComponent:categoriesPath]];
}

- (void)loadData {
    tables = [self loadObject:[documentsDirectory stringByAppendingPathComponent:tablesPath]];
    items = [self loadObject:[documentsDirectory stringByAppendingPathComponent:itemsPath]];
    categories = [self loadObject:[documentsDirectory stringByAppendingPathComponent:categoriesPath]];
    
    if (!tables) {
        tables = [[NSMutableArray alloc] init];
    }
    if (!items) {
        items = [[NSMutableArray alloc] init];
    }
    if (!categories) {
        categories = [[NSMutableArray alloc] init];
    }
}

@end

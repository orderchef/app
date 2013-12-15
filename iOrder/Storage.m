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
#import "Staff.h"
#import "AppDelegate.h"
#import "Report.h"

@interface Storage () {
    bool loadedData; // at least once....
}

@end

@implementation Storage

@synthesize tables, items, categories, staff, employee, reports;
@synthesize managedEmployee;

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
        [self loadData];
        loadedData = false;
        
        [[LTHPasscodeViewController sharedUser] setDelegate:self];
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
    @synchronized(self) {
        loadedData = true;
        
        NSString *name = [packet name];
        if ([name isEqualToString:@"get.tables"]) {
            [self setTables:[self loopAndLoad:[packet args] object:[Table class]]];
        } else if ([name isEqualToString:@"get.categories"]) {
            [self setCategories:[self loopAndLoad:[packet args] object:[ItemCategory class]]];
        } else if ([name isEqualToString:@"get.items"]) {
            [self setItems:[self loopAndLoad:[packet args] object:[Item class]]];
        } else if ([name isEqualToString:@"get.staff"]) {
            [self setStaff:[self loopAndLoad:[packet args] object:[Staff class]]];
            [[LTHPasscodeViewController sharedUser] loadStaff:staff];
        } else if ([name isEqualToString:@"get.reports"]) {
			[self setReports:[self loopAndLoad:[packet args] object:[Report class]]];
		}
        
        // for specific table
        else if ([name isEqualToString:@"get.items table"]) {
            [self forwardToTable:[packet args]];
        }
    }
}

- (void)loadData {
    SocketIO *socket = [[Connection getConnection] socket];
    
	[socket sendEvent:@"get.staff" withData:nil];
    [socket sendEvent:@"get.tables" withData:nil];
    [socket sendEvent:@"get.categories" withData:nil];
    [socket sendEvent:@"get.items" withData:nil];
}

- (ItemCategory *)findCategoryById:(NSString *)_id {
    for (ItemCategory *category in self.categories) {
        if ([category._id isEqualToString:_id]) {
            return category;
        }
    }
    
    return nil;
}

#pragma mark - LTHPasscodeViewControllerDelegate

- (void)passcodeViewControllerWasDismissed {
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}
- (void)maxNumberOfFailedAttemptsReached {
    
}
- (void)authenticatedAsUser:(Staff *)user {
    [self setEmployee:user];
    
    dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, 0.2 * NSEC_PER_SEC);
    dispatch_after(time, dispatch_get_main_queue(), ^(void) {
        [(AppDelegate *)[UIApplication sharedApplication].delegate showMessage:@"Logged in!" detail:[@"as " stringByAppendingString:user.name] hideAfter:1.5 showAnimated:NO hideAnimated:YES hide:YES tapRecognizer:nil toView:nil];
    });
}
- (void)changedPasscode:(NSString *)code {
    if (managedEmployee) {
        [[self managedEmployee] setCode:code];
    } else {
        [[self employee] setCode:code];
        [[self employee] save];
    }
}

@end

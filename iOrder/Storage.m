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
#import "Employee.h"
#import "AppDelegate.h"
#import "OrderGroup.h"
#import "Discount.h"

@interface Storage () {
    bool loadedData; // at least once....
}

@end

@implementation Storage

@synthesize tables, items, categories, staff, employee;
@synthesize managedEmployee;
@synthesize activeTable;

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
		loadedData = false;
        [[LTHPasscodeViewController sharedUser] setDelegate:self];
		[[Connection getConnection] addObserver:self forKeyPath:@"isConnected" options:NSKeyValueObservingOptionNew context:nil];
	}
	
	return self;
}

- (void)dealloc {
	@try {
		[[Connection getConnection] removeObserver:self forKeyPath:@"isConnected" context:nil];
	}
	@catch (NSException *exception) {}
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if ([keyPath isEqualToString:@"isConnected"]) {
		if ([[Connection getConnection] isConnected] && loadedData == false) {
			[self loadData];
		}
	}
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

- (void)forwardGroupToTable:(OrderGroup *)group {
    NSString *_id = [group table]._id;
    
    for (Table *table in tables) {
        if ([[table _id] isEqualToString:_id]) {
            [table setGroup:group];
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
			if (self.activeTable) {
				for (Table *t in [self tables]) {
					if ([t._id isEqualToString:activeTable._id]) {
						[self setActiveTable:t];
						break;
					}
				}
			}
        } else if ([name isEqualToString:@"get.categories"]) {
			[self setCategories:[self loopAndLoad:[packet args] object:[ItemCategory class]]];
            //[self updateCategories:packet.args];
        } else if ([name isEqualToString:@"get.items"]) {
            [self setItems:[self loopAndLoad:[packet args] object:[Item class]]];
        } else if ([name isEqualToString:@"get.staff"]) {
            [self setStaff:[self loopAndLoad:[packet args] object:[Employee class]]];
            [[LTHPasscodeViewController sharedUser] loadStaff:staff];
        } else if ([name isEqualToString:@"get.reports"]) {
			// reports
			[[NSNotificationCenter defaultCenter] postNotificationName:kReportsNotificationName object:self userInfo:(NSDictionary *)[[packet args] objectAtIndex:0]];
		} else if ([name isEqualToString:@"get.discounts"]) {
			// discounts
			NSArray *discounts = [self loopAndLoad:[packet args] object:[Discount class]];
			[[NSNotificationCenter defaultCenter] postNotificationName:kDiscountsNotificationName object:self userInfo:@{ @"discounts": discounts }];
		} else if ([name isEqualToString:@"print_data"]) {
			// Print data
			[[NSNotificationCenter defaultCenter] postNotificationName:kReceiptNotificationName object:self userInfo:(NSDictionary *)[[packet args] objectAtIndex:0]];
		}
        
        // for specific table
        else if ([name isEqualToString:@"get.group active"]) {
			for (NSDictionary *x in [packet.args objectAtIndex:0]) {
				NSString *gid = [x objectForKey:@"_id"];
				Table *found = nil;
				for (Table *t in tables) {
					if ([t.group._id isEqualToString:gid] || [t._id isEqualToString:[x objectForKey:@"table"]]) {
						found = t;
						break;
					}
				}
				
				if (!found.group) {
					found.group = [[OrderGroup alloc] init];
				}
				[found.group loadFromJSON:x];
				
				[found setGroup:found.group];
			}
        }
		else if ([name isEqualToString:@"get.order"]) {
			
		}
    }
}

- (void)updateCategories:(NSArray *)cats {
    if ([cats count] == 0) {
        return;
    }
    
	NSMutableArray *insert = [[NSMutableArray alloc] init];
	NSMutableArray *delete = [[NSMutableArray alloc] init];
	
    for (NSDictionary *x in [cats objectAtIndex:0]) {
		NSString *_id = [x objectForKey:@"_id"];
		
		bool found = false;
		for (ItemCategory *category in categories) {
			if ([category._id isEqualToString:_id]) {
				found = true;
				[category loadFromJSON:x];
				break;
			}
		}
		
		if (!found) {
			// Insert
			[insert addObject:x];
		}
	}
	
	for (ItemCategory *category in categories) {
		bool found = false;
		for (NSDictionary *x in [cats objectAtIndex:0]) {
			if ([[x objectForKey:@"_id"] isEqualToString:category._id]) {
				found = true;
				break;
			}
		}
		
		if (!found) {
			[delete addObject:category];
		}
	}
	
	for (NSDictionary *x in insert) {
		ItemCategory *cat = [[ItemCategory alloc] init];
		[cat loadFromJSON:x];
		
		[categories addObject:cat];
	}
	
	for (ItemCategory *del in delete) {
		[categories removeObjectIdenticalTo:del];
	}
}

- (void)loadData {
    SocketIO *socket = [[Connection getConnection] socket];
    
	[socket sendEvent:@"get.categories" withData:nil];
	[socket sendEvent:@"get.staff" withData:nil];
	[socket sendEvent:@"get.tables" withData:nil];
	
	double delayInSeconds = 0.2;
	dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
	dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
		[socket sendEvent:@"get.items" withData:nil];
	});
}

- (ItemCategory *)findCategoryById:(NSString *)_id {
    for (ItemCategory *category in self.categories) {
        if ([category._id isEqualToString:_id]) {
            return category;
        }
    }
    
    return nil;
}

- (ItemCategory *)findCategoryByName:(NSString *)name {
	for (ItemCategory *category in self.categories) {
        if ([category.name isEqualToString:name]) {
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
- (void)authenticatedAsUser:(Employee *)user {
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

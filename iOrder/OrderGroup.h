//
//  OrderGroup.h
//  iOrder
//
//  Created by Matej Kramny on 24/12/2013.
//  Copyright (c) 2013 Matej Kramny. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Storage.h"

@class Table;

@interface OrderGroup : NSObject <NetworkLoadingProtocol>

@property (nonatomic, strong) NSString *_id;
@property (nonatomic, strong) NSDate *created;
@property (nonatomic, strong) NSArray *orders;
@property (assign) BOOL cleared;
@property (nonatomic, strong) NSDate *clearedAt;

@property (nonatomic, strong) Table *table;

- (void)save;
- (void)getOrders;
- (void)clear;
- (void)printBill;

@end

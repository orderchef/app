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
@property (nonatomic, strong) NSArray *discounts;

@property (nonatomic, strong) NSString *postcode;
@property (nonatomic, strong) NSString *postcodeDistance;
@property (nonatomic, strong) NSString *deliveryTime;
@property (nonatomic, strong) NSString *cookingTime;
@property (nonatomic, strong) NSString *telephone;
@property (nonatomic, strong) NSString *customerName;

@property (nonatomic, strong) Table *table;

- (void)save;
- (void)getOrders;
- (void)clear;
- (void)printBill;

@end

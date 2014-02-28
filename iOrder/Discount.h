//
//  Discount.h
//  OrderChef
//
//  Created by Matej Kramny on 28/02/2014.
//  Copyright (c) 2014 Matej Kramny. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Storage.h"

@interface Discount : NSObject <NetworkLoadingProtocol>

@property (nonatomic, strong) NSString *_id;
@property (nonatomic, strong) NSString *name;
@property (assign) float value;
@property (nonatomic, strong) NSArray *tables;
@property (nonatomic, strong) NSArray *categories;

@property (assign) BOOL discountPercent;
@property (assign) BOOL allTables;
@property (assign) BOOL allCategories;

- (void)save;
- (void)remove;

@end

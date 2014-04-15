//
//  Item.h
//  iOrder
//
//  Created by Matej Kramny on 30/10/2013.
//  Copyright (c) 2013 Matej Kramny. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Storage.h"

@class ItemCategory, Table;

@interface Item : NSObject <NetworkLoadingProtocol>

@property (nonatomic, strong) NSString *_id;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSNumber *price;
@property (nonatomic, strong) ItemCategory *category;
@property (nonatomic, strong) Table *table;

- (void)save;
- (void)saveCategory:(ItemCategory *)theCategory;
- (void)deleteItem;
- (NSComparisonResult)caseInsensitiveCompare:(Item *)item;

@end

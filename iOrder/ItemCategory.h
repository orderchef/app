//
//  ItemCategory.h
//  iOrder
//
//  Created by Matej Kramny on 30/10/2013.
//  Copyright (c) 2013 Matej Kramny. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Storage.h"

@class Item;

@interface ItemCategory : NSObject <NetworkLoadingProtocol>

@property (nonatomic, strong) NSString *_id;
@property (nonatomic, strong) NSString *name;

@property (assign) BOOL drink;
@property (assign) BOOL hotFood;
@property (assign) BOOL sushi;

- (void)save;
- (void)deleteCategory;

@end

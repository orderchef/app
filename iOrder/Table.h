//
//  Table.h
//  iOrder
//
//  Created by Matej Kramny on 30/10/2013.
//  Copyright (c) 2013 Matej Kramny. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Storage.h"

@class Item;
@class OrderGroup;

@interface Table : NSObject <NetworkLoadingProtocol>

@property (nonatomic, strong) NSString *_id;
@property (nonatomic, strong) NSString *name;
@property (assign) BOOL delivery;
@property (assign) BOOL takeaway;
@property (nonatomic, strong) OrderGroup *group;

- (void)save;
- (void)loadItems;
- (void)clearTable;
- (void)sendToKitchen;
- (void)deleteTable;

@end

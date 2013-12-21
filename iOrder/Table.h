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

@interface Table : NSObject <NetworkLoadingProtocol>

@property (nonatomic, strong) NSString *_id;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSArray *items;
@property (nonatomic, strong) NSString *notes;
@property (assign) BOOL delivery;
@property (assign) BOOL takeaway;

- (void)save;
- (void)loadItems;
- (void)loadItems:(NSArray *)items;
- (void)addItem:(Item *)item;
- (void)removeItem:(Item *)item;
- (void)clearTable;
- (void)sendToKitchen;
- (void)deleteTable;

@end

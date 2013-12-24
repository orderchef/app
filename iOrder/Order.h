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
@class Item;

@interface Order : NSObject <NetworkLoadingProtocol>

@property (nonatomic, strong) NSString *_id;
@property (nonatomic, strong) NSString *notes;
@property (nonatomic, strong) NSDate *created;
@property (nonatomic, strong) NSArray *items;
@property (assign) BOOL printed;
@property (nonatomic, strong) NSDate *printedAt;

@property (nonatomic, weak) OrderGroup *group;

- (void)addItem:(Item *)item;

@end

//
//  ItemCategory.h
//  iOrder
//
//  Created by Matej Kramny on 30/10/2013.
//  Copyright (c) 2013 Matej Kramny. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Storage.h"

@class Item;

@interface ItemCategory : NSObject <NetworkLoadingProtocol>

@property (nonatomic, strong) NSString *_id;
@property (nonatomic, strong) NSString *name;

- (void)save;

@end

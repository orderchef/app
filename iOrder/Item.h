//
//  Item.h
//  iOrder
//
//  Created by Matej Kramny on 30/10/2013.
//  Copyright (c) 2013 Matej Kramny. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class ItemCategory, Table;

@interface Item : NSObject <NSCoding>

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * price;
@property (nonatomic, retain) NSDecimalNumber * quantity;
@property (nonatomic, retain) ItemCategory *category;
@property (nonatomic, retain) Table *table;

@end

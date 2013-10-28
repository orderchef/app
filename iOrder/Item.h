//
//  Item.h
//  iOrder
//
//  Created by Matej Kramny on 28/10/2013.
//  Copyright (c) 2013 Matej Kramny. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class ItemCategory;
@class Table;

@interface Item : NSManagedObject

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) ItemCategory *category;
@property (nonatomic, retain) Table *table;

@end

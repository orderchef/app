//
//  ItemCategory.h
//  iOrder
//
//  Created by Matej Kramny on 28/10/2013.
//  Copyright (c) 2013 Matej Kramny. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Item;

@interface ItemCategory : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) Item *item;

@end

//
//  Table.h
//  iOrder
//
//  Created by Matej Kramny on 28/10/2013.
//  Copyright (c) 2013 Matej Kramny. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Item;

@interface Table : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *item;
@end

@interface Table (CoreDataGeneratedAccessors)

- (void)addItemObject:(Item *)value;
- (void)removeItemObject:(Item *)value;
- (void)addItem:(NSSet *)values;
- (void)removeItem:(NSSet *)values;

@end

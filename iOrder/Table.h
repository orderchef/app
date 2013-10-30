//
//  Table.h
//  iOrder
//
//  Created by Matej Kramny on 30/10/2013.
//  Copyright (c) 2013 Matej Kramny. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Item;

@interface Table : NSObject <NSCoding>

@property (nonatomic, strong) NSString * name;
@property (nonatomic, strong) NSMutableArray *items;

@end

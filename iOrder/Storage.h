//
//  Settings.h
//  iOrder
//
//  Created by Matej Kramny on 30/10/2013.
//  Copyright (c) 2013 Matej Kramny. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LTHPasscodeViewController.h"

@class SocketIOPacket;
@class ItemCategory;

@protocol NetworkLoadingProtocol <NSObject>

- (void)loadFromJSON:(NSDictionary *)json;

@end

@interface Storage : NSObject <LTHPasscodeViewControllerDelegate>

+ (Storage *)getStorage;

@property (nonatomic, strong) NSMutableArray *tables;
@property (nonatomic, strong) NSMutableArray *items;
@property (nonatomic, strong) NSMutableArray *categories;
@property (nonatomic, strong) NSMutableArray *staff;
@property (nonatomic, strong) Staff *employee;
@property (nonatomic, weak) Staff *managedEmployee;

- (void)loadData;

- (void)parseEvent:(SocketIOPacket *)packet;

- (ItemCategory *)findCategoryById:(NSString *)_id;

@end

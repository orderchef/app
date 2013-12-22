//
//  Report.h
//  iOrder
//
//  Created by Matej Kramny on 15/12/2013.
//  Copyright (c) 2013 Matej Kramny. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Storage.h"

@interface Report : NSObject <NetworkLoadingProtocol>

@property (nonatomic, strong) NSString *_id;
@property (nonatomic, strong) NSDate *created;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *notes;
@property (nonatomic, strong) NSArray *items;
@property (assign) float total;
@property (assign) int quantity;
@property (assign) BOOL delivery;
@property (assign) BOOL takeaway;

- (void)save;
- (void)print;

@end


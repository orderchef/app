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
@property (nonatomic, strong) NSArray *tables;
@property (assign) int quantity;
@property (assign) float total;

- (void)save;
- (void)print;

@end


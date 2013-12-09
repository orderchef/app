//
//  Connection.h
//  iOrder
//
//  Created by Matej Kramny on 30/10/2013.
//  Copyright (c) 2013 Matej Kramny. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <socket.IO/SocketIO.h>

@interface Connection : NSObject <SocketIODelegate>

+ (Connection *)getConnection;

- (void)connect;
- (void)disconnect;

@property (nonatomic, strong) SocketIO *socket;
@property (assign) BOOL isConnected;

@end

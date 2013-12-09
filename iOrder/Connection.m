//
//  Connection.m
//  iOrder
//
//  Created by Matej Kramny on 30/10/2013.
//  Copyright (c) 2013 Matej Kramny. All rights reserved.
//

#import "Connection.h"
#import <socket.IO/SocketIOPacket.h>
#import "Storage.h"

@implementation Connection

@synthesize socket;

@synthesize isConnected;

+ (Connection *)getConnection {
    static Connection *connection;
    
    @synchronized(self) {
        if (!connection)
            connection = [[Connection alloc] init];
        
        return connection;
    }
}

- (id)init {
    self = [super init];
    
    if (self) {
        [self connect];
    }
    
    return self;
}

- (void)connect {
    if (socket && (socket.isConnected || socket.isConnecting)) {
        return;
    }
    
    socket = [[SocketIO alloc] initWithDelegate:self];
    [socket connectToHost:@"127.0.0.1" onPort:8080];
}

- (void)disconnect {
    [self setIsConnected:false];
    [socket disconnect];
}

- (void)socketIODidConnect:(SocketIO *)socket {
	NSLog(@"Connected");
    [self setIsConnected:true];
}

- (void)socketIODidDisconnect:(SocketIO *)socket disconnectedWithError:(NSError *)error {
	NSLog(@"Disconnected %@", error);
    [self setIsConnected:false];
}

- (void)socketIO:(SocketIO *)socket didReceiveEvent:(SocketIOPacket *)packet {
    [[Storage getStorage] parseEvent:packet];
}

@end

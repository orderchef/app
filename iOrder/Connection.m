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

@interface Connection () {
    int lastDisconnect;
    int disconnectedQuickly;
}

@end

@implementation Connection

@synthesize socket;
@synthesize isConnected;
@synthesize shouldAttemptRecovery;

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
        disconnectedQuickly = 0;
        lastDisconnect = -1;
        shouldAttemptRecovery = YES;
    }
    
    return self;
}

- (void)connect {
    NSLog(@"Connecting..");
    if (socket && (socket.isConnected || socket.isConnecting)) {
        return;
    }
    
    if (!socket) {
        socket = [[SocketIO alloc] initWithDelegate:self];
    }
    [socket connectToHost:@"192.168.0.9" onPort:8080];
}

- (void)disconnect {
    [self setIsConnected:false];
    [socket disconnect];
}

- (void)attemptReconnect {
    if (!shouldAttemptRecovery) {
        return;
    }
    
    if (disconnectedQuickly > 2) {
        disconnectedQuickly = 0;
        lastDisconnect = -1;
    } else {
        int now = [[NSDate date] timeIntervalSince1970];
        if (lastDisconnect > now-3) {
            disconnectedQuickly++;
        } else {
            disconnectedQuickly = 0;
        }
        
        lastDisconnect = now;
        
        [self connect];
    }
}

- (void)socketIODidConnect:(SocketIO *)socket {
	NSLog(@"Connected");
    [self setIsConnected:true];
}

- (void)socketIODidDisconnect:(SocketIO *)socket disconnectedWithError:(NSError *)error {
	NSLog(@"Disconnected %@", error);
    [self setIsConnected:false];
    
    [self attemptReconnect];
}

- (void)socketIO:(SocketIO *)socket onError:(NSError *)error {
    NSLog(@"Errord %@", error);
    [self setIsConnected:NO];
    
    [self attemptReconnect];
}

- (void)socketIO:(SocketIO *)socket didReceiveEvent:(SocketIOPacket *)packet {
    [[Storage getStorage] parseEvent:packet];
}

@end

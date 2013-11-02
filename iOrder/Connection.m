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
    socket = [[SocketIO alloc] initWithDelegate:self];
    [socket connectToHost:@"192.168.2.31" onPort:8080];
}

- (void)socketIODidConnect:(SocketIO *)socket {
	NSLog(@"Connected");
}

- (void)socketIODidDisconnect:(SocketIO *)socket disconnectedWithError:(NSError *)error {
	NSLog(@"Disconnected %@", error);
}

- (void)socketIO:(SocketIO *)socket didReceiveJSON:(SocketIOPacket *)packet {
	NSLog(@"Received %@", packet);
}

- (void)socketIO:(SocketIO *)socket didReceiveMessage:(SocketIOPacket *)packet {
	NSLog(@"Message %@", packet);
}

- (void)socketIO:(SocketIO *)socket didReceiveEvent:(SocketIOPacket *)packet {
	NSLog(@"Event %@", [packet name]);
    NSLog(@"Arguments: %@", [packet args]);
    
    [[Storage getStorage] parseEvent:packet];
}

- (void)socketIO:(SocketIO *)socket didSendMessage:(SocketIOPacket *)packet {
	NSLog(@"Send Message %@", packet);
}

- (void)socketIO:(SocketIO *)socket onError:(NSError *)error {
	NSLog(@"Error %@", error);
}

@end

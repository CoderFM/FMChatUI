//
//  SignalRClient.h
//  qygt
//
//  Created by 周发明 on 16/8/9.
//  Copyright © 2016年 途购. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Singler.h"
#import <SignalR.h>
#import <SRConnection.h>

@protocol SignalRClientDelegate <NSObject>

@required

- (void)SignalRClientReceiveGroupMessage:(id)message;

- (void)SignalRClientConnectStateChange:(connectionState)newState;

- (void)SignalRClientReceiveActionNotify:(id)message;
@end


@interface SignalRClient : NSObject
SingleH(SignalRClient)

@property(nonatomic, weak)id<SignalRClientDelegate> delegate;

@property(nonatomic, copy)NSString *access_token;

- (void)connectAdress:(NSString *)url access_token:(NSString *)token;

- (void)connectWithAccess_token:(NSString *)token;

- (void)sendMessage:(id)message completionHandler:(void (^)(id response, NSError *error))block;

- (void)stopConnection;

@end

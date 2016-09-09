//
//  SignalRClient.m
//  qygt
//
//  Created by 周发明 on 16/8/9.
//  Copyright © 2016年 途购. All rights reserved.
//

#import "SignalRClient.h"
#import "IMBaseAttribute.h"

#define Access_token @"access_token"
#define EquipmentId @"equipmentId"

#define ReceiveSingleMessageNotiKey @"ReceiveSingleMessage"
#define ReceiveGroupMessageNotiKey  @"ReceiveGroupMessage"
#define ReceiveNoticeMessageNotiKey @"ReceiveNoticeMessage"
#define ReceiveIllustratedMaterialMessageNotiKey @"ReceiveIllustratedMaterialMessage"
#define ForceOfflineNotiKey  @"ForceOffline"
#define ActionNotifyNotiKey @"ActionNotify"

#define SendGroupMessageKey @"SendGroupMessage"

@interface SignalRClient()<SRConnectionDelegate>

@property(nonatomic, strong)SRHubConnection *connection;

@property(nonatomic, strong) SRHubProxy *proxy;

@property(nonatomic, copy)NSString *connectionUrl;

@property(nonatomic, copy)NSString *token;

/**
 *  链接次数
 */
@property(nonatomic, assign)NSInteger connectTime;

@end

@implementation SignalRClient

SingleM(SignalRClient)

- (void)connectAdress:(NSString *)url access_token:(NSString *)token{
    SRHubConnection *connection = [SRHubConnection connectionWithURLString:url];
    [connection addValue:token forHTTPHeaderField:Access_token];
    [connection addValue:token forHTTPHeaderField:EquipmentId];
    [connection addValue:@"0" forHTTPHeaderField:@"PointX"];
    [connection addValue:@"0" forHTTPHeaderField:@"PointY"];
    self.access_token = token;
    self.connection = connection;
    self.proxy = [connection createHubProxy:@"ChatHub"];
    
    /*
     [hub on:RECEIVESINGLEMESSSGE perform:self selector:@selector(ReceiveMessage:)];
     [hub on:RECEIVEGROUPMESSAGE  perform:self selector:@selector(ReceiveMessage:)];
     [hub on:RECEIVENOTICEMESSAGE perform:self selector:@selector(ReceiveNoticeMessage:)];
     [hub on:RECEIVESYSTEMMESSAGE perform:self selector:@selector(ReceiveSystemMessage:)];
     [hub on:RECEIVELOGINMESSAGE perform:self selector:@selector(forceOffLineUser:)];
     [hub on:RECEIVEACTIONMESSAGE perform:self selector:@selector(receiveActionNotify:)];
     */
    
    [self.proxy on:ReceiveGroupMessageNotiKey perform:self selector:@selector(ReceiveGroupMessage:)];
    [self.proxy on:ActionNotifyNotiKey perform:self selector:@selector(ReceiveActionNotify:)];
    [self.proxy on:ReceiveNoticeMessageNotiKey perform:self selector:@selector(ReceiveNoticeMessageNoti:)];
    self.connection.delegate = self;
    [self.connection start];
}

- (void)connectWithAccess_token:(NSString *)token{
    self.token = token;
//    [self connectAdress:@"http://chat03.safetree.com.cn/" access_token:token];
    [self getNewIMServerURL];
}

- (void)stopConnection{
    if (self.connection.state != disconnected) {
        [self.connection disconnect];
    }
    self.connection.delegate = nil;
    self.connection = nil;
    self.proxy = nil;
}

/**
 *  获取新的IM地址
 */
- (void)getNewIMServerURL{
    WeakSelf
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager GET:[[ChatLoadMessage stringByAppendingString:GetChatSeverIp] stringByAppendingString:@"1"] parameters:nil success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        NSLog(@"%@ ",responseObject);
        if ([responseObject[@"e1"] integerValue] == 0) {
            NSDictionary *dict = responseObject[@"d"];
            [weakSelf connectAdress:dict[@"U"] access_token:weakSelf.token];
        } else {
            [[UIApplication sharedApplication] alertWithMessage:responseObject[@"e2"]];
//            [weakSelf getNewIMServerURL];
        }
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        [[UIApplication sharedApplication] alertWithMessage:@"获取聊天服务器失败"];
    }];
}

#pragma mark - 接收到群消息
- (void)ReceiveGroupMessage:(id)message{
    if ([self.delegate respondsToSelector:@selector(SignalRClientReceiveGroupMessage:)]) {
        [self.delegate SignalRClientReceiveGroupMessage:message];
    }
}

- (void)ReceiveActionNotify:(id)message{
    
    if ([self.delegate respondsToSelector:@selector(SignalRClientReceiveActionNotify:)]) {
        [self.delegate SignalRClientReceiveActionNotify:message];
    }
    
//    [[UIApplication sharedApplication] alertWithMessage:[NSString stringWithFormat:@"%@", message]];
//    
    
}

#pragma mark - 链接成功
- (void)SRConnectionDidOpen:(id <SRConnectionInterface>)connection{
    NSLog(@"链接成功");
}

#pragma mark - 即将重连
- (void)SRConnectionWillReconnect:(id <SRConnectionInterface>)connection{
    NSLog(@"即将重连");
}

#pragma mark - 重连
- (void)SRConnectionDidReconnect:(id <SRConnectionInterface>)connection{
    NSLog(@"重连");
}

#pragma mark - 接收到数据
- (void)SRConnection:(id <SRConnectionInterface>)connection didReceiveData:(id)data{
    NSLog(@"接收到数据%@", data);
}

#pragma mark - 关闭链接
- (void)SRConnectionDidClose:(id <SRConnectionInterface>)connection{
    if (self.connectTime > 2) {
        [self stopConnection];
        [self getNewIMServerURL];
    }
    NSLog(@"关闭链接");
}

#pragma mark - 收到错误
- (void)SRConnection:(id <SRConnectionInterface>)connection didReceiveError:(NSError *)error{
    NSLog(@"收到错误, %@", error);
}

#pragma mark - 链接状态改变
- (void)SRConnection:(id <SRConnectionInterface>)connection didChangeState:(connectionState)oldState newState:(connectionState)newState{
    
    switch (newState) {
        case connected:
            self.connectTime = 0;
            break;
            
        default:
            break;
    }
    
    
    if ([self.delegate respondsToSelector:@selector(SignalRClientConnectStateChange:)]){
        [self.delegate SignalRClientConnectStateChange:newState];
    }
}

#pragma mark - 链接缓慢
- (void)SRConnectionDidSlow:(id <SRConnectionInterface>)connection{
    NSLog(@"链接缓慢");
}

- (void)sendMessage:(id)message completionHandler:(void (^)(id response, NSError *error))block{
    if (self.connection.state == connected) {
        [self.proxy invoke:SendGroupMessageKey withArgs:@[message] completionHandler:block];
    } else if ([SignalRClient shareSignalRClient].connection.state == connecting){
        [[UIApplication sharedApplication] alertWithMessage:@"链接中......"];
    } else if ([SignalRClient shareSignalRClient].connection.state == reconnecting){
        [[UIApplication sharedApplication] alertWithMessage:@"正在重新链接中"];
    } else {
        [[UIApplication sharedApplication] alertWithMessage:@"已断开"];
    }
    
}

- (void)dealloc{
    NSLog(@"SignalRClient销毁了");
}

@end

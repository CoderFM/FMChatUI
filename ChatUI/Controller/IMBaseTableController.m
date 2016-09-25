//
//  IMTableViewController.m
//  qygt
//
//  Created by 周发明 on 16/8/4.
//  Copyright © 2016年 途购. All rights reserved.
//

#import "IMBaseTableController.h"
#import "IMBaseCell.h"
#import "IMBaseItem.h"
#import "MJRefresh.h"
#import "IMBaseAttribute.h"
#import "IMBaseItemTool.h"
#import "Masonry.h"
#import "IMAudioTool.h"
#import "IMDownloadManager.h"
#import "IMSQLiteTool.h"
#import "IMChatToolBar.h"



@interface IMBaseTableController ()<IMBaseCellDelegate, IMChatToolBarDelegate, UITableViewDataSource, UITableViewDelegate>

@property(nonatomic, weak)UIButton *bubbleButton;

@property(nonatomic, weak)UILabel *bubbleLabel;

@property(nonatomic, assign)NSInteger unreadCount;

@property(nonatomic, weak)IMChatToolBar *chatToolBar;

@end

@implementation IMBaseTableController{

}

CGFloat SchoolTopHeight = 44;

CGFloat SchoolChatToolBarHeight = 55;

CGFloat SchoolChatMoreHeight = 120;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [self.reloadTable addObserver:self forKeyPath:@"messages" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:NULL];
    
    self.lastMessageId = @"";
    
    [self setUpTableView];
    
    [self setUpBubbleView];
    
    [self loadData];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context{
    
    if ([keyPath isEqualToString:@"messages"]) {
        
        /*
         typedef NS_OPTIONS(NSUInteger, NSKeyValueChange) {
         
         NSKeyValueChangeSetting = 1,
         
         NSKeyValueChangeInsertion = 2,
         
         NSKeyValueChangeRemoval = 3,
         
         NSKeyValueChangeReplacement = 4
         
         };
         */
        
//        MainQueueBlock(^{
        
            NSInteger kind = [change[@"kind"] integerValue];
            
            IMBaseItem *item = [change[@"new"] firstObject];
            
            if (kind == NSKeyValueChangeReplacement){
                
                [self.tableView reloadData];
        
            } else if (kind == NSKeyValueChangeInsertion){
                if (self.reloadTable.messages.count <= 10) {
                    [self.tableView reloadData];
                    [self scrollToBottom];
                } else {
                    [self.tableView reloadData];
                    if (item.scrollToIndex > 0) {// 插入
                        if (self.reloadTable.messages.count > item.scrollToIndex) {
                            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.reloadTable.messages.count - item.scrollToIndex inSection:0];
                            [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
                        }
                    } else {// 追加
                        NSIndexPath *lastIndexPath = [[self.tableView indexPathsForVisibleRows] lastObject];
                        if (lastIndexPath.row == self.reloadTable.messages.count - 2) {
                            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.reloadTable.messages.count - 1 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
                        } else {
                            self.unreadCount++;
                        }
                    }
                }
            }

//        })
        
    }
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
}

- (void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    [self chatToolBar];
}

#pragma mark - 初始化tableView
- (void)setUpTableView{
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    
    [self.view addSubview:tableView];
    
    tableView.delegate = self;
    
    tableView.dataSource = self;
    
    tableView.backgroundColor = UIColorFromRGB(0xf7f7f7);
    
    self.tableView = tableView;
    
    self.tableView.frame = CGRectMake(0, 64, SCREEN_WIDTH, SCREEN_HEIGHT - 64 - SchoolChatToolBarHeight);
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self.tableView registerClass:[IMBaseCell class] forCellReuseIdentifier:NSStringFromClass([IMBaseCell class])];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:NSStringFromClass([UITableViewCell class])];
    
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadMoreData)];
}

#pragma mark - 初始化气泡View
- (void)setUpBubbleView{
    
    UIButton *btn = [[UIButton alloc] init];
    
    [btn setBackgroundImage:[UIImage imageNamed:@"school_chat_unread_ bubble"] forState:UIControlStateNormal];
    
    [self.view addSubview:btn];
    
    self.bubbleButton = btn;
    
    [self.bubbleButton addTarget:self action:@selector(bubbleButtonClick) forControlEvents:UIControlEventTouchUpInside];
    
    [self.bubbleButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(@(-30));
        make.bottom.equalTo(@(-10));
        make.width.equalTo(@30);
        make.height.equalTo(@37);
    }];
    
    UILabel *label = [[UILabel alloc] init];
    
    label.font = [UIFont systemFontOfSize:12];
    
    label.textColor = [UIColor whiteColor];
    
    label.textAlignment = NSTextAlignmentCenter;
    
    [self.bubbleButton addSubview:label];
    
    self.bubbleLabel = label;
    
    [self.bubbleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.bubbleButton);
        make.centerY.equalTo(self.bubbleButton).offset(-4);
    }];
    
    self.unreadCount = 0;
}

- (void)loadData{
    WeakSelf
    [IMSQLiteTool loadMessagesWithMessageTime:@"" reviceID:[IMBaseAttribute shareIMBaseAttribute].reciverID withTeacherID:@"11" isExclude:NO RerutnMessagesBlock:^(NSArray *messages) {
        if (messages && messages.count > 0) {
            IMBaseItem *item = [messages lastObject];
            weakSelf.lastMessageId = item.chatMessageIdentifier;
            weakSelf.lastMessageTime = item.messageTime;
            [messages enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                [weakSelf reloadDataWithMessage:obj isInser:NO];
            }];
        }
    }];
    
}

- (void)loadMoreData{
    
    self.scrollToIndex = self.reloadTable.messages.count;
    WeakSelf
    [IMSQLiteTool loadMessagesWithMessageTime:self.lastMessageTime reviceID:[IMBaseAttribute shareIMBaseAttribute].reciverID withTeacherID:@"11" isExclude:NO RerutnMessagesBlock:^(NSArray *messages) {
        if (messages && messages.count > 0) {
            IMBaseItem *item = [messages lastObject];
            weakSelf.lastMessageId = item.chatMessageIdentifier;
            weakSelf.lastMessageTime = item.messageTime;
            [messages enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                [weakSelf reloadDataWithMessage:obj isInser:YES];
            }];
        }
        [weakSelf.tableView.mj_header endRefreshing];
    }];
}

#pragma mark - 处理服务器数据
- (void)handleServerData:(NSArray *)messages isInser:(BOOL)isInser{
    
//    BackgroundThreadBlock(^{
        int count = (int)messages.count;
        for (int i = count - 1; i > -1; i--) {
            [IMBaseItemTool itemWithDict:messages[i] success:^(IMBaseItem *item) {
                [self reloadDataWithMessage:item isInser:isInser];
            }];
        }
//    });

}

#pragma mark - 根据IMBaseItem对象刷新列表

- (void)reloadDataWithMessage:(IMBaseItem *)messageItem isInser:(BOOL)isInser{
    
//    BackgroundThreadBlock(^{
    
        if (isInser) {
            [self inserItemTableViewUpdate:messageItem];
        } else {
            if ([self isHaveMessage:messageItem] != -1 || [[self.reloadTable mutableArrayValueForKey:@"messages"] containsObject:messageItem]) {
                NSInteger row = 0;
                if ([[self.reloadTable mutableArrayValueForKey:@"messages"] containsObject:messageItem]) {
                    row = [[self.reloadTable mutableArrayValueForKey:@"messages"] indexOfObject:messageItem];
                } else {
                    row = [self isHaveMessage:messageItem];
                }
                
//                dispatch_async(queue, ^{
//                    @synchronized(self.reloadTable) {
                        [[self.reloadTable mutableArrayValueForKey:@"messages"] replaceObjectAtIndex:row withObject:messageItem];
//                    }
//                });
                
            } else {
                [self addItemTableViewUpdata:messageItem];
            }
        }
//    })
    
}

#pragma mark - 滚动到底部
- (void)scrollToBottom{
    
    if ([self.reloadTable mutableArrayValueForKey:@"messages"].count > 0) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[self.reloadTable mutableArrayValueForKey:@"messages"].count - 1 inSection:0];
        
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
}

#pragma mark - 气泡点击
- (void)bubbleButtonClick{
    
    if ([self.reloadTable mutableArrayValueForKey:@"messages"].count - self.unreadCount > 0) {
        
        NSInteger index = [self.reloadTable mutableArrayValueForKey:@"messages"].count - self.unreadCount;
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
        
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
    
}

#pragma mark - 设置气泡数
- (void)setUnreadCount:(NSInteger)unreadCount{
    _unreadCount = unreadCount;
    if (unreadCount > 0) {
        self.bubbleButton.hidden = NO;
        self.bubbleLabel.text = [NSString stringWithFormat:@"%ld", self.unreadCount];
    } else {
        self.bubbleButton.hidden = YES;
    }
}

#pragma mark - tableViewDelegate and dataSouce and scrollViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.reloadTable mutableArrayValueForKey:@"messages"].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.row < [self.reloadTable mutableArrayValueForKey:@"messages"].count) {
        
    id message = [self.reloadTable mutableArrayValueForKey:@"messages"][indexPath.row];
        
        IMBaseCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([IMBaseCell class])];
        
        __weak typeof(self)weakSelf = self;
        [cell setReloadCell:^(IMBaseItem *item) {
            [[weakSelf.reloadTable mutableArrayValueForKey:@"messages"] replaceObjectAtIndex:indexPath.row withObject:item];
            [weakSelf.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        }];
        
        cell.style = indexPath.row % 2;
        
        cell.messageItem = message;
        
        cell.delegate = self;
        
        return cell;
        
    }
    
    return [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([UITableViewCell class])];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.row >= [self.reloadTable mutableArrayValueForKey:@"messages"].count - self.unreadCount) {
        self.unreadCount = 0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.row < [self.reloadTable mutableArrayValueForKey:@"messages"].count) {
        
        id message = [self.reloadTable mutableArrayValueForKey:@"messages"][indexPath.row];
        
        if ([message isKindOfClass:[NSString class]]) {// 时间cell
            
            return 50;
            
        } else { // 消息的cell
            
            if ([message isKindOfClass:[IMBaseItem class]]) {
                
                IMBaseItem *item = (IMBaseItem *)message;
                
                return item.cellHeight;
                
            }
            
        }
        
    }
    
    return 0;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [self.view endEditing:YES];
    [self.chatToolBar backOriginalHeight];
}

#pragma mark - IMChatToolBarDelegate

- (void)IMChatToolBar:(IMChatToolBar *)schoolChatToolBar imBaseItem:(IMBaseItem *)messageItem{
    [IMSQLiteTool savaWithMessage:messageItem];
    [self reloadDataWithMessage:messageItem isInser:NO];
}

- (void)IMChatToolBar:(IMChatToolBar *)schoolChatToolBar sendIMBaseItem:(IMBaseItem *)message{
    [IMSQLiteTool savaWithMessage:message];
    [self reloadDataWithMessage:message isInser:NO];
}

- (void)IMChatToolBar:(IMChatToolBar *)schoolChatToolBar ReloadHeight:(CGFloat)reloadHeight{
    
    if (schoolChatToolBar.inputTextView.isFirstResponder) {
        [self scrollToBottom];
    }
    
    CGRect frame = self.tableView.frame;
    frame.origin.y = 64 - reloadHeight;
    [UIView animateWithDuration:0.25 animations:^{
        self.tableView.frame = frame;
    }];
}

#pragma mark - IMBaseCell delegate

- (void)IMBaseCell:(IMBaseCell *)cell presentViewController:(UIViewController *)viewController animated:(BOOL)animated completion:(void (^)())completion{
    [[IMAudioTool shareAudioTool] stopPlay];
    [self presentViewController:viewController animated:animated completion:completion];
}

- (void)IMBaseCell:(IMBaseCell *)cell reSendMessage:(IMBaseItem *)message{
    if ([self.imBaseDelegate respondsToSelector:@selector(baseTableController:sendMessage:)]) {
        [self.imBaseDelegate baseTableController:self sendMessage:message];
    }
}

#pragma mark - 语音Cell点击的回调
- (void)IMBaseCellClickAudioCell:(IMBaseCell *)cell{
    
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    
    [self playAudioWithIndexPath:indexPath autoNext:YES];
    
}
/**
 *  准备播放
 *
 *  @param indexPath 播放的哪一行
 *  @param next      是否播放下一行未读
 */
- (void)playAudioWithIndexPath:(NSIndexPath *)indexPath autoNext:(BOOL)next{
    
    IMBaseItem *message = [self.reloadTable mutableArrayValueForKey:@"messages"][indexPath.row];
    
    WeakSelf
    if (message.messageBody.locationPath && message.messageBody.locationPath.length > 0) {
        message.isPlaying = YES;
        [self reloadDataWithMessage:message isInser:NO];
        [[IMAudioTool shareAudioTool] playWithFileName:message.messageBody.locationPath returnBeforeFileName:^(NSString *beforeFileName) {
            [weakSelf cancelAudioPlayWithFileName:beforeFileName];
        } withFinishBlock:^(BOOL isFinish) {
            message.isPlaying = !isFinish;
            message.readState = IMMessageReaded;
            [weakSelf reloadDataWithMessage:message isInser:NO];
            if (next) {
                if ([weakSelf getNextIndexPathForUnReadAudioWithCurrentIndexPath:indexPath]) {
                    [weakSelf playAudioWithIndexPath:[weakSelf getNextIndexPathForUnReadAudioWithCurrentIndexPath:indexPath] autoNext:YES];
                }
            }
        }];
    } else {
        NSString *fileName = [NSString stringWithFormat:@"%d%d.mp3", (int)[[NSDate date] timeIntervalSince1970], arc4random() % 100000];
        WeakSelf
        [IMDownloadManager downLoadFileUrl:message.messageBody.voiceUrlString datePath:[IMBaseAttribute dataAudioPath] fileName:fileName completionHandler:^(BOOL isSuccess) {
            if (isSuccess) {
                message.messageBody.locationPath = fileName;
                [IMSQLiteTool updateMessage:message withKey:@"messageBody"];
                message.isPlaying = YES;
                [weakSelf reloadDataWithMessage:message isInser:NO];
                [[IMAudioTool shareAudioTool] playWithFileName:message.messageBody.locationPath returnBeforeFileName:^(NSString *beforeFileName) {
                    [weakSelf cancelAudioPlayWithFileName:beforeFileName];
                } withFinishBlock:^(BOOL isFinish) {
                    message.isPlaying = !isFinish;
                    message.readState = IMMessageReaded;
                    [weakSelf reloadDataWithMessage:message isInser:NO];
                    if (next) {
                        if ([weakSelf getNextIndexPathForUnReadAudioWithCurrentIndexPath:indexPath]) {
                            [weakSelf playAudioWithIndexPath:[weakSelf getNextIndexPathForUnReadAudioWithCurrentIndexPath:indexPath] autoNext:YES];
                        }
                    }
                }];
            } else {
                NSLog(@"播放失败");
            }
        }];
    }
}
/**
 *  获取下一行未读的IndexPath
 *
 *  @param currentIndexPath 当前播放的IndexPath
 *
 *  @return 下一行未读的IndexPath
 */
- (NSIndexPath *)getNextIndexPathForUnReadAudioWithCurrentIndexPath:(NSIndexPath *)currentIndexPath{
    
    if (currentIndexPath.row < [self.reloadTable mutableArrayValueForKey:@"messages"].count - 1) {
        
        for (NSInteger i = currentIndexPath.row + 1; i < [self.reloadTable mutableArrayValueForKey:@"messages"].count - 1; i++) {
            
            IMBaseItem *item = [self.reloadTable mutableArrayValueForKey:@"messages"][i];
            
            if (item.messageType == IMMessageAudioType && item.readState == IMMessageUnRead) {
                
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
                
                return indexPath;
                
            } else {
                continue;
            }
        }
    }
    
    return nil;
}

- (void)cancelAudioPlayWithFileName:(NSString *)fileName{
    
    if (fileName) {
        NSArray *arr = [[self.reloadTable mutableArrayValueForKey:@"messages"] valueForKey:@"messageBody"];
        
        WeakSelf
        
        [arr enumerateObjectsUsingBlock:^(IMMessageBody *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            if (obj.type == IMMessageAudioType && [obj.locationPath isEqualToString:fileName]) {
                
                IMBaseItem *item = [self.reloadTable mutableArrayValueForKey:@"messages"][idx];
                
                item.isPlaying = NO;
                
                item.readState = IMMessageReaded;
                
                [weakSelf reloadDataWithMessage:item isInser:NO];
            }
        }];
    }
    
}

#pragma mark - 处理插入消息
- (void)inserItemTableViewUpdate:(IMBaseItem *)item{
    
    if ([self isHaveMessage:item] != -1) return;
    
    // 以下是从上往下插入
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    
    formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    
    if ([self.reloadTable mutableArrayValueForKey:@"messages"].count == 0){ //此时数组没有数据  直接加入  刷新列表
        
//        dispatch_async(queue, ^{
//            @synchronized(self.reloadTable) {
                [[self.reloadTable mutableArrayValueForKey:@"messages"] addObject:item];
//            }
//        });
        
    } else if ([self.reloadTable mutableArrayValueForKey:@"messages"].count == 1) { // 有一个数据  与之比较
        
        IMBaseItem *item2 = [self.reloadTable mutableArrayValueForKey:@"messages"][0];
        
        NSDate *date2 = [formatter dateFromString:item2.messageTime];
        
        NSTimeInterval interval2 = [date2 timeIntervalSince1970];
        
        NSDate *currentDate = [formatter dateFromString:item.messageTime];
        
        NSTimeInterval currentInterval = [currentDate timeIntervalSince1970];
        
        if (currentInterval > interval2) { // 这个消息的收到时间  大于  这里的一条消息时间
            
            if ((currentInterval - interval2) < - 5 * 60) {
                item.isShowTime = YES;
            } else {
                item.isShowTime = NO;
            }
            
//            dispatch_async(queue, ^{
//                @synchronized(self.reloadTable) {
                    [[self.reloadTable mutableArrayValueForKey:@"messages"] addObject:item];
//                }
//            });
            
        } else { // 小于那条消息的时间  插入到第0个
            if ((currentInterval - interval2) < - 5 * 60) {
                item.isShowTime = YES;
            } else {
                item.isShowTime = NO;
            }
            
//            dispatch_async(queue, ^{
//                @synchronized(self.reloadTable) {
                    [[self.reloadTable mutableArrayValueForKey:@"messages"] insertObject:item atIndex:0];
//                }
//            });
            
        }
        
    }  else { // 这种情况是当前有两条以上数据
        
        NSInteger count = [self.reloadTable mutableArrayValueForKey:@"messages"].count;
        
        NSInteger index = 0;
        
        for (int i = 0; i < count - 1; i++) {// 从最小的时间开始遍历
            
            IMBaseItem *item1 = [self.reloadTable mutableArrayValueForKey:@"messages"][i];
            
            NSDate *date1 = [formatter dateFromString:item1.messageTime];
            
            NSTimeInterval interval1 = [date1 timeIntervalSince1970]; // 第一个距离1970的时间戳
            
            IMBaseItem *item2 = [self.reloadTable mutableArrayValueForKey:@"messages"][i + 1];
            
            NSDate *date2 = [formatter dateFromString:item2.messageTime];
            
            NSTimeInterval interval2 = [date2 timeIntervalSince1970]; // 第二个距离1970的时间戳
            
            NSDate *currentDate = [formatter dateFromString:item.messageTime];
            
            NSTimeInterval currentInterval = [currentDate timeIntervalSince1970]; // 要插入进来这个距离1970的时间戳
            
            if (i == 0) {
                
                if (currentInterval <= interval1) { // 如果时间小于第一个  他就是最小的  直接插入到第0个
                    if ((interval1 - currentInterval) > 5 * 60) {
                        item.isShowTime = YES;
                    }
                    
                    index = i;
                    
                    item.scrollToIndex = self.scrollToIndex;
                    
//                    dispatch_async(queue, ^{
//                        @synchronized(self.reloadTable) {
                            [[self.reloadTable mutableArrayValueForKey:@"messages"] insertObject:item atIndex:i];
                            
//                        }
//                    });
                    
                    break;
                }
            }
            
            if (currentInterval > interval1 && currentInterval <= interval2) { // 当前的这个时间在大于第一个时间  小于第二个时间
                if ((currentInterval - interval1) > 5 * 60) {
                    item.isShowTime = YES;
                }
                index = i + 1;
                
                item.scrollToIndex = self.scrollToIndex;
                
//                dispatch_async(queue, ^{
//                    @synchronized(self.reloadTable) {
                        [[self.reloadTable mutableArrayValueForKey:@"messages"] insertObject:item atIndex:index];
                        
//                    }
//                });
                
                break;
            }
            
            if (i == count - 2) {
                
                if ((currentInterval - interval2) > 5 * 60) {
                    item.isShowTime = YES;
                } else {
                    item.isShowTime = NO;
                }
                
                item.scrollToIndex = self.scrollToIndex;
                
//                dispatch_async(queue, ^{
//                    @synchronized(self.reloadTable) {
                        [[self.reloadTable mutableArrayValueForKey:@"messages"] addObject:item];
                        
//                    }
//                });
                
            } else {
                
                if (currentInterval > interval2) {
                    continue;
                }
            }
            
        }
        
    }
    

}

#pragma mark - 处理追加消息
- (void)addItemTableViewUpdata:(IMBaseItem *)item{
    
    // 一下是从最大往小  追加
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    
    formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    
    if ([self.reloadTable mutableArrayValueForKey:@"messages"].count == 0){ // 第一条  还是直接插入即可
    
        
//        dispatch_async(queue, ^{
//            @synchronized(self.reloadTable) {
                [[self.reloadTable mutableArrayValueForKey:@"messages"] addObject:item];
                
//            }
//        });
        
    } else if ([self.reloadTable mutableArrayValueForKey:@"messages"].count == 1) { // 第二条也是一样的
        
        IMBaseItem *item2 = [self.reloadTable mutableArrayValueForKey:@"messages"][0];
        
        NSDate *date2 = [formatter dateFromString:item2.messageTime];
        
        NSTimeInterval interval2 = [date2 timeIntervalSince1970];
        
        NSDate *currentDate = [formatter dateFromString:item.messageTime];
        
        NSTimeInterval currentInterval = [currentDate timeIntervalSince1970];
        
        if (currentInterval >= interval2) { // 这个消息的收到时间  大于  这里的一条消息时间
            
            if ((currentInterval - interval2) > 5 * 60) {
                item.isShowTime = YES;
            } else {
                item.isShowTime = NO;
            }
            
//            dispatch_async(queue, ^{
//                @synchronized(self.reloadTable) {
                    [[self.reloadTable mutableArrayValueForKey:@"messages"] addObject:item];
                    
//                }
//            });
            
        } else { // 小于那条消息的时间  插入到第0个
            
            if ((currentInterval - interval2) < - 5 * 60) {
                item.isShowTime = YES;
            } else {
                item.isShowTime = NO;
            }
            
//            dispatch_async(queue, ^{
//                @synchronized(self.reloadTable) {
                    [[self.reloadTable mutableArrayValueForKey:@"messages"] insertObject:item atIndex:0];
                    
//                }
//            });
            
        }
        
    }  else {
        
        NSInteger count = [self.reloadTable mutableArrayValueForKey:@"messages"].count;
        
        NSInteger index = [self.reloadTable mutableArrayValueForKey:@"messages"].count - 1;
        
        for (int i = (int)count - 1; i > 0; i--) {
            
            IMBaseItem *item1 = [self.reloadTable mutableArrayValueForKey:@"messages"][i];
            
            NSDate *date1 = [formatter dateFromString:item1.messageTime];
            
            NSTimeInterval interval1 = [date1 timeIntervalSince1970];
            
            IMBaseItem *item2 = [self.reloadTable mutableArrayValueForKey:@"messages"][i - 1];
            
            NSDate *date2 = [formatter dateFromString:item2.messageTime];
            
            NSTimeInterval interval2 = [date2 timeIntervalSince1970];
            
            NSDate *currentDate = [formatter dateFromString:item.messageTime];
            
            NSTimeInterval currentInterval = [currentDate timeIntervalSince1970];
            
            if (i == count - 1){ // 先和最后一条比 如果时间大于这个时间就加入到最后去
                if (currentInterval >= interval1) {
                    if ((interval1 - currentInterval) < - 5 * 60) {
                        item.isShowTime = YES;
                    }
                    
//                    dispatch_async(queue, ^{
//                        @synchronized(self.reloadTable) {
                            [[self.reloadTable mutableArrayValueForKey:@"messages"] addObject:item];
                            
//                        }
//                    });
                    
                    break;
                }
            }
            
            if (currentInterval > interval2 && currentInterval < interval1) { // 小于第一条 大于第二条
                if ((currentInterval - interval1) < - 5 * 60) {
                    item.isShowTime = YES;
                }
                
                index = i;
                
//                dispatch_async(queue, ^{
//                    @synchronized(self.reloadTable) {
                        [[self.reloadTable mutableArrayValueForKey:@"messages"] insertObject:item atIndex:index];
                        
//                    }
//                });
            
                break;
            }
            
            if (i == 1){
                
                if ((currentInterval - interval2) < - 5 * 60) {
                    item.isShowTime = YES;
                } else {
                    item.isShowTime = NO;
                }
                
//                dispatch_async(queue, ^{
//                    @synchronized(self.reloadTable) {
                        [[self.reloadTable mutableArrayValueForKey:@"messages"] insertObject:item atIndex:0];
                        
//                    }
//                });
                
                break;
            } else {
                continue;
            }
            
        }
        
    }
    
}

- (BOOL)isLeftWithIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

- (NSInteger)isHaveMessage:(IMBaseItem *)message{
    
    __block NSInteger index = -1;
    
    [[self.reloadTable mutableArrayValueForKey:@"messages"] enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[IMBaseItem class]]) {
            IMBaseItem *item = obj;
            if ([item.chatMessageIdentifier isEqualToString:message.chatMessageIdentifier]) {
                index = idx;
            }
        }
    }];
    
    return index;
}

- (IMRealodTableTool *)reloadTable{
    
    if (_reloadTable == nil) {
        
        NSDictionary *dic = [NSDictionary dictionaryWithObject:[NSMutableArray arrayWithCapacity:0] forKey:@"messages"];
        
        _reloadTable = [[IMRealodTableTool alloc] initWithDic:dic];
        
    }
    return _reloadTable;
}

- (IMChatToolBar *)chatToolBar{
    
    if (_chatToolBar == nil) {
        
        IMChatToolBar *toolBar = [[IMChatToolBar alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT - SchoolChatToolBarHeight, SCREEN_WIDTH, SchoolChatToolBarHeight + SchoolChatMoreHeight) toolBarHeight:SchoolChatToolBarHeight moreViewHeight:SchoolChatMoreHeight];
        
        toolBar.delegate = self;
        
        [self.view addSubview:toolBar];
        
        _chatToolBar = toolBar;
    }
    return _chatToolBar;
}

- (void)dealloc{
    [self.reloadTable removeObserver:self forKeyPath:@"messages"];
}

@end

@implementation IMRealodTableTool

-(id)initWithDic:(NSDictionary *)dic
{
    self = [super init];
    if (self) {
        [self setValuesForKeysWithDictionary:dic];
    }
    
    return self;
}

-(void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    NSLog(@"undefine key ---%@",key);
}

@end

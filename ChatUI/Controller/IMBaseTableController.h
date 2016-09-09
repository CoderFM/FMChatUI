//
//  IMTableViewController.h
//  qygt
//
//  Created by 周发明 on 16/8/4.
//  Copyright © 2016年 途购. All rights reserved.
//

#import <UIKit/UIKit.h>

@class IMBaseTableController, IMBaseItem;

@protocol IMBaseTableControllerDelefate <NSObject>

- (void)tableViewScroll:(IMBaseTableController *)baseController;

- (void)baseTableController:(IMBaseTableController *)tableController sendMessage:(IMBaseItem *)message;

@end

@class IMBaseItem, IMRealodTableTool;

@interface IMBaseTableController : UIViewController

@property(nonatomic, weak)UITableView *tableView;

@property(nonatomic, strong)IMRealodTableTool *reloadTable;

@property(nonatomic, copy)NSString *lastMessageId;

@property(nonatomic, copy)NSString *lastMessageTime;

@property(nonatomic, assign)NSInteger scrollToIndex;

@property(nonatomic, assign)BOOL isScrollToBottom;

- (void)loadData;

- (void)loadMoreData;

- (void)scrollToBottom;

- (void)reloadDataWithMessage:(IMBaseItem *)messageItem isInser:(BOOL)isInser;

- (void)handleServerData:(NSArray *)messages isInser:(BOOL)isInser;

- (BOOL)isLeftWithIndexPath:(NSIndexPath *)indexPath;

@property(nonatomic, weak)id<IMBaseTableControllerDelefate> imBaseDelegate;

@end

@interface IMRealodTableTool : NSObject

@property(nonatomic, strong)NSMutableArray *messages;

-(id)initWithDic:(NSDictionary *)dic;

@end

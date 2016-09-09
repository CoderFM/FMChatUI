//
//  ViewController.m
//  FMChatDemo
//
//  Created by 周发明 on 16/9/9.
//  Copyright © 2016年 周发明. All rights reserved.
//

#import "ViewController.h"
#import "IMBaseTableController.h"
#import "IMBaseAttribute.h"
#import "IMSQLiteTool.h"


@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)btnClick:(id)sender {
    [IMSQLiteTool openSQLiteWithPartInteger:10];
    [IMBaseAttribute shareIMBaseAttribute].part = 10;
    [IMBaseAttribute shareIMBaseAttribute].reciverID = @"10";
    [self.navigationController pushViewController:[[IMBaseTableController alloc] init] animated:YES];
}

@end

//
//  ViewController.m
//  GCAsyncDisplayDemo
//
//  Created by 宫城 on 16/7/9.
//  Copyright © 2016年 宫城. All rights reserved.
//

#import "ViewController.h"
#import "GCTextCell.h"
#import "GCMessageModel.h"
#import "GCBubbleLayout.h"

@interface ViewController ()

@property (nonatomic, strong) NSMutableArray *dataSouce;
@property (nonatomic, strong) NSMutableArray *layoutArray;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerClass:[GCTextCell class] forCellReuseIdentifier:GCTextCellIdentifier];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSLog(@"%@",[NSDate dateWithTimeIntervalSinceNow:0]);
        self.dataSouce = [NSMutableArray array];
        for (NSInteger i = 0; i < 100; i++) {
            GCMessageModel *message = [[GCMessageModel alloc] init];
            message.isSelf = NO;
            message.msgType = GCTypeText;
            // core text
            message.content = [NSString stringWithFormat:@"%ld http://www.baidu.com ✺◟(∗❛ัᴗ❛ั∗)◞✺ ✺◟(∗❛ัᴗ❛ั∗)◞✺ 😀😖😐😣😡🚖🚌🚋🎊💖💗💛💙🏨🏦🏫 [微笑] ✺◟(∗❛ัᴗ❛ั)◞✺ 😀😖😐😣😡🚖🚌🚋🎊💖💗💛💙🏨🏦🏫",(long)i];
            
            [self.dataSouce addObject:message];
        }
        NSLog(@"%@",[NSDate dateWithTimeIntervalSinceNow:0]);
        self.layoutArray = [NSMutableArray array];
        for (GCMessageModel *message in self.dataSouce) {
            GCBubbleLayout *bubbleLayout = [GCBubbleLayout bubbleLayoutWithMessage:message];
            [self.layoutArray addObject:bubbleLayout];
        }
        NSLog(@"%@",[NSDate dateWithTimeIntervalSinceNow:0]);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    });
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.layoutArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return ((GCBubbleLayout *)self.layoutArray[indexPath.row]).height+21*2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    GCMessageModel *message = self.dataSouce[indexPath.row];
    GCBubbleLayout *bubbleLayout = self.layoutArray[indexPath.row];
    if ([message.msgType isEqualToString:GCTypeText]) {
        GCTextCell *cell = [tableView dequeueReusableCellWithIdentifier:GCTextCellIdentifier forIndexPath:indexPath];
        [cell setLayout:bubbleLayout];
        return cell;
    }
    
    return nil;
}

@end

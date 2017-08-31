//
//  ViewController.m
//  TBTopWindow
//
//  Created by hanchuangkeji on 2017/8/31.
//  Copyright © 2017年 hanchuangkeji. All rights reserved.
//

#import "ViewController.h"
#import "UITableView+FOF.h"


@interface ViewController ()

@property (nonatomic, strong) NSMutableArray<NSString *> *dataSource;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupBasic];
    
    [self loadNewData];
}

- (void)setupBasic {
    
    __weak typeof (self) weakSelf = self;
    self.tableView.tbHeader = [TBHeader headerWithRefreshBlock:^{
        [weakSelf loadNewData];
    }];
    
    self.tableView.tbFooter = [TBFooter footerWithRefreshTarget:self reFreshingAction:@selector(loadMoreData)];
    
}


#pragma mark <UITableViewDelegate>

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([UITableViewCell class])];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NSStringFromClass([UITableViewCell class])];
    }
    cell.textLabel.text = self.dataSource[indexPath.row];
    return cell;
}

#pragma mark 加载数据
- (void)loadNewData {
    
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.tableView.tbHeader headerEndRefresh];
        
        // 添加数据
        self.dataSource = [NSMutableArray array];
        for (int i = 0; i < 20; i++) {
            //            int aa = arc4random() % 100;
            int aa = i;
            [self.dataSource addObject:[NSString stringWithFormat:@"%d", aa]];
        }
        
        [self.tableView reloadData];
        
    });
}


- (void)loadMoreData {
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.tableView.tbFooter footerEndRefresh];
        
        // 添加数据
        for (int i = 0; i < 10; i++) {
            //                        int aa = arc4random() % 100;
            int aa = [[self.dataSource lastObject] intValue] + 1;
            [self.dataSource addObject:[NSString stringWithFormat:@"%d", aa]];
        }
        
        [self.tableView reloadData];
        
    });
}

@end

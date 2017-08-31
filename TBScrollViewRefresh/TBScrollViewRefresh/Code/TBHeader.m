//
//  TBHeader.m
//  com.pintu.aaaaaa
//
//  Created by hanchuangkeji on 2017/8/10.
//  Copyright © 2017年 hanchuangkeji. All rights reserved.
//

#import "TBHeader.h"
#import "UIView+FOFExtension.h"

#define refreshHeaderHeight 20.0
#define pullToRefreshHeight 50.0

@interface TBHeader()

@property (nonatomic, weak)id target;

@property (nonatomic, assign)SEL selector;

@property (nonatomic, assign)BOOL isFreshing;

@property (nonatomic, weak)UIView *NewheaderViewTemp;

@property (nonatomic, weak)UIView *NewFooterViewTemp;

@property (nonatomic, copy)void(^refreshBlock)();

@property (nonatomic, weak)UILabel *headerLabel;

@property (nonatomic, weak)UIButton *headerBtnView;



@end

@implementation TBHeader

+ (instancetype)headerWithRefreshTarget:(id)target reFreshingAction:(SEL)action {
    
    TBHeader *tempHeader = [[self alloc] init];
    [tempHeader setTargetAndSelector:target selector:action];
//    self perform
    return tempHeader;
}

+ (instancetype)headerWithRefreshBlock: (void(^)()) refreshBlock{
    TBHeader *tempHeader = [[TBHeader alloc] init];
    [tempHeader setRefreshBlock:refreshBlock];
    return tempHeader;
}

- (void)setRefreshBlock: (void(^)()) refreshBlock{
    _refreshBlock = refreshBlock;
}

- (void)setTargetAndSelector:(id)target selector:(SEL)selector {
    _target = target;
    _selector = selector;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if (object == self.tableView && [keyPath isEqualToString:@"tableHeaderView"]) {
//        [self addRefreshHeader2];
    }else if (object == self.tableView && [keyPath isEqualToString:@"contentSize"]) {
        NSLog(@"contentSize %@", NSStringFromCGPoint([change[@"new"] CGPointValue]));
    }else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}


- (void)replaceNewHeader {
    
    if (self.NewheaderViewTemp != self.tableView.tableHeaderView || !self.NewheaderViewTemp) {
        UIView *NewheaderViewTemp = [[UIView alloc] init];
        NewheaderViewTemp.backgroundColor = [UIColor colorWithWhite:0.5 alpha:1.0];
        self.NewheaderViewTemp = NewheaderViewTemp;
        
        UIView *headerViewOriginal = self.tableView.tableHeaderView;
        NSLog(@"%@", headerViewOriginal);
        self.tableView.tableHeaderView = nil;
        
        
        UIButton *headerBtnView = [UIButton buttonWithType:UIButtonTypeCustom];
        headerBtnView.backgroundColor = [UIColor purpleColor];
        headerBtnView.titleLabel.textAlignment = NSTextAlignmentCenter;
        [headerBtnView setTitle:@"下拉刷新" forState:UIControlStateNormal];
        [headerBtnView addTarget:self action:@selector(headerBeginRefresh) forControlEvents:UIControlEventTouchUpInside];
        self.headerBtnView = headerBtnView;
        headerBtnView.frame = CGRectMake(0, 0, self.tableView.width, refreshHeaderHeight);
        headerViewOriginal.y = headerBtnView.height;
        [NewheaderViewTemp addSubview:headerBtnView];
        //    [headerViewOriginal removeFromSuperview];
        NewheaderViewTemp.height = headerViewOriginal.height + headerBtnView.height;
        [NewheaderViewTemp addSubview:headerViewOriginal];
        self.tableView.tableHeaderView = NewheaderViewTemp;
        
        // 重新设置inset
        [self.tableView setContentInset:UIEdgeInsetsMake(self.tableView.contentInset.top - headerBtnView.height, 0, self.tableView.contentInset.bottom, 0)];
    }
}



//- viewHeader

/**
 回去View的Controller

 @param sourceView 目标View
 @return Controller实例
 */
- (UIViewController *)findViewController:(UIView *)sourceView
{
    id target = sourceView;
    while (target) {
        target = ((UIResponder *)target).nextResponder;
        if ([target isKindOfClass:[UIViewController class]]) {
            break;
        }
    }
    return target;
}

- (void)setTableView:(UITableView *)tableView {
//    tableView.delegate = self;
    _tableView = tableView;
    // 设置监听
    [self.tableView addObserver:self forKeyPath:@"tableHeaderView" options:NSKeyValueObservingOptionNew context:@"TBHeader"];
    
    [self.tableView addObserver:self forKeyPath:@"dragging" options:NSKeyValueObservingOptionNew context:@"TBHeader"];
    
    // 寻找controller
    self.vc = [self findViewController:tableView];
}



- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    
    // 下拉伸进入刷新模式
    if (scrollView.contentOffset.y < -scrollView.contentInset.top - pullToRefreshHeight && !self.isFreshing) {
        
        // 开启刷新
        [self headerBeginRefresh];
        
        
        // 正在刷新
        dispatch_async(dispatch_get_main_queue(), ^{
            //  NSLog(@"*****禁止惯性滚动*************Start reFresh**************************");
            
            [scrollView setContentOffset:CGPointMake(scrollView.contentOffset.x, -scrollView.contentInset.top - refreshHeaderHeight) animated:YES];
        });
        
    }
    // 解决下拉正在刷新
    else if(scrollView.contentOffset.y < - scrollView.contentInset.top - pullToRefreshHeight && self.isFreshing){
        // 正在刷新
        dispatch_async(dispatch_get_main_queue(), ^{
            //  NSLog(@"*****禁止惯性滚动*************Start reFresh**************************");
            
            [scrollView setContentOffset:CGPointMake(scrollView.contentOffset.x, -scrollView.contentInset.top - refreshHeaderHeight) animated:YES];
        });
    }

    // 上拉刷新
    else if (self.tableView.contentOffset.y + [UIScreen mainScreen].bounds.size.height >= self.tableView.contentSize.height + pullToRefreshHeight) {
        
    }
    
    NSLog(@"%@", NSStringFromCGPoint(self.tableView.contentOffset));
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    
    [self replaceNewHeader];
    NSLog(@"%s", __func__);
    
}

- (void)headerBeginRefresh {
    NSLog(@"******************Start reFresh**************************");
    self.isFreshing = YES;
    self.headerLabel.text = @"刷新中...";
    
    if (self.target && self.selector && [self.target respondsToSelector:self.selector]) {
        [self.target performSelector:self.selector];
        //            self.target setSelector:self.
    }else if (self.refreshBlock) {
        self.refreshBlock();
    }
    
    // 更改Label的刷新状态
    self.headerBtnView.enabled = NO;
    [self.headerBtnView setTitle:@"刷新中..." forState:UIControlStateNormal];
}



- (void)headerEndRefresh {
    self.isFreshing = NO;
    self.headerBtnView.enabled = YES;
    [self.headerBtnView setTitle:@"下拉刷新" forState:UIControlStateNormal];
    
    // 调整contentOffset
    dispatch_async(dispatch_get_main_queue(), ^{
        //  NSLog(@"*****禁止惯性滚动*************Start reFresh**************************");
        
        // 往上移动不再调整用户的contentOffset
        if (self.tableView.contentOffset.y > -self.tableView.contentInset.top) return;
        
        [self.tableView setContentOffset:CGPointMake(self.tableView.contentOffset.x, -self.tableView.contentInset.top) animated:YES];
    });
}

@end

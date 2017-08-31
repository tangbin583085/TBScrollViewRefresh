//
//  TBFooter.m
//  com.pintu.aaaaaa
//
//  Created by hanchuangkeji on 2017/8/10.
//  Copyright © 2017年 hanchuangkeji. All rights reserved.
//

#import "TBFooter.h"
#import "UIView+FOFExtension.h"

#define refreshFooterHeight 20.0
#define pullToRefreshHeight 50.0

@interface TBFooter()

@property (nonatomic, weak)id target;

@property (nonatomic, assign)SEL selector;

@property (nonatomic, assign)BOOL isFreshing;

@property (nonatomic, weak)UIView *NewFooterViewTemp;

@property (nonatomic, copy)void(^refreshBlock)();

@property (nonatomic, weak)UIButton *footerBtnView;

@end

@implementation TBFooter


+ (instancetype)footerWithRefreshTarget:(id)target reFreshingAction:(SEL)action {
    
    TBFooter *tempFooter = [[self alloc] init];
    [tempFooter setTargetAndSelector:target selector:action];
    
    return tempFooter;
}

+ (instancetype)footerWithRefreshBlock: (void(^)()) refreshBlock{
    TBFooter *tempFooter = [[TBFooter alloc] init];
    [tempFooter setRefreshBlock:refreshBlock];
    return tempFooter;
}

- (void)setRefreshBlock: (void(^)()) refreshBlock{
    _refreshBlock = refreshBlock;
}

- (void)setTargetAndSelector:(id)target selector:(SEL)selector {
    _target = target;
    _selector = selector;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if (object == self.tableView && [keyPath isEqualToString:@"tableFooterView"]) {
//        [self addRefreshFooter2];
    }else if (object == self.tableView && [keyPath isEqualToString:@"contentSize"]) {
        NSLog(@"contentSize %@", NSStringFromCGPoint([change[@"new"] CGPointValue]));
    }else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)replaceNewFooter {
    
    if (self.NewFooterViewTemp != self.tableView.tableFooterView || !self.NewFooterViewTemp) {
        UIView *NewFooterViewTemp = [[UIView alloc] init];
        NewFooterViewTemp.backgroundColor = [UIColor colorWithWhite:0.5 alpha:1.0];
        self.NewFooterViewTemp = NewFooterViewTemp;
        
        UIView *footerViewOriginal = self.tableView.tableFooterView;
        NSLog(@"%@", footerViewOriginal);
        self.tableView.tableFooterView = nil;
        
        UIButton *footerBtnView = [UIButton buttonWithType:UIButtonTypeCustom];
        footerBtnView.backgroundColor = [UIColor purpleColor];
        footerBtnView.titleLabel.textAlignment = NSTextAlignmentCenter;
        [footerBtnView setTitle:@"上拉或点击加载更多" forState:UIControlStateNormal];
        [footerBtnView addTarget:self action:@selector(footerBeginRefresh) forControlEvents:UIControlEventTouchUpInside];
        self.footerBtnView = footerBtnView;
        footerBtnView.frame = CGRectMake(0, 0, self.tableView.width, refreshFooterHeight);
        footerViewOriginal.y = footerBtnView.height;
        [NewFooterViewTemp addSubview:footerBtnView];
        //    [footerViewOriginal removeFromSuperview];
        NewFooterViewTemp.height = footerViewOriginal.height + footerBtnView.height;
        [NewFooterViewTemp addSubview:footerViewOriginal];
        self.tableView.tableFooterView = NewFooterViewTemp;
        NSLog(@"%f %f", self.tableView.contentInset.bottom, NewFooterViewTemp.height);
        // 重新设置inset
        [self.tableView setContentInset:UIEdgeInsetsMake(self.tableView.contentInset.top, 0, self.tableView.contentInset.bottom, 0)];
        
        
    }
}


//- viewFooter

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

    _tableView = tableView;
    // 设置监听
    [self.tableView addObserver:self forKeyPath:@"tableFooterView" options:NSKeyValueObservingOptionNew context:@"TBFooter"];
    
    [self.tableView addObserver:self forKeyPath:@"dragging" options:NSKeyValueObservingOptionNew context:@"TBFooter"];
    
    // 寻找controller
    self.vc = [self findViewController:tableView];
}



- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    // 上拉刷新
    if (self.tableView.contentOffset.y + self.tableView.height - self.tableView.contentInset.bottom >= self.tableView.contentSize.height + pullToRefreshHeight && !self.isFreshing) {
        
        [self footerBeginRefresh];
    }
    
    NSLog(@"%@", NSStringFromCGPoint(self.tableView.contentOffset));
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self replaceNewFooter];
    
    NSLog(@"%s", __func__);
}

- (void)footerBeginRefresh {
    
    NSLog(@"******************Start reFresh**************************");
    self.isFreshing = YES;
    
    if (self.target && self.selector && [self.target respondsToSelector:self.selector]) {
        [self.target performSelector:self.selector];
    }else if (self.refreshBlock) {
        self.refreshBlock();
    }
    
    // 更改btn的刷新状态
    self.footerBtnView.enabled = NO;
    [self.footerBtnView setTitle:@"加载中..." forState:UIControlStateNormal];
}


- (void)footerEndRefresh {
    self.isFreshing = NO;
    self.footerBtnView.enabled = YES;
    [self.footerBtnView setTitle:@"上拉或点击加载更多" forState:UIControlStateNormal];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
    });
}

@end

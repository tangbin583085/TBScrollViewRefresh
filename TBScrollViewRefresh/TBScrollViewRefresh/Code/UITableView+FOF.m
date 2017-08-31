
//
//  UITableView+FOF.m
//  com.pintu.aaaaaa
//
//  Created by hanchuangkeji on 2017/8/10.
//  Copyright © 2017年 hanchuangkeji. All rights reserved.
//

#import "UITableView+FOF.h"
#import "TBFooter.h"

@implementation UITableView (FOF)

__strong TBHeader *_tbHeader;

__strong TBFooter *_tbFooter;

__weak UIViewController *_viewController;

- (TBHeader *)tbHeader {
    return _tbHeader;
}

- (void)setTbHeader:(TBHeader *)tbHeader {
    
    // 设置对象
    tbHeader.tableView = self;
    _tbHeader = tbHeader;
    
    // 设置代理
    self.delegate = self;
    
    // 设置VC
    _viewController = [self findViewController:self];
}


- (TBFooter *)tbFooter {
    return _tbFooter;
}

- (void)setTbFooter:(TBFooter *)tbFooter {
    
    // 设置对象
    tbFooter.tableView = self;
    _tbFooter = tbFooter;
    
    // 设置代理
    self.delegate = self;
    
    // 设置VC
    _viewController = [self findViewController:self];
}

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

#pragma mark <UIScrollViewDelegate>

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    NSLog(@"%s", __func__);
    
    // 执行头部代理
    if ([_tbHeader respondsToSelector:@selector(scrollViewWillBeginDragging:)]) {
        [_tbHeader scrollViewWillBeginDragging:scrollView];
    }
    
    // 执行尾部代理
    if ([_tbFooter respondsToSelector:@selector(scrollViewWillBeginDragging:)]) {
        [_tbFooter scrollViewWillBeginDragging:scrollView];
    }
    
    // 执行vc代理
    if ([_viewController respondsToSelector:@selector(scrollViewWillBeginDragging:)]) {
        [(UITableViewController *)_viewController scrollViewWillBeginDragging:scrollView];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    
    // 执行头部代理
    if ([_tbHeader respondsToSelector:@selector(scrollViewDidEndDragging:willDecelerate:)]) {
        [_tbHeader scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
    }
    
    // 执行尾部代理
    if ([_tbFooter respondsToSelector:@selector(scrollViewDidEndDragging:willDecelerate:)]) {
        [_tbFooter scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
    }
    
    // 执行vc代理
    if ([_viewController respondsToSelector:@selector(scrollViewDidEndDragging:willDecelerate:)]) {
        [(UITableViewController *)_viewController scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
    }
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([_viewController respondsToSelector:@selector(tableView:didSelectRowAtIndexPath:)]) {
        [((UITableViewController *)_viewController) tableView:tableView didSelectRowAtIndexPath:indexPath];
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([_viewController respondsToSelector:@selector(tableView:heightForRowAtIndexPath:)]) {
        return [((UITableViewController *)_viewController) tableView:tableView heightForRowAtIndexPath:indexPath];
    }else {
        return 44.0;
    }
}

// 需要实现全部代理

@end

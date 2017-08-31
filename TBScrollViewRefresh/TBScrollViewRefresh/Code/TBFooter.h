//
//  TBHeader.h
//  com.pintu.aaaaaa
//
//  Created by hanchuangkeji on 2017/8/10.
//  Copyright © 2017年 hanchuangkeji. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface TBFooter : NSObject<UITableViewDelegate>


@property (nonatomic, weak) UIViewController *vc;

@property (nonatomic, weak)UITableView *tableView;


+ (instancetype)footerWithRefreshTarget:(id)target reFreshingAction:(SEL)action;

+ (instancetype)footerWithRefreshBlock: (void(^)()) refreshBlock;

- (void)footerEndRefresh;


@end

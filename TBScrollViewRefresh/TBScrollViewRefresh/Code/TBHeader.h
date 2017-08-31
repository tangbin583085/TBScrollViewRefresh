//
//  TBHeader.h
//  com.pintu.aaaaaa
//
//  Created by hanchuangkeji on 2017/8/10.
//  Copyright © 2017年 hanchuangkeji. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface TBHeader : NSObject<UITableViewDelegate>


@property (nonatomic, weak) UIViewController *vc;

@property (nonatomic, weak)UITableView *tableView;


+ (instancetype)headerWithRefreshTarget:(id)target reFreshingAction:(SEL)action;

+ (instancetype)headerWithRefreshBlock: (void(^)()) refreshBlock;

- (void)headerEndRefresh;

@end

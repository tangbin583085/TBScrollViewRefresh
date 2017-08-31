//
//  UITableView+FOF.h
//  com.pintu.aaaaaa
//
//  Created by hanchuangkeji on 2017/8/10.
//  Copyright © 2017年 hanchuangkeji. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TBHeader.h"
#import "TBFooter.h"

@interface UITableView (FOF)<UITableViewDelegate>

// 头部
- (void)setTbHeader:(TBHeader *)tbHeader;
- (TBHeader *)tbHeader;

// 尾部
- (TBFooter *)tbFooter;
- (void)setTbFooter:(TBFooter *)tbFooter;

@end

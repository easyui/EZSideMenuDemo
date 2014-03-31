//
//  EZRightMenuViewController.h
//  EZSideMenuDemo
//
//  Created by NeuLion SH on 14-3-26.
//  Copyright (c) 2014年 cactus. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EZRightMenuViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *menuTableview;

@property (strong, nonatomic) NSDictionary *menuDic;
@end

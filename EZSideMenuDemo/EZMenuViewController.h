//
//  EZMenuViewController.h
//  EZSideMenuDemo
//
//  Created by EZ on 13-11-19.
//  Copyright (c) 2013年 cactus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EZSideMenu.h"
@interface EZMenuViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *menuTableview;
@property (strong, nonatomic) NSDictionary *menuDic;
@end

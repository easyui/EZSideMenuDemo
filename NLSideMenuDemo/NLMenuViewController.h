//
//  NLMenuViewController.h
//  EZSideMenuDemo
//
//  Created by NeuLion SH on 13-11-24.
//  Copyright (c) 2013年 cactus. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NLMenuViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) NSMutableArray *squareArr;
@property (strong, nonatomic) NSMutableDictionary *menuDic;

@property (weak, nonatomic) IBOutlet UIView *titleView;
@property (weak, nonatomic) IBOutlet UIView *squareView;
@property (weak, nonatomic) IBOutlet UITableView *squareTableView;
@property (weak, nonatomic) IBOutlet UIView *menuView;
@property (weak, nonatomic) IBOutlet UITableView *menuTableView;

- (void)drawMenu;
@end

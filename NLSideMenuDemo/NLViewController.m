//
//  NLViewController.m
//  NLSideMenuDemo
//
//  Created by NeuLion SH on 13-11-24.
//  Copyright (c) 2013年 cactus. All rights reserved.
//

#import "NLViewController.h"
#import "EZSideMenu.h"

@interface NLViewController ()

@end

@implementation NLViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"First Controller";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Menu"
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(showMenu)];
}


- (void)showMenu
{
    [self.sideMenuViewController presentMenuViewController];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end

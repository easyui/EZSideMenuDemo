//
//  DEMORootViewController.m
//  EZSideMenuDemo
//
//  Created by yangjun zhu on 15/8/25.
//  Copyright (c) 2015年 Cactus. All rights reserved.
//

#import "DemoRootViewController.h"

@interface DemoRootViewController ()

@end

@implementation DemoRootViewController

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.menuPreferredStatusBarStyle = UIStatusBarStyleLightContent;
    self.contentViewShadowColor = [UIColor blackColor];
    self.contentViewShadowOffset = CGSizeMake(0, 0);
    self.contentViewShadowOpacity = 0.6;
    self.contentViewShadowRadius = 12;
    self.contentViewShadowEnabled = YES;
    
    //    self.contentViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"TRZEatAlarmViewControllerPhoneStoryboardID"];
    //    self.leftMenuViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"TRZMainMenuViewControllerSharedStoryboardID"];
    //    self.rightMenuViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"rightMenuViewController"];
        self.backgroundImage = [UIImage imageNamed:@"menu_bg"];
    self.delegate = self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


#pragma mark - EZSideMenu Delegate

- (void)sideMenu:(EZSideMenu *)sideMenu willShowMenuViewController:(UIViewController *)menuViewController
{
    NSLog(@"willShowMenuViewController: %@", NSStringFromClass([menuViewController class]));
}

- (void)sideMenu:(EZSideMenu *)sideMenu didShowMenuViewController:(UIViewController *)menuViewController
{
    NSLog(@"didShowMenuViewController: %@", NSStringFromClass([menuViewController class]));
}

- (void)sideMenu:(EZSideMenu *)sideMenu willHideMenuViewController:(UIViewController *)menuViewController
{
    NSLog(@"willHideMenuViewController: %@", NSStringFromClass([menuViewController class]));
}

- (void)sideMenu:(EZSideMenu *)sideMenu didHideMenuViewController:(UIViewController *)menuViewController
{
    NSLog(@"didHideMenuViewController: %@", NSStringFromClass([menuViewController class]));
}

@end

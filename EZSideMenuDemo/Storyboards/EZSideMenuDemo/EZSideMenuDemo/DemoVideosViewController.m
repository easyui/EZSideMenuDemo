//
//  DemoVideosViewController.m
//  EZSideMenuDemo
//
//  Created by yangjun zhu on 15/8/25.
//  Copyright (c) 2015年 Cactus. All rights reserved.
//

#import "DemoVideosViewController.h"

@interface DemoVideosViewController ()

@end

@implementation DemoVideosViewController

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
- (IBAction)pushButtonAction:(UIButton *)sender {
    UIViewController *viewController = [[UIViewController alloc] init];
    viewController.title = @"Pushed Controller";
    viewController.view.backgroundColor = [UIColor whiteColor];
    [self.navigationController pushViewController:viewController animated:YES];
}
- (IBAction)presentButtonAction:(UIButton *)sender {
    UIViewController *viewController = [[UIViewController alloc] init];
    viewController.title = @"Presented Controller";
    viewController.view.backgroundColor = [UIColor whiteColor];
    [self presentViewController:viewController animated:YES completion:^{
        
    }];
}


- (IBAction)unwindSegueToRedViewController:(UIStoryboardSegue *)segue {
    
//    UIViewController *sourceViewController = segue.sourceViewController;
    
//    if ([sourceViewController isKindOfClass:[XXXViewController class]]) {
//        NSLog(@"from XXXViewController vc");
//    }

}

@end

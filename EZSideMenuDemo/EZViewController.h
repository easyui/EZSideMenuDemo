//
//  EZViewController.h
//  EZSideMenuDemo
//
//  Created by NeuLion SH on 13-11-19.
//  Copyright (c) 2013年 cactus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EZSideMenu.h"
@interface EZViewController : UIViewController
@property (weak, nonatomic) IBOutlet UISwitch *panSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *scaleContentViewSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *scaleMenuViewControllerSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *scaleBackgroundImageViewSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *gradientMenuViewControllerSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *onlySlideFromEdgeSwitch;

- (IBAction)switchAction:(UISwitch *)sender;

@property (weak, nonatomic) IBOutlet UITextField *animationDurationTextField;
@property (weak, nonatomic) IBOutlet UITextField *contentViewScaleValueTextField;
@property (weak, nonatomic) IBOutlet UITextField *contentViewInPortraitOffsetCenterXTextField;
@property (weak, nonatomic) IBOutlet UITextField *contentViewInLandscapeOffsetCenterXTextField;
@property (weak, nonatomic) IBOutlet UITextField *menuViewControllerScaleValueTextField;
@property (weak, nonatomic) IBOutlet UITextField *backgroundImageViewScaleValueTextField;
@property (weak, nonatomic) IBOutlet UITextField *slideEdgeValueTextField;

- (IBAction)animationDurationChanged:(UITextField *)sender;





- (IBAction)closeKeyBoard:(id)sender;
@end
/*
@interface UIViewController (IOS6Support)
@end
*/
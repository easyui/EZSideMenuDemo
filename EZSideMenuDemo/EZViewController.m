//
//  EZViewController.m
//  EZSideMenuDemo
//
//  Created by NeuLion SH on 13-11-19.
//  Copyright (c) 2013年 cactus. All rights reserved.
//

#import "EZViewController.h"

@interface EZViewController ()

@end

@implementation EZViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.title = @"First Controller";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Menu"
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(showMenu)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)showMenu
{
    [self.sideMenuViewController presentMenuViewController];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.panSwitch.on = self.sideMenuViewController.panGestureEnabled;
     self.scaleContentViewSwitch.on = self.sideMenuViewController.scaleContentView;
     self.scaleMenuViewControllerSwitch.on = self.sideMenuViewController.scaleMenuViewController;
     self.scaleBackgroundImageViewSwitch.on = self.sideMenuViewController.scaleBackgroundImageView;
    self.gradientViewControllerSwitch.on = self.sideMenuViewController.gradientViewController;
      self.animationDurationTextField.text = [NSString stringWithFormat:@"%f",self.sideMenuViewController.animationDuration];
       self.contentViewScaleValueTextField.text = [NSString stringWithFormat:@"%f",self.sideMenuViewController.contentViewScaleValue];
      self.contentViewInPortraitOffsetCenterXTextField.text = [NSString stringWithFormat:@"%f",self.sideMenuViewController.contentViewInPortraitOffsetCenterX];
      self.contentViewInLandscapeOffsetCenterXTextField.text = [NSString stringWithFormat:@"%f",self.sideMenuViewController.contentViewInLandscapeOffsetCenterX];
     self.menuViewControllerScaleValueTextField.text = [NSString stringWithFormat:@"%f",self.sideMenuViewController.menuViewControllerScaleValue];
     self.backgroundImageViewScaleValueTextField.text = [NSString stringWithFormat:@"%f",self.sideMenuViewController.backgroundImageViewScaleValue];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
}

- (IBAction)switchAction:(UISwitch *)sender {
    if (self.panSwitch == sender) {
        self.sideMenuViewController.panGestureEnabled = self.panSwitch.on;
    }else if (self.scaleContentViewSwitch == sender) {
        self.sideMenuViewController.scaleContentView = self.scaleContentViewSwitch.on;
    }else if (self.scaleMenuViewControllerSwitch == sender) {
        self.sideMenuViewController.scaleMenuViewController = self.scaleMenuViewControllerSwitch.on;
    }else if (self.scaleBackgroundImageViewSwitch == sender) {
        self.sideMenuViewController.scaleBackgroundImageView = self.scaleBackgroundImageViewSwitch.on;
    }else if (self.gradientViewControllerSwitch == sender) {
        self.sideMenuViewController.gradientViewController = self.gradientViewControllerSwitch.on;
        self.sideMenuViewController.menuViewController.view.alpha =1.f;
    }
}
- (IBAction)animationDurationChanged:(UITextField *)sender {
    if (sender == self.animationDurationTextField) {
            self.sideMenuViewController.animationDuration =  [self.animationDurationTextField.text doubleValue];
    }else if (sender == self.contentViewScaleValueTextField) {
        self.sideMenuViewController.contentViewScaleValue =  [self.contentViewScaleValueTextField.text doubleValue];
    }else if (sender == self.contentViewInLandscapeOffsetCenterXTextField) {
        self.sideMenuViewController.contentViewInLandscapeOffsetCenterX =  [self.contentViewInLandscapeOffsetCenterXTextField.text doubleValue];
    }else if (sender == self.contentViewInPortraitOffsetCenterXTextField) {
            self.sideMenuViewController.contentViewInPortraitOffsetCenterX =  [self.contentViewInPortraitOffsetCenterXTextField.text doubleValue];
    }else if (sender == self.menuViewControllerScaleValueTextField) {
        self.sideMenuViewController.menuViewControllerScaleValue =  [self.menuViewControllerScaleValueTextField.text doubleValue];
    }else if (sender == self.backgroundImageViewScaleValueTextField) {
        self.sideMenuViewController.backgroundImageViewScaleValue =  [self.backgroundImageViewScaleValueTextField.text doubleValue];
    }

}

- (IBAction)closeKeyBoard:(id)sender {
    [self.animationDurationTextField resignFirstResponder];
}
@end

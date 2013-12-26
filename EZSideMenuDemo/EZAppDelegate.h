//
//  EZAppDelegate.h
//  EZSideMenuDemo
//
//  Created by EZ on 13-11-19.
//  Copyright (c) 2013年 cactus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EZSideMenu.h"
@class EZViewController;

@interface EZAppDelegate : UIResponder <UIApplicationDelegate,EZSideMenuDelegate>

@property (strong, nonatomic) UIWindow *window;

//@property (strong, nonatomic) EZViewController *viewController;

@end

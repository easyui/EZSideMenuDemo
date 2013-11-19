//
//  EZAppDelegate.m
//  EZSideMenuDemo
//
//  Created by NeuLion SH on 13-11-19.
//  Copyright (c) 2013年 cactus. All rights reserved.
//

#import "EZAppDelegate.h"
#import "EZViewController.h"
#import "EZMenuViewController.h"


@implementation EZAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point d customization after application launch.
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[EZViewController alloc] initWithNibName:@"EZViewController_iPhone" bundle:nil]];
        EZMenuViewController *menuViewController = [[EZMenuViewController alloc] initWithNibName:@"EZMenuViewController" bundle:nil];
        EZSideMenu *sideMenuViewController = [[EZSideMenu alloc] initWithContentViewController:navigationController menuViewController:menuViewController];
        sideMenuViewController.backgroundImage = [UIImage imageNamed:@"Stars"];
        sideMenuViewController.delegate = self;
        self.window.rootViewController = sideMenuViewController;
//        self.window.backgroundColor = [UIColor whiteColor];
        [self.window makeKeyAndVisible];

    } else {

            UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[EZViewController alloc] initWithNibName:@"EZViewController_iPhone" bundle:nil]];
            EZMenuViewController *menuViewController = [[EZMenuViewController alloc] initWithNibName:@"EZMenuViewController" bundle:nil];
            EZSideMenu *sideMenuViewController = [[EZSideMenu alloc] initWithContentViewController:navigationController menuViewController:menuViewController];
            sideMenuViewController.backgroundImage = [UIImage imageNamed:@"Stars"];
            sideMenuViewController.delegate = self;
            self.window.rootViewController = sideMenuViewController;
            //        self.window.backgroundColor = [UIColor whiteColor];
            [self.window makeKeyAndVisible];
     
//        EZViewController *viewController = [[EZViewController alloc] initWithNibName:@"EZViewController_iPad" bundle:nil];
//        self.window.rootViewController = viewController;
//        [self.window makeKeyAndVisible];
    }
  
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


#pragma mark -
#pragma mark EZSideMenu Delegate

- (void)sideMenu:(EZSideMenu *)sideMenu willShowMenuViewController:(UIViewController *)menuViewController
{
    NSLog(@"willShowMenuViewController");
}

- (void)sideMenu:(EZSideMenu *)sideMenu didShowMenuViewController:(UIViewController *)menuViewController
{
    NSLog(@"didShowMenuViewController");
}

- (void)sideMenu:(EZSideMenu *)sideMenu willHideMenuViewController:(UIViewController *)menuViewController
{
    NSLog(@"willHideMenuViewController");
}

- (void)sideMenu:(EZSideMenu *)sideMenu didHideMenuViewController:(UIViewController *)menuViewController
{
    NSLog(@"didHideMenuViewController");
}


@end

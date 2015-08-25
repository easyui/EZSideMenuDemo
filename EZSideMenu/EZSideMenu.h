//
//  EZSideMenu.h
//  EZSideMenuDemo
//
//  Created by yangjun zhu on 15/8/25.
//  Copyright (c) 2015年 Cactus. All rights reserved.
//

#import <UIKit/UIKit.h>
@class EZSideMenu;

@interface UIViewController (EZSideMenu)
@property (strong, readonly, nonatomic) EZSideMenu *sideMenuViewController;
// IB Action Helper methods
- (IBAction)presentLeftMenuViewController:(id)sender;
- (IBAction)presentRightMenuViewController:(id)sender;
@end





#ifndef IBInspectable
#define IBInspectable
#endif

@protocol EZSideMenuDelegate;

@interface EZSideMenu : UIViewController <UIGestureRecognizerDelegate>


//组件

@property (strong, readwrite, nonatomic) IBInspectable NSString *contentViewStoryboardID;
@property (strong, readwrite, nonatomic) IBInspectable NSString *leftMenuViewStoryboardID;
@property (strong, readwrite, nonatomic) IBInspectable NSString *rightMenuViewStoryboardID;


@property (strong, readwrite, nonatomic) UIViewController *contentViewController;
@property (strong, readwrite, nonatomic) UIViewController *leftMenuViewController;
@property (strong, readwrite, nonatomic) UIViewController *rightMenuViewController;
@property (weak, readwrite, nonatomic) id<EZSideMenuDelegate> delegate;



@property (assign, readwrite, nonatomic) NSTimeInterval animationDuration;//菜单动画时间，0.35f
#warning 可以实现左右两个图
@property (strong, readwrite, nonatomic) UIImage *backgroundImage;//菜单背景图片
@property (assign, readwrite, nonatomic) UIStatusBarStyle menuPreferredStatusBarStyle;
@property (assign, readwrite, nonatomic) IBInspectable BOOL menuPrefersStatusBarHidden;

//主内容偏移量
@property (assign, readwrite, nonatomic) IBInspectable CGFloat contentViewInLandscapeOffsetCenterX;
@property (assign, readwrite, nonatomic) IBInspectable CGFloat contentViewInPortraitOffsetCenterX;

//手势
@property (assign, readwrite, nonatomic) BOOL panGestureEnabled;//滑动打开
@property (assign, readwrite, nonatomic) BOOL panFromEdge;//边缘滑动打开
@property (assign, readwrite, nonatomic) NSUInteger panMinimumOpenThreshold;//滑动至少多少才算打开
@property (assign, readwrite, nonatomic) IBInspectable BOOL interactivePopGestureRecognizerEnabled;
#warning interactivePopGestureRecognizerEnabled 可以去掉
@property (assign, readwrite, nonatomic) IBInspectable BOOL bouncesHorizontally;//打开菜单后是否还可以像后滑动


//透明度渐变
@property (assign, readwrite, nonatomic) IBInspectable BOOL fadeMenuView;//菜单是否支持透明度
@property (assign, readwrite, nonatomic) IBInspectable CGFloat contentViewFadeOutAlpha;//打开菜单后主内容透明度

//大小改变
@property (assign, readwrite, nonatomic) IBInspectable BOOL scaleContentView;//主内容是否支持大小改变
@property (assign, readwrite, nonatomic) IBInspectable CGFloat contentViewScaleValue;//打开菜单后主内容大小
@property (assign, readwrite, nonatomic) IBInspectable BOOL scaleMenuView;//菜单大小
@property (assign, readwrite, nonatomic) IBInspectable CGFloat menuViewControllerScaleValue;//打开菜单前菜单大小
@property (assign, readwrite, nonatomic) IBInspectable BOOL scaleBackgroundImageView;//组件背景图片是否支持大小改变
@property (assign, readwrite, nonatomic) IBInspectable CGFloat backgroundImageViewScaleValue;//打开菜单前背景大小

//Shadow
@property (assign, readwrite, nonatomic) IBInspectable BOOL contentViewShadowEnabled;
@property (strong, readwrite, nonatomic) IBInspectable UIColor *contentViewShadowColor;
@property (assign, readwrite, nonatomic) IBInspectable CGSize contentViewShadowOffset;
@property (assign, readwrite, nonatomic) IBInspectable CGFloat contentViewShadowOpacity;
@property (assign, readwrite, nonatomic) IBInspectable CGFloat contentViewShadowRadius;


//MotionEffects效果
@property (assign, readwrite, nonatomic) IBInspectable BOOL parallaxEnabled;
@property (assign, readwrite, nonatomic) IBInspectable CGFloat parallaxMenuMinimumRelativeValue;
@property (assign, readwrite, nonatomic) IBInspectable CGFloat parallaxMenuMaximumRelativeValue;
@property (assign, readwrite, nonatomic) IBInspectable CGFloat parallaxContentMinimumRelativeValue;
@property (assign, readwrite, nonatomic) IBInspectable CGFloat parallaxContentMaximumRelativeValue;



- (id)initWithContentViewController:(UIViewController *)contentViewController
             leftMenuViewController:(UIViewController *)leftMenuViewController
            rightMenuViewController:(UIViewController *)rightMenuViewController;
- (void)presentLeftMenuViewController;
- (void)presentRightMenuViewController;
- (void)hideMenuViewController;
- (void)setContentViewController:(UIViewController *)contentViewController animated:(BOOL)animated;

@end

@protocol EZSideMenuDelegate <NSObject>

@optional
- (void)sideMenu:(EZSideMenu *)sideMenu didRecognizePanGesture:(UIPanGestureRecognizer *)recognizer;
- (void)sideMenu:(EZSideMenu *)sideMenu willShowMenuViewController:(UIViewController *)menuViewController;
- (void)sideMenu:(EZSideMenu *)sideMenu didShowMenuViewController:(UIViewController *)menuViewController;
- (void)sideMenu:(EZSideMenu *)sideMenu willHideMenuViewController:(UIViewController *)menuViewController;
- (void)sideMenu:(EZSideMenu *)sideMenu didHideMenuViewController:(UIViewController *)menuViewController;

@end


@interface EZSideMenu (Animation)
- (void)flashMenu;
@end
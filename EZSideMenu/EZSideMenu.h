#import <UIKit/UIKit.h>
@class EZSideMenu;
///////////////start ,兼容ios7
#ifndef EZUIKitIsFlatMode
  #define EZUIKitIsFlatMode() EZSideMenuUIKitIsFlatMode()
#endif

#ifndef kCFCoreFoundationVersionNumber_iOS_6_1
  #define kCFCoreFoundationVersionNumber_iOS_6_1 793.00
#endif

#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_6_1
  #define IF_IOS7_OR_GREATER(...)                                                  \
    if (kCFCoreFoundationVersionNumber > kCFCoreFoundationVersionNumber_iOS_6_1) { \
        __VA_ARGS__                                                                \
    }
#else
  #define IF_IOS7_OR_GREATER(...)
#endif

BOOL EZSideMenuUIKitIsFlatMode();

////////////////////end

/////////category
@interface UIViewController (EZSideMenu)

@property (strong, readonly, nonatomic) EZSideMenu *sideMenuViewController;

- (void)re_displayController:(UIViewController *)controller frame:(CGRect)frame;
- (void)re_hideController:(UIViewController *)controller;

@end
////////

@protocol EZSideMenuDelegate;

@interface EZSideMenu : UIViewController

@property (assign, nonatomic) NSTimeInterval animationDuration;  // 动画时间
@property (assign, nonatomic) BOOL           panGestureEnabled;  // 支持手势滑动

@property (strong, nonatomic) UIViewController   *contentViewController;
@property (assign, nonatomic) BOOL           scaleContentView;   // 主页面是否缩放
@property (assign, nonatomic) CGFloat    contentViewScaleValue;
@property (assign, nonatomic) CGFloat    contentViewInLandscapeOffsetCenterX;
@property (assign, nonatomic) CGFloat    contentViewInPortraitOffsetCenterX;

@property (strong, nonatomic) UIViewController   *menuViewController;
@property (assign, nonatomic) BOOL               scaleMenuViewController; // 抽屉是否缩放
@property (assign, nonatomic) CGFloat            menuViewControllerScaleValue;
@property (assign, nonatomic) BOOL               gradientMenuViewController;//抽屉渐变

@property (strong, nonatomic) UIImage    *backgroundImage;
@property (assign, nonatomic) BOOL       scaleBackgroundImageView;    // 抽屉背景是否缩放
@property (assign, nonatomic) CGFloat    backgroundImageViewScaleValue;

@property (assign, nonatomic) BOOL       onlySlideFromEdge;
@property (assign, nonatomic) CGFloat    slideEdgeValue;

@property (strong, nonatomic) id         parallaxMenuMinimumRelativeValue;
@property (strong, nonatomic) id         parallaxMenuMaximumRelativeValue;
@property (strong, nonatomic) id         parallaxContentMinimumRelativeValue;
@property (strong, nonatomic) id         parallaxContentMaximumRelativeValue;
@property (assign, nonatomic) BOOL       parallaxEnabled;




@property (weak, nonatomic) id <EZSideMenuDelegate> delegate;

- (id)initWithContentViewController:(UIViewController *)contentViewController menuViewController:(UIViewController *)menuViewController;
- (void)setContentViewController:(UIViewController *)contentViewController animated:(BOOL)animated;
- (void)presentMenuViewController;
- (void)hideMenuViewController;
- (void)flashMenu;

@end

@protocol EZSideMenuDelegate <NSObject>

@optional
- (void)sideMenu:(EZSideMenu *)sideMenu didRecognizePanGesture:(UIPanGestureRecognizer *)recognizer;
- (void)sideMenu:(EZSideMenu *)sideMenu willShowMenuViewController:(UIViewController *)menuViewController;
- (void)sideMenu:(EZSideMenu *)sideMenu didShowMenuViewController:(UIViewController *)menuViewController;
- (void)sideMenu:(EZSideMenu *)sideMenu willHideMenuViewController:(UIViewController *)menuViewController;
- (void)sideMenu:(EZSideMenu *)sideMenu didHideMenuViewController:(UIViewController *)menuViewController;

@end
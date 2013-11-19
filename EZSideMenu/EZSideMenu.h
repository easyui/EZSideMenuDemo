

#import <UIKit/UIKit.h>
@class EZSideMenu;
///////////////start
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

////////
@interface UIViewController (EZSideMenu)

@property (strong, readonly, nonatomic) EZSideMenu *sideMenuViewController;

- (void)re_displayController:(UIViewController *)controller frame:(CGRect)frame;
- (void)re_hideController:(UIViewController *)controller;

@end
////////

@protocol EZSideMenuDelegate;

@interface EZSideMenu : UIViewController

@property (assign, readwrite, nonatomic) NSTimeInterval animationDuration;//动画时间
@property (strong, readwrite, nonatomic) UIImage        *backgroundImage;
@property (assign, readwrite, nonatomic) BOOL           panGestureEnabled;//支持手势滑动
@property (assign, readwrite, nonatomic) BOOL           scaleContentView;//主页面是否缩放
@property (assign, readwrite, nonatomic) BOOL           scaleBackgroundImageView;//抽屉背景是否缩放
@property (assign, readwrite, nonatomic) CGFloat        contentViewScaleValue;
@property (assign, readwrite, nonatomic) CGFloat        contentViewInLandscapeOffsetCenterX;
@property (assign, readwrite, nonatomic) CGFloat        contentViewInPortraitOffsetCenterX;
@property (strong, readwrite, nonatomic) id             parallaxMenuMinimumRelativeValue;
@property (strong, readwrite, nonatomic) id             parallaxMenuMaximumRelativeValue;
@property (strong, readwrite, nonatomic) id             parallaxContentMinimumRelativeValue;
@property (strong, readwrite, nonatomic) id             parallaxContentMaximumRelativeValue;
@property (assign, readwrite, nonatomic) BOOL           parallaxEnabled;

@property (strong, readwrite, nonatomic) UIViewController   *contentViewController;
@property (strong, readwrite, nonatomic) UIViewController   *menuViewController;

@property (weak, readwrite, nonatomic) id <EZSideMenuDelegate> delegate;

- (id)initWithContentViewController:(UIViewController *)contentViewController menuViewController:(UIViewController *)menuViewController;
- (void)setContentViewController:(UIViewController *)contentViewController animated:(BOOL)animated;
- (void)presentMenuViewController;
- (void)hideMenuViewController;

@end

@protocol EZSideMenuDelegate <NSObject>

@optional
- (void)sideMenu:(EZSideMenu *)sideMenu didRecognizePanGesture:(UIPanGestureRecognizer *)recognizer;
- (void)sideMenu:(EZSideMenu *)sideMenu willShowMenuViewController:(UIViewController *)menuViewController;
- (void)sideMenu:(EZSideMenu *)sideMenu didShowMenuViewController:(UIViewController *)menuViewController;
- (void)sideMenu:(EZSideMenu *)sideMenu willHideMenuViewController:(UIViewController *)menuViewController;
- (void)sideMenu:(EZSideMenu *)sideMenu didHideMenuViewController:(UIViewController *)menuViewController;

@end
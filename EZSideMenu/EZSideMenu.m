//
//  EZSideMenu.m
//  EZSideMenuDemo
//
//  Created by yangjun zhu on 15/8/25.
//  Copyright (c) 2015年 Cactus. All rights reserved.
//

#import "EZSideMenu.h"

@implementation UIViewController (EZSideMenu)

- (EZSideMenu *)sideMenuViewController
{
    UIViewController *iter = self.parentViewController;
    while (iter) {
        if ([iter isKindOfClass:[EZSideMenu class]]) {
            return (EZSideMenu *)iter;
        } else if (iter.parentViewController && iter.parentViewController != iter) {
            iter = iter.parentViewController;
        } else {
            iter = nil;
        }
    }
    return nil;
}

#pragma mark -
#pragma mark IB Action Helper methods

- (IBAction)presentLeftMenuViewController:(id)sender
{
    [self.sideMenuViewController presentLeftMenuViewController];
}

- (IBAction)presentRightMenuViewController:(id)sender
{
    [self.sideMenuViewController presentRightMenuViewController];
}

@end


@interface EZSideMenu ()

@property (strong, readwrite, nonatomic) UIImageView *backgroundImageView;
@property (assign, readwrite, nonatomic) BOOL visible;
@property (assign, readwrite, nonatomic) BOOL leftMenuVisible;
@property (assign, readwrite, nonatomic) BOOL rightMenuVisible;
@property (assign, readwrite, nonatomic) CGPoint originalPoint;
@property (strong, readwrite, nonatomic) UIButton *contentButton;
@property (strong, readwrite, nonatomic) UIView *menuViewContainer;
@property (strong, readwrite, nonatomic) UIView *contentViewContainer;
@property (assign, readwrite, nonatomic) BOOL didNotifyDelegate;
@property (assign, nonatomic) BOOL toSuperMenu;

@end

@implementation EZSideMenu

#pragma mark -
#pragma mark Instance lifecycle

- (id)init
{
    self = [super init];
    if (self) {
        [self commonInit];
    }
    return self;
}


// storeboard
- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super initWithCoder:decoder];
    if (self) {
        [self commonInit];
    }
    return self;
}

#if __IPHONE_8_0
- (void)awakeFromNib
{
    [super awakeFromNib];
    if (self.contentViewStoryboardID) {
        self.contentViewController = [self.storyboard instantiateViewControllerWithIdentifier:self.contentViewStoryboardID];
    }
    if (self.leftMenuViewStoryboardID) {
        self.leftMenuViewController = [self.storyboard instantiateViewControllerWithIdentifier:self.leftMenuViewStoryboardID];
    }
    if (self.rightMenuViewStoryboardID) {
        self.rightMenuViewController = [self.storyboard instantiateViewControllerWithIdentifier:self.rightMenuViewStoryboardID];
    }
}
#endif

- (void)commonInit
{
    _menuViewContainer = [[UIView alloc] init];
    _contentViewContainer = [[UIView alloc] init];
    
    _animationDuration = 0.35f;
    //主内容偏移量
    _contentViewInLandscapeOffsetCenterX = 30.f;
    _contentViewInPortraitOffsetCenterX = 30.f;
    
    //手势
    _panGestureEnabled = YES;
    _panFromEdge = YES;
    _panMinimumOpenThreshold = 60.0;
    _bouncesHorizontally = YES;
    
    //透明度渐变
    _fadeMenuView = YES;
    _contentViewFadeOutAlpha = 1.0f;
    
    //大小改变
    _scaleContentView = YES;
    _contentViewScaleValue = 0.7f;
    _scaleMenuView = YES;
    _menuViewControllerScaleValue = 1.5f;
    _scaleBackgroundImageView = YES;
    _backgroundImageViewScaleValue = 1.7f;
    
    //Shadow
    _contentViewShadowEnabled = NO;
    _contentViewShadowColor = [UIColor blackColor];
    _contentViewShadowOffset = CGSizeZero;
    _contentViewShadowOpacity = 0.4f;
    _contentViewShadowRadius = 8.0f;
    
    //MotionEffects效果
    _parallaxEnabled = YES;
    _parallaxMenuMinimumRelativeValue = -15;
    _parallaxMenuMaximumRelativeValue = 15;
    _parallaxContentMinimumRelativeValue = -25;
    _parallaxContentMaximumRelativeValue = 25;
    
}

#pragma mark -
#pragma mark Public methods

- (id)initWithContentViewController:(UIViewController *)contentViewController leftMenuViewController:(UIViewController *)leftMenuViewController rightMenuViewController:(UIViewController *)rightMenuViewController
{
    self = [self init];
    if (self) {
        _contentViewController = contentViewController;
        _leftMenuViewController = leftMenuViewController;
        _rightMenuViewController = rightMenuViewController;
    }
    return self;
}

- (void)presentLeftMenuViewController
{
    [self __presentMenuViewContainerWithMenuViewController:self.leftMenuViewController];
    //    [self __showLeftMenuViewController];
    [self __showMenuViewController:self.leftMenuViewController];
}

- (void)presentRightMenuViewController
{
    [self __presentMenuViewContainerWithMenuViewController:self.rightMenuViewController];
    //    [self __showRightMenuViewController];
    [self __showMenuViewController:self.rightMenuViewController];
}

- (void)hideMenuViewController
{
    [self __hideMenuViewControllerAnimated:YES];
}

- (void)setContentViewController:(UIViewController *)contentViewController animated:(BOOL)animated
{
    if (_contentViewController == contentViewController)
    {
        return;
    }
    
    if (!animated) {
        [self setContentViewController:contentViewController];
    } else {
        [self addChildViewController:contentViewController];
        contentViewController.view.alpha = 0;
        contentViewController.view.frame = self.contentViewContainer.bounds;
        [self.contentViewContainer addSubview:contentViewController.view];
        [UIView animateWithDuration:self.animationDuration animations:^{
            contentViewController.view.alpha = 1;
        } completion:^(BOOL finished) {
            [self __hideViewController:self.contentViewController];
            [contentViewController didMoveToParentViewController:self];
            _contentViewController = contentViewController;
            
            [self __statusBarNeedsAppearanceUpdate];
            [self __updateContentViewShadow];
            
            if (self.visible) {
                [self __addContentViewControllerMotionEffects];
            }
        }];
    }
}

#pragma mark View life cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.backgroundImageView = ({
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
        imageView.image = self.backgroundImage;
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        imageView;
    });
    self.contentButton = ({
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectNull];
        [button addTarget:self action:@selector(hideMenuViewController) forControlEvents:UIControlEventTouchUpInside];
        button;
    });
    
    [self.view addSubview:self.backgroundImageView];
    [self.view addSubview:self.menuViewContainer];
    [self.view addSubview:self.contentViewContainer];
    
    self.menuViewContainer.frame = self.view.bounds;
    self.menuViewContainer.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    if (self.leftMenuViewController) {
        [self addChildViewController:self.leftMenuViewController];
        self.leftMenuViewController.view.frame = self.view.bounds;
        self.leftMenuViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.menuViewContainer addSubview:self.leftMenuViewController.view];
        [self.leftMenuViewController didMoveToParentViewController:self];
    }
    if (self.rightMenuViewController) {
        [self addChildViewController:self.rightMenuViewController];
        self.rightMenuViewController.view.frame = self.view.bounds;
        self.rightMenuViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.menuViewContainer addSubview:self.rightMenuViewController.view];
        [self.rightMenuViewController didMoveToParentViewController:self];
    }
    
    self.contentViewContainer.frame = self.view.bounds;
    self.contentViewContainer.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self addChildViewController:self.contentViewController];
    self.contentViewController.view.frame = self.view.bounds;
    [self.contentViewContainer addSubview:self.contentViewController.view];
    [self.contentViewController didMoveToParentViewController:self];
    
    self.menuViewContainer.alpha = self.fadeMenuView ? 0.0f : 1.0f;
    if (self.scaleBackgroundImageView)
        self.backgroundImageView.transform = CGAffineTransformMakeScale(self.backgroundImageViewScaleValue, self.backgroundImageViewScaleValue);
    
    [self __addMenuViewControllerMotionEffects];
#if TARGET_OS_IOS
    if (self.panGestureEnabled) {

        self.view.multipleTouchEnabled = NO;
        UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureRecognized:)];
        panGestureRecognizer.delegate = self;
        [self.view addGestureRecognizer:panGestureRecognizer];
    }
#endif
    
    [self __updateContentViewShadow];
}

#pragma mark -
#pragma mark Private methods

- (void)__presentMenuViewContainerWithMenuViewController:(UIViewController *)menuViewController
{
    /*初始化状态*/
    //组件
    if (self.scaleBackgroundImageView) {
        self.backgroundImageView.transform = CGAffineTransformIdentity;
        self.backgroundImageView.frame = self.view.bounds;
        self.backgroundImageView.transform = CGAffineTransformMakeScale(self.backgroundImageViewScaleValue, self.backgroundImageViewScaleValue);
    }
    
    //菜单
    self.menuViewContainer.transform = CGAffineTransformIdentity;
    self.menuViewContainer.frame = self.view.bounds;
    if (self.scaleMenuView) {
        self.menuViewContainer.transform = CGAffineTransformIdentity;
        self.menuViewContainer.frame = self.view.bounds;
        self.menuViewContainer.transform = CGAffineTransformMakeScale(self.menuViewControllerScaleValue, self.menuViewControllerScaleValue);
    }
    self.menuViewContainer.alpha = self.fadeMenuView ? 0.0f : 1.0f;
    
    
    
    if ([self.delegate conformsToProtocol:@protocol(EZSideMenuDelegate)] && [self.delegate respondsToSelector:@selector(sideMenu:willShowMenuViewController:)]) {
        [self.delegate sideMenu:self willShowMenuViewController:menuViewController];
    }
}

- (void)__showMenuViewController:(UIViewController *)menuViewController
{
    if (!menuViewController) {
        return;
    }
    
    //主内容
    [self __resetContentViewScale];
    [self __updateContentViewShadow];
    [self __addContentButton];
    
    
    self.leftMenuViewController.view.hidden = YES;
    self.rightMenuViewController.view.hidden = YES;
    menuViewController.view.hidden = NO;
    
    
    [self.view.window endEditing:YES];// 退出键盘等
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    [menuViewController beginAppearanceTransition:YES animated:YES];
    
    [UIView animateWithDuration:self.animationDuration animations:^{
        //组件
        if (self.scaleBackgroundImageView)
            self.backgroundImageView.transform = CGAffineTransformIdentity;
        //菜单
        self.menuViewContainer.alpha = self.fadeMenuView ? 1.0f : 1.0f;
        self.menuViewContainer.transform = CGAffineTransformIdentity;
        //主内容
        if (self.scaleContentView) {
            self.contentViewContainer.transform = CGAffineTransformMakeScale(self.contentViewScaleValue, self.contentViewScaleValue);
        } else {
            self.contentViewContainer.transform = CGAffineTransformIdentity;
        }
        if(menuViewController == self.leftMenuViewController){
#if TARGET_OS_IOS
            self.contentViewContainer.center = CGPointMake((UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation]) ? (self.contentViewInLandscapeOffsetCenterX + [self __viewGetWidth]) : (self.contentViewInPortraitOffsetCenterX + CGRectGetWidth(self.view.frame))), self.contentViewContainer.center.y);
#else
            self.contentViewContainer.center = CGPointMake((self.contentViewInLandscapeOffsetCenterX + [self __viewGetWidth]) , self.contentViewContainer.center.y);
#endif
        }else{
#if TARGET_OS_IOS
            self.contentViewContainer.center = CGPointMake((UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation]) ? -self.contentViewInLandscapeOffsetCenterX : -self.contentViewInPortraitOffsetCenterX), self.contentViewContainer.center.y);
            self.contentViewContainer.center = CGPointMake( -self.contentViewInLandscapeOffsetCenterX , self.contentViewContainer.center.y);
#else
            self.contentViewContainer.alpha = self.contentViewFadeOutAlpha;
#endif
            
        }
        
        
    } completion:^(BOOL finished) {
        [menuViewController endAppearanceTransition];
        [self __addContentViewControllerMotionEffects];
        
        if (!self.visible && [self.delegate conformsToProtocol:@protocol(EZSideMenuDelegate)] && [self.delegate respondsToSelector:@selector(sideMenu:didShowMenuViewController:)]) {
            [self.delegate sideMenu:self didShowMenuViewController:menuViewController];
        }
        
        self.visible = YES;
        self.leftMenuVisible = (menuViewController == self.leftMenuViewController);
        self.rightMenuVisible = (menuViewController == self.rightMenuViewController);
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
        [self setNeedsFocusUpdate];
        
    }];
    
    [self __statusBarNeedsAppearanceUpdate];
}

/*
 - (void)__showLeftMenuViewController
 {
 if (!self.leftMenuViewController) {
 return;
 }
 
 self.leftMenuViewController.view.hidden = NO;
 self.rightMenuViewController.view.hidden = YES;
 
 
 
 [self.view.window endEditing:YES];// 退出键盘等
 [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
 [self.leftMenuViewController beginAppearanceTransition:YES animated:YES];
 
 [UIView animateWithDuration:self.animationDuration animations:^{
 //组件
 if (self.scaleBackgroundImageView)
 self.backgroundImageView.transform = CGAffineTransformIdentity;
 //菜单
 self.menuViewContainer.alpha = self.fadeMenuView ? 1.0f : 1.0f;
 self.menuViewContainer.transform = CGAffineTransformIdentity;
 //主内容
 if (self.scaleContentView) {
 self.contentViewContainer.transform = CGAffineTransformMakeScale(self.contentViewScaleValue, self.contentViewScaleValue);
 } else {
 self.contentViewContainer.transform = CGAffineTransformIdentity;
 }
 self.contentViewContainer.center = CGPointMake((UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation]) ? (self.contentViewInLandscapeOffsetCenterX + [self __viewGetWidth]) : (self.contentViewInPortraitOffsetCenterX + CGRectGetWidth(self.view.frame))), self.contentViewContainer.center.y);
 self.contentViewContainer.alpha = self.contentViewFadeOutAlpha;
 
 } completion:^(BOOL finished) {
 [self.leftMenuViewController endAppearanceTransition];
 [self __addContentViewControllerMotionEffects];
 
 if (!self.visible && [self.delegate conformsToProtocol:@protocol(EZSideMenuDelegate)] && [self.delegate respondsToSelector:@selector(sideMenu:didShowMenuViewController:)]) {
 [self.delegate sideMenu:self didShowMenuViewController:self.leftMenuViewController];
 }
 
 self.visible = YES;
 self.leftMenuVisible = YES;
 [[UIApplication sharedApplication] endIgnoringInteractionEvents];
 
 }];
 
 [self __statusBarNeedsAppearanceUpdate];
 }
 
 - (void)__showRightMenuViewController
 {
 if (!self.rightMenuViewController) {
 return;
 }
 
 
 self.leftMenuViewController.view.hidden = YES;
 self.rightMenuViewController.view.hidden = NO;
 
 [self.view.window endEditing:YES];
 [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
 [self.rightMenuViewController beginAppearanceTransition:YES animated:YES];
 
 [UIView animateWithDuration:self.animationDuration animations:^{
 if (self.scaleBackgroundImageView)
 self.backgroundImageView.transform = CGAffineTransformIdentity;
 
 //菜单
 self.menuViewContainer.alpha = self.fadeMenuView ? 1.0f : 1.0f;
 self.menuViewContainer.transform = CGAffineTransformIdentity;
 
 //主内容
 if (self.scaleContentView) {
 self.contentViewContainer.transform = CGAffineTransformMakeScale(self.contentViewScaleValue, self.contentViewScaleValue);
 } else {
 self.contentViewContainer.transform = CGAffineTransformIdentity;
 }
 self.contentViewContainer.center = CGPointMake((UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation]) ? -self.contentViewInLandscapeOffsetCenterX : -self.contentViewInPortraitOffsetCenterX), self.contentViewContainer.center.y);
 self.contentViewContainer.alpha = self.contentViewFadeOutAlpha;
 
 } completion:^(BOOL finished) {
 [self.rightMenuViewController endAppearanceTransition];
 [self __addContentViewControllerMotionEffects];
 
 if (!self.rightMenuVisible && [self.delegate conformsToProtocol:@protocol(EZSideMenuDelegate)] && [self.delegate respondsToSelector:@selector(sideMenu:didShowMenuViewController:)]) {
 [self.delegate sideMenu:self didShowMenuViewController:self.rightMenuViewController];
 }
 
 self.visible = !(self.contentViewContainer.frame.size.width == self.view.bounds.size.width && self.contentViewContainer.frame.size.height == self.view.bounds.size.height && self.contentViewContainer.frame.origin.x == 0 && self.contentViewContainer.frame.origin.y == 0);
 self.rightMenuVisible = self.visible;
 [[UIApplication sharedApplication] endIgnoringInteractionEvents];
 
 }];
 
 [self __statusBarNeedsAppearanceUpdate];
 }
 */

- (void)__hideViewController:(UIViewController *)viewController
{
    [viewController willMoveToParentViewController:nil];
    [viewController.view removeFromSuperview];
    [viewController removeFromParentViewController];
}

- (void)__hideMenuViewControllerAnimated:(BOOL)animated
{
    BOOL rightMenuVisible = self.rightMenuVisible;
    UIViewController *visibleMenuViewController = rightMenuVisible ? self.rightMenuViewController : self.leftMenuViewController;
    [visibleMenuViewController beginAppearanceTransition:NO animated:animated];
    if ([self.delegate conformsToProtocol:@protocol(EZSideMenuDelegate)] && [self.delegate respondsToSelector:@selector(sideMenu:willHideMenuViewController:)]) {
        [self.delegate sideMenu:self willHideMenuViewController:rightMenuVisible ? self.rightMenuViewController : self.leftMenuViewController];
    }
    
    self.visible = NO;
    self.leftMenuVisible = NO;
    self.rightMenuVisible = NO;
    [self.contentButton removeFromSuperview];
    
    __typeof (self) __weak weakSelf = self;
    void (^animationBlock)(void) = ^{
        __typeof (weakSelf) __strong strongSelf = weakSelf;
        if (!strongSelf) {
            return;
        }
        strongSelf.contentViewContainer.transform = CGAffineTransformIdentity;
        strongSelf.contentViewContainer.frame = strongSelf.view.bounds;
        strongSelf.contentViewContainer.alpha = 1.0f;
        
        if (strongSelf.scaleMenuView) {
            strongSelf.menuViewContainer.transform = CGAffineTransformMakeScale(self.menuViewControllerScaleValue, self.menuViewControllerScaleValue);
        }
        strongSelf.menuViewContainer.alpha = self.fadeMenuView ? 0.0f : 1.0f;
        
        if (strongSelf.scaleBackgroundImageView) {
            strongSelf.backgroundImageView.transform = CGAffineTransformMakeScale(self.backgroundImageViewScaleValue, self.backgroundImageViewScaleValue);
        }
        if (strongSelf.parallaxEnabled) {
            for (UIMotionEffect *effect in strongSelf.contentViewContainer.motionEffects) {
                [strongSelf.contentViewContainer removeMotionEffect:effect];
            }
            
        }
        
    };
    void (^completionBlock)(void) = ^{
        __typeof (weakSelf) __strong strongSelf = weakSelf;
        if (!strongSelf) {
            return;
        }
        [visibleMenuViewController endAppearanceTransition];
        if (!strongSelf.visible && [strongSelf.delegate conformsToProtocol:@protocol(EZSideMenuDelegate)] && [strongSelf.delegate respondsToSelector:@selector(sideMenu:didHideMenuViewController:)]) {
            [strongSelf.delegate sideMenu:strongSelf didHideMenuViewController:rightMenuVisible ? strongSelf.rightMenuViewController : strongSelf.leftMenuViewController];
        }
        [self setNeedsFocusUpdate];

    };
    
    if (animated) {
        [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
        [UIView animateWithDuration:self.animationDuration animations:^{
            animationBlock();
        } completion:^(BOOL finished) {
            [[UIApplication sharedApplication] endIgnoringInteractionEvents];
            completionBlock();
        }];
    } else {
        animationBlock();
        completionBlock();
    }
    [self __statusBarNeedsAppearanceUpdate];
}

- (void)__addContentButton
{
    if (self.contentButton.superview)
        return;
    
    //    self.contentButton.autoresizingMask = UIViewAutoresizingNone;
    self.contentButton.frame = self.contentViewContainer.bounds;
    self.contentButton.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.contentViewContainer addSubview:self.contentButton];
}

- (void)__statusBarNeedsAppearanceUpdate
{
    if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
        [UIView animateWithDuration:0.3f animations:^{
            [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
        }];
    }
}

- (void)__updateContentViewShadow
{
    if (self.contentViewShadowEnabled) {
        CALayer *layer = self.contentViewContainer.layer;
        UIBezierPath *path = [UIBezierPath bezierPathWithRect:layer.bounds];
        layer.shadowPath = path.CGPath;
        layer.shadowColor = self.contentViewShadowColor.CGColor;
        layer.shadowOffset = self.contentViewShadowOffset;
        layer.shadowOpacity = self.contentViewShadowOpacity;
        layer.shadowRadius = self.contentViewShadowRadius;
    }
}

- (void)__resetContentViewScale
{
    
    CGAffineTransform t = self.contentViewContainer.transform;
    CGFloat scale = sqrt(t.a * t.a + t.c * t.c);
    CGRect frame = self.contentViewContainer.frame;
    self.contentViewContainer.transform = CGAffineTransformIdentity;
    self.contentViewContainer.transform = CGAffineTransformMakeScale(scale, scale);
    self.contentViewContainer.frame = frame;
}

#pragma mark - view methods (Private)
-(CGFloat)__viewGetWidth{
#if TARGET_OS_IOS
    if ((NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_7_1)) {
        return  CGRectGetWidth(self.view.frame);
    }else{
        return UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation)?CGRectGetHeight(self.view.frame):CGRectGetWidth(self.view.frame);
    }
#else
    return  CGRectGetWidth(self.view.frame);
#endif
}

#pragma mark -
#pragma mark iOS 7 Motion Effects (Private)

- (void)__addMenuViewControllerMotionEffects
{
    
    [self __addMotionEffectsTo:self.menuViewContainer minimumRelativeValue:self.parallaxMenuMinimumRelativeValue maximumRelativeValue:self.parallaxMenuMaximumRelativeValue];
}

- (void)__addContentViewControllerMotionEffects
{
    [self __addMotionEffectsTo:self.contentViewContainer minimumRelativeValue:self.parallaxContentMinimumRelativeValue maximumRelativeValue:self.parallaxContentMaximumRelativeValue];
}

- (void)__addMotionEffectsTo:(UIView *)view minimumRelativeValue:(CGFloat)minimumRelativeValue maximumRelativeValue:(CGFloat)maximumRelativeValue{
    if (self.parallaxEnabled) {
        
        for (UIMotionEffect *effect in view.motionEffects) {
            [view removeMotionEffect:effect];
        }
        [UIView animateWithDuration:0.2 animations:^{
            UIInterpolatingMotionEffect *interpolationHorizontal = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.x" type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
            interpolationHorizontal.minimumRelativeValue = @(minimumRelativeValue);
            interpolationHorizontal.maximumRelativeValue = @(maximumRelativeValue);
            
            UIInterpolatingMotionEffect *interpolationVertical = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.y" type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
            interpolationVertical.minimumRelativeValue = @(minimumRelativeValue);
            interpolationVertical.maximumRelativeValue = @(maximumRelativeValue);
            
            [view addMotionEffect:interpolationHorizontal];
            [view addMotionEffect:interpolationVertical];
        }];
        
    }
    
}

#pragma mark -
#pragma mark UIGestureRecognizer Delegate (Private)

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{

    if (self.panFromEdge && [gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]] && !self.visible) {
        CGPoint point = [touch locationInView:gestureRecognizer.view];
        if (point.x < 20.0 || point.x > self.view.frame.size.width - 20.0) {
            return YES;
        } else {
            return NO;
        }
    }
    
    return YES;
}

#pragma mark -
#pragma mark Pan gesture recognizer (Private)

- (void)panGestureRecognized:(UIPanGestureRecognizer *)recognizer
{
    if ([self.delegate conformsToProtocol:@protocol(EZSideMenuDelegate)] && [self.delegate respondsToSelector:@selector(sideMenu:didRecognizePanGesture:)])
        [self.delegate sideMenu:self didRecognizePanGesture:recognizer];
    
    if (!self.panGestureEnabled) {
        return;
    }
    
    CGPoint point = [recognizer translationInView:self.view];
    
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        [self __updateContentViewShadow];
        
        self.originalPoint = CGPointMake(self.contentViewContainer.center.x - CGRectGetWidth(self.contentViewContainer.bounds) / 2.0,
                                         self.contentViewContainer.center.y - CGRectGetHeight(self.contentViewContainer.bounds) / 2.0);
        self.menuViewContainer.transform = CGAffineTransformIdentity;
        self.menuViewContainer.frame = self.view.bounds;
        
        if (self.scaleBackgroundImageView) {
            self.backgroundImageView.transform = CGAffineTransformIdentity;
            self.backgroundImageView.frame = self.view.bounds;
        }
        [self __addContentButton];
        [self.view.window endEditing:YES];
        self.didNotifyDelegate = NO;
    }
    
    if (recognizer.state == UIGestureRecognizerStateChanged) {
        CGFloat delta = 0;
        if (self.visible) {
            delta = self.originalPoint.x != 0 ? (point.x + self.originalPoint.x) / self.originalPoint.x : 0;
        } else {
            delta = point.x / self.view.frame.size.width;
        }
        delta = MIN(fabs(delta), 1.6);
        
        CGFloat contentViewScale = self.scaleContentView ? 1 - ((1 - self.contentViewScaleValue) * delta) : 1;
        
        CGFloat backgroundViewScale = self.backgroundImageViewScaleValue - (0.7f * delta);
        CGFloat menuViewScale = 1.5f - (0.5f * delta);
        
        if (!self.bouncesHorizontally) {
            contentViewScale = MAX(contentViewScale, self.contentViewScaleValue);
            backgroundViewScale = MAX(backgroundViewScale, 1.0);
            menuViewScale = MAX(menuViewScale, 1.0);
        }
        
        self.menuViewContainer.alpha = self.fadeMenuView ? delta: 1.0f;
        self.contentViewContainer.alpha = 1 - (1 - self.contentViewFadeOutAlpha) * delta;
        
        if (self.scaleBackgroundImageView) {
            self.backgroundImageView.transform = CGAffineTransformMakeScale(backgroundViewScale, backgroundViewScale);
            if (backgroundViewScale < 1) {
                self.backgroundImageView.transform = CGAffineTransformIdentity;
            }
        }
        
        if (self.scaleMenuView) {
            self.menuViewContainer.transform = CGAffineTransformMakeScale(menuViewScale, menuViewScale);
        }
        
        
        
        if (!self.bouncesHorizontally && self.visible) {
            if (self.contentViewContainer.frame.origin.x > self.contentViewContainer.frame.size.width / 2.0)
                point.x = MIN(0.0, point.x);
            
            if (self.contentViewContainer.frame.origin.x < -(self.contentViewContainer.frame.size.width / 2.0))
                point.x = MAX(0.0, point.x);
        }
        
        // Limit size
        //
        if (point.x < 0) {
            point.x = MAX(point.x, -[UIScreen mainScreen].bounds.size.height);
        } else {
            point.x = MIN(point.x, [UIScreen mainScreen].bounds.size.height);
        }
        [recognizer setTranslation:point inView:self.view];
        
        if (!self.didNotifyDelegate) {
            if (point.x > 0) {
                if (!self.visible && [self.delegate conformsToProtocol:@protocol(EZSideMenuDelegate)] && [self.delegate respondsToSelector:@selector(sideMenu:willShowMenuViewController:)]) {
                    [self.delegate sideMenu:self willShowMenuViewController:self.leftMenuViewController];
                }
            }
            if (point.x < 0) {
                if (!self.visible && [self.delegate conformsToProtocol:@protocol(EZSideMenuDelegate)] && [self.delegate respondsToSelector:@selector(sideMenu:willShowMenuViewController:)]) {
                    [self.delegate sideMenu:self willShowMenuViewController:self.rightMenuViewController];
                }
            }
            self.didNotifyDelegate = YES;
        }
        
        if (contentViewScale > 1) {
            CGFloat oppositeScale = (1 - (contentViewScale - 1));
            self.contentViewContainer.transform = CGAffineTransformMakeScale(oppositeScale, oppositeScale);
            self.contentViewContainer.transform = CGAffineTransformTranslate(self.contentViewContainer.transform, point.x, 0);
        } else {
            self.contentViewContainer.transform = CGAffineTransformMakeScale(contentViewScale, contentViewScale);
            self.contentViewContainer.transform = CGAffineTransformTranslate(self.contentViewContainer.transform, point.x, 0);
        }
        
        self.leftMenuViewController.view.hidden = self.contentViewContainer.frame.origin.x < 0;
        self.rightMenuViewController.view.hidden = self.contentViewContainer.frame.origin.x > 0;
        
        if (!self.leftMenuViewController && self.contentViewContainer.frame.origin.x > 0) {
            self.contentViewContainer.transform = CGAffineTransformIdentity;
            self.contentViewContainer.frame = self.view.bounds;
            self.visible = NO;
            self.leftMenuVisible = NO;
        } else  if (!self.rightMenuViewController && self.contentViewContainer.frame.origin.x < 0) {
            self.contentViewContainer.transform = CGAffineTransformIdentity;
            self.contentViewContainer.frame = self.view.bounds;
            self.visible = NO;
            self.rightMenuVisible = NO;
        }
        
        [self __statusBarNeedsAppearanceUpdate];
    }
    
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        self.didNotifyDelegate = NO;
        if (self.panMinimumOpenThreshold > 0 && (
                                                 (self.contentViewContainer.frame.origin.x < 0 && self.contentViewContainer.frame.origin.x > -((NSInteger)self.panMinimumOpenThreshold)) ||
                                                 (self.contentViewContainer.frame.origin.x > 0 && self.contentViewContainer.frame.origin.x < self.panMinimumOpenThreshold))
            ) {
            [self hideMenuViewController];
        }
        else if (self.contentViewContainer.frame.origin.x == 0) {
            [self __hideMenuViewControllerAnimated:NO];
        }
        else {
            if ([recognizer velocityInView:self.view].x > 0) {
                if (self.contentViewContainer.frame.origin.x < 0) {
                    [self hideMenuViewController];
                } else {
                    if (self.leftMenuViewController) {
                        [self __showMenuViewController:self.leftMenuViewController];
                    }
                }
            } else {
                if (self.contentViewContainer.frame.origin.x < 20) {
                    if (self.rightMenuViewController) {
                        [self __showMenuViewController:self.rightMenuViewController];
                    }
                } else {
                    [self hideMenuViewController];
                }
            }
        }
    }
}

#pragma mark -
#pragma mark Setters

- (void)setBackgroundImage:(UIImage *)backgroundImage
{
    _backgroundImage = backgroundImage;
    if (self.backgroundImageView)
        self.backgroundImageView.image = backgroundImage;
}

- (void)setContentViewController:(UIViewController *)contentViewController
{
    if (!_contentViewController) {
        _contentViewController = contentViewController;
        return;
    }
    [self __hideViewController:_contentViewController];
    _contentViewController = contentViewController;
    
    [self addChildViewController:self.contentViewController];
    self.contentViewController.view.frame = self.view.bounds;
    [self.contentViewContainer addSubview:self.contentViewController.view];
    [self.contentViewController didMoveToParentViewController:self];
    
    [self __updateContentViewShadow];
    
    if (self.visible) {
        [self __addContentViewControllerMotionEffects];
    }
}

- (void)setLeftMenuViewController:(UIViewController *)leftMenuViewController
{
    if (!_leftMenuViewController) {
        _leftMenuViewController = leftMenuViewController;
        return;
    }
    [self __hideViewController:_leftMenuViewController];
    _leftMenuViewController = leftMenuViewController;
    
    [self addChildViewController:self.leftMenuViewController];
    self.leftMenuViewController.view.frame = self.view.bounds;
    self.leftMenuViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.menuViewContainer addSubview:self.leftMenuViewController.view];
    [self.leftMenuViewController didMoveToParentViewController:self];
    
    [self __addMenuViewControllerMotionEffects];
    [self.view bringSubviewToFront:self.contentViewContainer];
}

- (void)setRightMenuViewController:(UIViewController *)rightMenuViewController
{
    if (!_rightMenuViewController) {
        _rightMenuViewController = rightMenuViewController;
        return;
    }
    [self __hideViewController:_rightMenuViewController];
    _rightMenuViewController = rightMenuViewController;
    
    [self addChildViewController:self.rightMenuViewController];
    self.rightMenuViewController.view.frame = self.view.bounds;
    self.rightMenuViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.menuViewContainer addSubview:self.rightMenuViewController.view];
    [self.rightMenuViewController didMoveToParentViewController:self];
    
    [self __addMenuViewControllerMotionEffects];
    [self.view bringSubviewToFront:self.contentViewContainer];
}

#pragma mark -
#pragma mark View Controller Rotation handler

- (BOOL)shouldAutorotate
{
    return self.contentViewController.shouldAutorotate;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
    return self.contentViewController.supportedInterfaceOrientations;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    if (self.visible) {
        self.menuViewContainer.bounds = self.view.bounds;
        self.contentViewContainer.transform = CGAffineTransformIdentity;
        self.contentViewContainer.frame = self.view.bounds;
        
        if (self.scaleContentView) {
            self.contentViewContainer.transform = CGAffineTransformMakeScale(self.contentViewScaleValue, self.contentViewScaleValue);
        } else {
            self.contentViewContainer.transform = CGAffineTransformIdentity;
        }
        
        CGPoint center;
        if (self.leftMenuVisible) {
            center = CGPointMake((UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation) ? self.contentViewInLandscapeOffsetCenterX + [self __viewGetWidth] : self.contentViewInPortraitOffsetCenterX + CGRectGetWidth(self.view.frame)), self.contentViewContainer.center.y);
            
        } else {
            center = CGPointMake((UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation) ? -self.contentViewInLandscapeOffsetCenterX : -self.contentViewInPortraitOffsetCenterX), self.contentViewContainer.center.y);
        }
        
        self.contentViewContainer.center = center;
    }
    
    [self __updateContentViewShadow];
}

#pragma mark -
#pragma mark Status Bar Appearance Management
#if TARGET_OS_IOS
- (UIStatusBarStyle)preferredStatusBarStyle
{
    UIStatusBarStyle statusBarStyle = UIStatusBarStyleDefault;
    
    //    statusBarStyle = self.visible ? self.menuPreferredStatusBarStyle : self.contentViewController.preferredStatusBarStyle;
    if (self.contentViewContainer.frame.origin.y > 10) {
        statusBarStyle = self.menuPreferredStatusBarStyle;
    } else {
        statusBarStyle = self.contentViewController.preferredStatusBarStyle;
    }
    
    return statusBarStyle;
}

- (BOOL)prefersStatusBarHidden
{
    BOOL statusBarHidden = NO;
    
    //    statusBarHidden = self.visible ? self.menuPrefersStatusBarHidden : self.contentViewController.prefersStatusBarHidden;
    if (self.contentViewContainer.frame.origin.y > 10) {
        statusBarHidden = self.menuPrefersStatusBarHidden;
    } else {
        statusBarHidden = self.contentViewController.prefersStatusBarHidden;
    }
    
    return statusBarHidden;
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation
{
    UIStatusBarAnimation statusBarAnimation = UIStatusBarAnimationNone;
    statusBarAnimation = self.visible ? self.leftMenuViewController.preferredStatusBarUpdateAnimation : self.contentViewController.preferredStatusBarUpdateAnimation;
    if (self.contentViewContainer.frame.origin.y > 10) {
        statusBarAnimation = (self.leftMenuVisible ? self.leftMenuViewController.preferredStatusBarUpdateAnimation : self.rightMenuViewController.preferredStatusBarUpdateAnimation);
    } else {
        statusBarAnimation = self.contentViewController.preferredStatusBarUpdateAnimation;
    }
    
    return statusBarAnimation;
}
#endif

#pragma mark -
#pragma mark UIPress action (Private)

-(void)pressesBegan:(NSSet<UIPress *> *)presses withEvent:(UIPressesEvent *)event{
    
    if ( presses.anyObject.type == UIPressTypeMenu) {
        self.toSuperMenu = NO;
        
        if (self.visible == NO){
            
            if ([self.contentViewController isKindOfClass:[UINavigationController class]]) {
                UINavigationController *navigationController = (UINavigationController *)self.contentViewController;
                if (navigationController.viewControllers.count == 1 &&  !navigationController.viewControllers[0].presentedViewController && !self.contentViewController.presentedViewController) {
                    [self presentLeftMenuViewController];
                    return;
                }
            }else{
                if(!self.contentViewController.presentedViewController){
                    [self presentLeftMenuViewController];
                    return;
                }
            }
        }else{
            
            if ([self.delegate conformsToProtocol:@protocol(EZSideMenuDelegate)] && [self.delegate respondsToSelector:@selector(sideMenu:pressesBegan:withEvent:)]) {
                if(![self.delegate sideMenu:self pressesBegan:presses withEvent:event]){
                    return;
                }
            }
            
        }
        self.toSuperMenu = YES;
    }
    [super pressesBegan:presses withEvent:event];
}

-(void)pressesChanged:(NSSet<UIPress *> *)presses withEvent:(UIPressesEvent *)event{
    if ( presses.anyObject.type == UIPressTypeMenu && !self.toSuperMenu) {
        return;
    }
    [super pressesChanged:presses withEvent:event];
}

-(void)pressesEnded:(NSSet<UIPress *> *)presses withEvent:(UIPressesEvent *)event{
    if ( presses.anyObject.type == UIPressTypeMenu && !self.toSuperMenu) {
        return;
    }
    [super pressesEnded:presses withEvent:event];
}


-(void)pressesCancelled:(NSSet<UIPress *> *)presses withEvent:(UIPressesEvent *)event{
    if ( presses.anyObject.type == UIPressTypeMenu && !self.toSuperMenu) {
        return;
    }
    [super pressesCancelled:presses withEvent:event];
}


#pragma mark -
#pragma mark UIFocusEnvironment

- (UIView *)preferredFocusedView
{
    if (self.visible == YES){
        self.contentViewContainer.userInteractionEnabled = NO;
        return self.leftMenuViewController.view;
    }else{
        self.contentViewContainer.userInteractionEnabled = YES;
        return self.contentViewController.view;
    }
}



@end

@implementation EZSideMenu (Animation)
- (void)flashMenu
{
    // Animate to deappear
    __typeof(&*self) __weak weakSelf = self;
    self.menuViewContainer.transform = CGAffineTransformScale(self.menuViewContainer.transform, 0.9, 0.9);
    [UIView animateWithDuration:0.5 animations:^{
        weakSelf.menuViewContainer.transform = CGAffineTransformIdentity;
    }];
    [UIView animateWithDuration:0.6 animations:^{
        weakSelf.menuViewContainer.alpha = 0;
    }];
    
    [UIView animateWithDuration:0.6 animations:^{
        weakSelf.menuViewContainer.alpha = 1;
    }];
}
@end

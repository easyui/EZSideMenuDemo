#import "EZSideMenu.h"
/////////////////start
BOOL EZSideMenuUIKitIsFlatMode() // 是否支持扁平
{
    static BOOL             isUIKitFlatMode = NO;
    static dispatch_once_t  onceToken;

    dispatch_once(&onceToken, ^{
            if (floor(NSFoundationVersionNumber) > 993.0) {
                // If your app is running in legacy mode, tintColor will be nil - else it must be set to some color.
                if (UIApplication.sharedApplication.keyWindow) {
                    isUIKitFlatMode = [UIApplication.sharedApplication.delegate.window performSelector:@selector(tintColor)] != nil;
                } else {
                    // Possible that we're called early on (e.g. when used in a Storyboard). Adapt and use a temporary window.
                    isUIKitFlatMode = [[UIWindow new] performSelector:@selector(tintColor)] != nil;
                }
            }
        });
    return isUIKitFlatMode;
}

////////////////////end

///////
@implementation UIViewController (EZSideMenu)

- (void)re_displayController:(UIViewController *)controller frame:(CGRect)frame
{
    [self addChildViewController:controller];
    controller.view.frame = frame;
    [self.view addSubview:controller.view];
    [controller didMoveToParentViewController:self];
}

- (void)re_hideController:(UIViewController *)controller
{
    [controller willMoveToParentViewController:nil];
    [controller.view removeFromSuperview];
    [controller removeFromParentViewController];
}

- (EZSideMenu *)sideMenuViewController
{
    UIViewController *iter = self.parentViewController;

    while (iter) {
        if ([iter isKindOfClass:[EZSideMenu class]]) {
            return (EZSideMenu *)iter;
        } else if (iter.parentViewController && (iter.parentViewController != iter)) {
            iter = iter.parentViewController;
        } else {
            iter = nil;
        }
    }

    return nil;
}

@end
///////

@interface EZSideMenu ()

@property (strong, nonatomic) UIImageView       *backgroundImageView;
@property (assign, nonatomic) BOOL              visible;
@property (assign, nonatomic) BOOL              leftMenuVisible;
@property (assign, nonatomic) BOOL              rightMenuVisible;
@property (assign, nonatomic) CGPoint           originalPoint;
@property (strong, nonatomic) UIButton          *contentButton; // 主界面上add上去的按钮
@property (assign, readwrite, nonatomic) BOOL   didNotifyDelegate;


@end

@implementation EZSideMenu

- (id)init
{
    self = [super init];

    if (self) {
        [self __commonInit];
    }

    return self;
}

- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super initWithCoder:decoder];

    if (self) {
        [self __commonInit];
    }

    return self;
}

- (void)__commonInit
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    self.wantsFullScreenLayout = YES;
#pragma clang diagnostic pop
    _animationDuration = 0.3f;
    _panGestureEnabled = YES;
    _interactivePopGestureRecognizerEnabled = YES;

    _scaleContentView = YES;
    _contentViewScaleValue = 0.7f;

    _scaleBackgroundImageView = YES;
    _backgroundImageViewScaleValue = 1.7f;
    _scaleMenuViewController = YES;
    _menuViewControllerScaleValue = 1.5;
    _gradientMenuViewController = YES;

    _panMinimumOpenThreshold = 60.0;

    _bouncesHorizontally = YES;
    _onlySlideFromEdge = YES;
    _slideEdgeValue = 25.f;

    _parallaxEnabled = YES;
    _parallaxMenuMinimumRelativeValue = -15;
    _parallaxMenuMaximumRelativeValue = 15;

    _parallaxContentMinimumRelativeValue = -25;
    _parallaxContentMaximumRelativeValue = 25;

    _menuView = [[UIView alloc] init];

    _contentViewShadowEnabled = YES;
    _contentViewShadowColor = [UIColor blackColor];
    _contentViewShadowOffset = CGSizeZero;
    _contentViewShadowOpacity = 0.4f;
    _contentViewShadowRadius = 8.0f;
}

// - (id)initWithContentViewController:(UIViewController *)contentViewController menuViewController:(UIViewController *)menuViewController
// {
//    self = [self init];
//
//    if (self) {
//        _contentViewController = contentViewController;
//        _menuViewController = menuViewController;
//
//    }
//
//    return self;
// }
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

- (void)viewDidLoad
{
    [super viewDidLoad];

    // 打开抽屉后主界面的中心点偏移
    if (!_contentViewInLandscapeOffsetCenterX) {
        _contentViewInLandscapeOffsetCenterX = CGRectGetHeight(self.view.frame) + 30.f;
    }

    if (!_contentViewInPortraitOffsetCenterX) {
        _contentViewInPortraitOffsetCenterX = CGRectGetWidth(self.view.frame) + 30.f;
    }

    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.backgroundImageView = ({
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
            imageView.image = self.backgroundImage;
            imageView.contentMode = UIViewContentModeScaleAspectFill;
            imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            imageView;
        });
    [self.view addSubview:self.backgroundImageView];
    self.contentButton = ({
            UIButton *button = [[UIButton alloc] initWithFrame:CGRectNull];
            [button addTarget:self action:@selector(hideMenuViewController) forControlEvents:UIControlEventTouchUpInside];
            button;
        });

    [self.view addSubview:self.menuView];
    self.menuView.frame = self.view.bounds;
    self.menuView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

    [self __displayController:self.leftMenuViewController];
    [self __displayController:self.rightMenuViewController];
    [self re_displayController:self.contentViewController frame:self.view.frame];

    if (self.gradientMenuViewController) {
        self.menuView.alpha = 0;
    }

    if (self.scaleBackgroundImageView) {
        self.backgroundImageView.transform = CGAffineTransformMakeScale(self.backgroundImageViewScaleValue, self.backgroundImageViewScaleValue);
    }

    [self __addMenuViewControllerMotionEffects];

    if (self.panGestureEnabled) {
        self.view.multipleTouchEnabled = NO;
        UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureRecognized:)];
        panGestureRecognizer.delegate = self; //////
        [self.view addGestureRecognizer:panGestureRecognizer];
    }

    [self __refreshContentViewShadow];

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

#pragma mark - action

- (void)presentLeftMenuViewController
{
    [self __presentMenuViewContainerWithMenuViewController:self.leftMenuViewController];
    [self __showLeftMenuViewController];
}

- (void)presentRightMenuViewController
{
    [self __presentMenuViewContainerWithMenuViewController:self.rightMenuViewController];
    [self __showRightMenuViewController];
}

- (void)__presentMenuViewContainerWithMenuViewController:(UIViewController *)menuViewController
{
    // 打开抽屉前初始化动画参数
    if (self.scaleBackgroundImageView) {
        self.backgroundImageView.transform = CGAffineTransformIdentity;
        self.backgroundImageView.frame = self.view.bounds;
        self.backgroundImageView.transform = CGAffineTransformMakeScale(self.backgroundImageViewScaleValue, self.backgroundImageViewScaleValue);
    }

    if (self.scaleMenuViewController) {
        self.menuView.transform = CGAffineTransformIdentity;
        self.menuView.frame = self.view.bounds;
        self.menuView.transform = CGAffineTransformMakeScale(self.menuViewControllerScaleValue, self.menuViewControllerScaleValue);
    }

    if (self.gradientMenuViewController) {
        self.menuView.alpha = 0;
    }

    if ([self.delegate conformsToProtocol:@protocol(EZSideMenuDelegate)] && [self.delegate respondsToSelector:@selector(sideMenu:willShowMenuViewController:)]) {
        [self.delegate sideMenu:self willShowMenuViewController:menuViewController];
    }
}

- (void)__showLeftMenuViewController
{
    if (!self.leftMenuViewController) {
        return;
    }

    self.leftMenuViewController.view.hidden = NO;
    self.rightMenuViewController.view.hidden = YES;
    [self.view.window endEditing:YES];   // 退出键盘等
    [self __addContentButton];

    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    [UIView animateWithDuration:self.animationDuration animations:^{
        if (self.scaleContentView) {
            self.contentViewController.view.transform = CGAffineTransformMakeScale(self.contentViewScaleValue, self.contentViewScaleValue);
        } else {
            self.contentViewController.view.transform = CGAffineTransformIdentity;
        }

        self.contentViewController.view.center = CGPointMake((UIDeviceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation]) ? self.contentViewInLandscapeOffsetCenterX : self.contentViewInPortraitOffsetCenterX), self.contentViewController.view.center.y);

        if (self.scaleBackgroundImageView) {
            self.backgroundImageView.transform = CGAffineTransformIdentity;
        }

        if (self.scaleMenuViewController) {
            self.menuView.transform = CGAffineTransformIdentity;
        }

        if (self.gradientMenuViewController) {
            self.menuView.alpha = 1.f;
        }
    } completion:^(BOOL finished) {
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
    [self __addContentButton];

    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    [UIView animateWithDuration:self.animationDuration animations:^{
        if (self.scaleContentView) {
            self.contentViewController.view.transform = CGAffineTransformMakeScale(self.contentViewScaleValue, self.contentViewScaleValue);
        } else {
            self.contentViewController.view.transform = CGAffineTransformIdentity;
        }

        self.contentViewController.view.center = CGPointMake((UIDeviceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation]) ? (-self.contentViewInLandscapeOffsetCenterX + CGRectGetHeight(self.view.frame)) : (-self.contentViewInPortraitOffsetCenterX + CGRectGetWidth(self.view.frame))), self.contentViewController.view.center.y);

        if (self.scaleBackgroundImageView) {
            self.backgroundImageView.transform = CGAffineTransformIdentity;
        }

        if (self.scaleMenuViewController) {
            self.menuView.transform = CGAffineTransformIdentity;
        }

        if (self.gradientMenuViewController) {
            self.menuView.alpha = 1.f;
        }
    } completion:^(BOOL finished) {
        [self __addContentViewControllerMotionEffects];

        if (!self.rightMenuVisible && [self.delegate conformsToProtocol:@protocol(EZSideMenuDelegate)] && [self.delegate respondsToSelector:@selector(sideMenu:didShowMenuViewController:)]) {
            [self.delegate sideMenu:self didShowMenuViewController:self.rightMenuViewController];
        }

        /////zyj
        self.visible = !(self.contentViewController.view.frame.size.width == self.view.bounds.size.width && self.contentViewController.view.frame.size.height == self.view.bounds.size.height && self.contentViewController.view.frame.origin.x == 0 && self.contentViewController.view.frame.origin.y == 0);
        self.rightMenuVisible = self.visible;
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
    }];

    [self __statusBarNeedsAppearanceUpdate];
}

- (void)hideMenuViewController
{
    BOOL rightMenuVisible = self.rightMenuVisible;

    [self.view.window endEditing:YES];

    if ([self.delegate conformsToProtocol:@protocol(EZSideMenuDelegate)] && [self.delegate respondsToSelector:@selector(sideMenu:willHideMenuViewController:)]) {
        [self.delegate sideMenu:self willHideMenuViewController:rightMenuVisible ? self.rightMenuViewController:self.leftMenuViewController];
    }

    self.visible = NO;
    self.leftMenuVisible = NO;
    self.rightMenuVisible = NO;
    [self.contentButton removeFromSuperview];                           // 记得移除按钮

    [[UIApplication sharedApplication] beginIgnoringInteractionEvents]; // 忽略所有事件
    [UIView animateWithDuration:self.animationDuration animations:^{
        self.contentViewController.view.transform = CGAffineTransformIdentity;
        self.contentViewController.view.frame = self.view.bounds;

        if (self.scaleBackgroundImageView) {
            self.backgroundImageView.transform = CGAffineTransformMakeScale(self.backgroundImageViewScaleValue, self.backgroundImageViewScaleValue);
        }

        if (self.scaleMenuViewController) {
            self.menuView.transform = CGAffineTransformMakeScale(self.menuViewControllerScaleValue, self.menuViewControllerScaleValue);
        }

        if (self.gradientMenuViewController) {
            self.menuView.alpha = 0;
        }

        if (self.parallaxEnabled) {
            IF_IOS7_OR_GREATER(
                for (UIMotionEffect * effect in self.contentViewController.view.motionEffects) {
                    [self.contentViewController.view removeMotionEffect:effect];
                }

                );
        }
    } completion:^(BOOL finished) {
        if (!self.visible && [self.delegate conformsToProtocol:@protocol(EZSideMenuDelegate)] && [self.delegate respondsToSelector:@selector(sideMenu:didHideMenuViewController:)]) {
            [self.delegate sideMenu:self didHideMenuViewController:rightMenuVisible ? self.rightMenuViewController:self.leftMenuViewController];
        }

        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
    }];
    [self __statusBarNeedsAppearanceUpdate];
}

- (void)__addContentButton
{
    if (self.contentButton.superview) {
        return;
    }

    self.contentButton.autoresizingMask = UIViewAutoresizingNone;
    self.contentButton.frame = self.contentViewController.view.bounds;
    self.contentButton.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.contentViewController.view addSubview:self.contentButton];
}

#pragma mark - animation

- (void)flashMenu
{
    // Animate to deappear
    __typeof(&*self) __weak weakSelf = self;
    self.menuView.transform = CGAffineTransformScale(self.menuView.transform, 0.9, 0.9);
    [UIView animateWithDuration:0.5 animations:^{
        weakSelf.menuView.transform = CGAffineTransformIdentity;
    }];
    [UIView animateWithDuration:0.6 animations:^{
        weakSelf.menuView.alpha = 0;
    }];

    [UIView animateWithDuration:0.6 animations:^{
        weakSelf.menuView.alpha = 1;
    }];
}

#pragma mark -
#pragma mark iOS 7 Motion Effects (Private)

- (void)__addMenuViewControllerMotionEffects
{
    if (self.parallaxEnabled) {
        IF_IOS7_OR_GREATER(
            for (UIMotionEffect *effect in self.menuView.motionEffects) {
                [self.menuView removeMotionEffect:effect];
            }

            UIInterpolatingMotionEffect *interpolationHorizontal = [[UIInterpolatingMotionEffect alloc]initWithKeyPath:@"center.x" type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
            interpolationHorizontal.minimumRelativeValue = @(self.parallaxMenuMinimumRelativeValue);
            interpolationHorizontal.maximumRelativeValue = @(self.parallaxMenuMaximumRelativeValue);

            UIInterpolatingMotionEffect *interpolationVertical = [[UIInterpolatingMotionEffect alloc]initWithKeyPath:@"center.y" type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
            interpolationVertical.minimumRelativeValue = @(self.parallaxMenuMinimumRelativeValue);
            interpolationVertical.maximumRelativeValue = @(self.parallaxMenuMaximumRelativeValue);

            [self.menuView addMotionEffect:interpolationHorizontal];
            [self.menuView addMotionEffect:interpolationVertical];
            );
    }
}

- (void)__addContentViewControllerMotionEffects
{
    if (self.parallaxEnabled) {
        IF_IOS7_OR_GREATER(
            for (UIMotionEffect *effect in self.contentViewController.view.motionEffects) {
                [self.contentViewController.view removeMotionEffect:effect];
            }

            [UIView animateWithDuration:0.2 animations:^{
                UIInterpolatingMotionEffect *interpolationHorizontal = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.x" type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
                interpolationHorizontal.minimumRelativeValue = @(self.parallaxContentMinimumRelativeValue);
                interpolationHorizontal.maximumRelativeValue = @(self.parallaxContentMaximumRelativeValue);

                UIInterpolatingMotionEffect *interpolationVertical = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.y" type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
                interpolationVertical.minimumRelativeValue = @(self.parallaxContentMinimumRelativeValue);
                interpolationVertical.maximumRelativeValue = @(self.parallaxContentMaximumRelativeValue);

                [self.contentViewController.view addMotionEffect:interpolationHorizontal];
                [self.contentViewController.view addMotionEffect:interpolationVertical];
            }];
            );
    }
}

#pragma mark -
#pragma mark UIGestureRecognizer Delegate (Private)

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    IF_IOS7_OR_GREATER(
        if (self.interactivePopGestureRecognizerEnabled && [self.contentViewController isKindOfClass:[UINavigationController class]]) {
            UINavigationController *navigationController = (UINavigationController *)self.contentViewController;

            if ((navigationController.viewControllers.count > 1) && navigationController.interactivePopGestureRecognizer.enabled) {
                return NO;
            }
        }

        );

    if (self.onlySlideFromEdge && [gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]] && !self.visible) {
        //        if (recognizer.state == UIGestureRecognizerStateBegan) {
        CGPoint startPoint = [touch locationInView:gestureRecognizer.view];

        //            CGPoint startPoint = [recognizer locationInView:self.contentViewController.view];
        BOOL isSideFromEdge;

        if ((self.leftMenuViewController && (startPoint.x < self.slideEdgeValue)) || (self.rightMenuViewController && (startPoint.x > self.view.frame.size.width - 20.0))) {
            isSideFromEdge = YES;
        } else {
            isSideFromEdge = NO;
        }

        //        }
        return isSideFromEdge;
    }

    return YES;
}

#pragma mark -
#pragma mark Pan gesture recognizer (Private)
- (void)panGestureRecognized:(UIPanGestureRecognizer *)recognizer
{
    /**
     *   //    CGPoint startPoint = [recognizer locationInView:self.view];
     *   //    NSLog(@"%@",NSStringFromCGPoint(startPoint));
     *   if (self.onlySlideFromEdge &&!self.visible) {
     *    if (recognizer.state == UIGestureRecognizerStateBegan) {
     *        CGPoint startPoint = [recognizer locationInView:self.contentViewController.view];
     *        if (startPoint.x < self.slideEdgeValue) {
     *            self.isSideFromEdge = YES;
     *        }else{
     *            self.isSideFromEdge = NO;
     *        }
     *    }
     *    if (!self.isSideFromEdge) {
     *        return;
     *    }
     *   }
     *
     *
     **/

    if ([self.delegate conformsToProtocol:@protocol(EZSideMenuDelegate)] && [self.delegate respondsToSelector:@selector(sideMenu:didRecognizePanGesture:)]) {
        [self.delegate sideMenu:self didRecognizePanGesture:recognizer];
    }

    if (!self.panGestureEnabled) {
        return;
    }

    CGPoint point = [recognizer translationInView:self.view];

    if (recognizer.state == UIGestureRecognizerStateBegan) {
        self.originalPoint = CGPointMake(self.contentViewController.view.center.x - CGRectGetWidth(self.contentViewController.view.bounds) / 2.0,
                self.contentViewController.view.center.y - CGRectGetHeight(self.contentViewController.view.bounds) / 2.0);                          // self.contentViewController.view.frame.origin;
        self.menuView.transform = CGAffineTransformIdentity;

        if (self.scaleBackgroundImageView) {
            self.backgroundImageView.transform = CGAffineTransformIdentity;
            self.backgroundImageView.frame = self.view.bounds;
        }

        if (self.scaleContentView) {
            self.backgroundImageView.transform = CGAffineTransformIdentity;
            self.menuView.frame = self.view.bounds;
        }

        [self __addContentButton];
        [self.view.window endEditing:YES];
        self.didNotifyDelegate = NO;
    }

    if (recognizer.state == UIGestureRecognizerStateChanged) {
        //        CGFloat delta = self.visible ? (point.x + self.originalPoint.x) / self.originalPoint.x : point.x / self.view.frame.size.width;
        CGFloat delta = 0;

        if (self.visible) {
            delta = self.originalPoint.x != 0 ? (point.x + self.originalPoint.x) / self.originalPoint.x : 0;
        } else {
            delta = point.x / self.view.frame.size.width;
        }

        delta = MIN(fabs(delta), 1.6);

        //        CGFloat contentViewScale = self.scaleContentView ? 1 - ((1 - self.contentViewScaleValue) * delta) : 1;
        CGFloat contentViewScale = self.scaleContentView ? 1 - ((1 - self.contentViewScaleValue) * delta) : 1;

        CGFloat backgroundViewScale = self.backgroundImageViewScaleValue - (0.7f * delta);
        CGFloat menuViewScale = self.menuViewControllerScaleValue - (0.5f * delta);

        if (!self.bouncesHorizontally) {
            contentViewScale = MAX(contentViewScale, self.contentViewScaleValue);
            backgroundViewScale = MAX(backgroundViewScale, 1.0);
            menuViewScale = MAX(menuViewScale, 1.0);
        }

        if (self.gradientMenuViewController) {
            self.menuView.alpha = delta;
        }

        if (self.scaleBackgroundImageView) {
            self.backgroundImageView.transform = CGAffineTransformMakeScale(backgroundViewScale, backgroundViewScale);
        }

        if (self.scaleMenuViewController) {
            self.menuView.transform = CGAffineTransformMakeScale(menuViewScale, menuViewScale);
        }

        if (self.scaleBackgroundImageView) {
            if (backgroundViewScale < 1) {
                self.backgroundImageView.transform = CGAffineTransformIdentity;
            }
        }

        if (!self.bouncesHorizontally && self.visible) {
            if (self.contentViewController.view.frame.origin.x > self.contentViewController.view.frame.size.width / 2.0) {
                point.x = MIN(0.0, point.x);
            }

            if (self.contentViewController.view.frame.origin.x < -(self.contentViewController.view.frame.size.width / 2.0)) {
                point.x = MAX(0.0, point.x);
            }
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
            self.contentViewController.view.transform = CGAffineTransformMakeScale(oppositeScale, oppositeScale);
            self.contentViewController.view.transform = CGAffineTransformTranslate(self.contentViewController.view.transform, point.x, 0);
        } else {
            self.contentViewController.view.transform = CGAffineTransformMakeScale(contentViewScale, contentViewScale);
            self.contentViewController.view.transform = CGAffineTransformTranslate(self.contentViewController.view.transform, point.x, 0);
        }

        self.leftMenuViewController.view.hidden = self.contentViewController.view.frame.origin.x < 0;
        self.rightMenuViewController.view.hidden = self.contentViewController.view.frame.origin.x > 0;

        if (!self.leftMenuViewController && (self.contentViewController.view.frame.origin.x > 0)) {
            self.contentViewController.view.transform = CGAffineTransformIdentity;
            self.contentViewController.view.frame = self.view.bounds;
            self.visible = NO;
            self.leftMenuVisible = NO;
        } else if (!self.rightMenuViewController && (self.contentViewController.view.frame.origin.x < 0)) {
            self.contentViewController.view.transform = CGAffineTransformIdentity;
            self.contentViewController.view.frame = self.view.bounds;
            self.visible = NO;
            self.rightMenuVisible = NO;
        }

        [self __statusBarNeedsAppearanceUpdate];
    }

    if (recognizer.state == UIGestureRecognizerStateEnded) {
        self.didNotifyDelegate = NO;

        if ((self.panMinimumOpenThreshold > 0) && (
                ((self.contentViewController.view.frame.origin.x < 0) && (self.contentViewController.view.frame.origin.x > -((NSInteger)self.panMinimumOpenThreshold))) ||
                ((self.contentViewController.view.frame.origin.x > 0) && (self.contentViewController.view.frame.origin.x < self.panMinimumOpenThreshold)))
            ) {
            [self hideMenuViewController];
        } else {
            if ([recognizer velocityInView:self.view].x > 0) { // 返回速度矢量
                if (self.contentViewController.view.frame.origin.x < 0) {
                    [self hideMenuViewController];
                } else {
                    if (self.leftMenuViewController) {
                        [self __showLeftMenuViewController];
                    }
                }
            } else {
                if (self.contentViewController.view.frame.origin.x < 20) {
                    if (self.rightMenuViewController) {
                        [self __showRightMenuViewController];
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

    if (self.backgroundImageView) {
        self.backgroundImageView.image = backgroundImage;
    }
}

- (void)setContentViewController:(UIViewController *)contentViewController
{
    if (!_contentViewController) {
        _contentViewController = contentViewController;
        return;
    }

    CGRect              frame = _contentViewController.view.frame;
    CGAffineTransform   transform = _contentViewController.view.transform;
    [self re_hideController:_contentViewController];
    _contentViewController = contentViewController;
    [self re_displayController:contentViewController frame:self.view.frame];
    contentViewController.view.transform = transform;
    contentViewController.view.frame = frame;

    [self __refreshContentViewShadow];

    if (self.visible) {
        [self __addContentViewControllerMotionEffects];
    }
}

- (void)setContentViewController:(UIViewController *)contentViewController animated:(BOOL)animated
{
    if (!animated) {
        [self setContentViewController:contentViewController];
    } else {
        contentViewController.view.alpha = 0;
        [self.contentViewController.view addSubview:contentViewController.view];
        [UIView animateWithDuration:self.animationDuration animations:^{
            contentViewController.view.alpha = 1;
        } completion:^(BOOL finished) {
            [contentViewController.view removeFromSuperview];
            [self setContentViewController:contentViewController];
        }];
    }
}

- (void)setLeftMenuViewController:(UIViewController *)leftMenuViewController
{
    if (!_leftMenuViewController) {
        _leftMenuViewController = leftMenuViewController;
        return;
    }

    [self re_hideController:_leftMenuViewController];
    _leftMenuViewController = leftMenuViewController;

    [self addChildViewController:self.leftMenuViewController];
    self.leftMenuViewController.view.frame = self.view.bounds;
    self.leftMenuViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.menuView addSubview:self.leftMenuViewController.view];
    [self.leftMenuViewController didMoveToParentViewController:self];

    [self __addMenuViewControllerMotionEffects];
    [self.view bringSubviewToFront:self.contentViewController.view];
}

- (void)setRightMenuViewController:(UIViewController *)rightMenuViewController
{
    if (!_rightMenuViewController) {
        _rightMenuViewController = rightMenuViewController;
        return;
    }

    [self re_hideController:_rightMenuViewController];
    _rightMenuViewController = rightMenuViewController;

    [self addChildViewController:self.rightMenuViewController];
    self.rightMenuViewController.view.frame = self.view.bounds;
    self.rightMenuViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.menuView addSubview:self.rightMenuViewController.view];
    [self.rightMenuViewController didMoveToParentViewController:self];

    [self __addMenuViewControllerMotionEffects];
    [self.view bringSubviewToFront:self.contentViewController.view];
}

#pragma mark -
#pragma mark Rotation handler

- (BOOL)shouldAutorotate
{
    return self.contentViewController.shouldAutorotate;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    if (self.visible) {
        self.menuView.bounds = self.view.bounds;
        self.contentViewController.view.transform = CGAffineTransformIdentity;
        self.contentViewController.view.frame = self.view.bounds;

        if (self.scaleContentView) {
            self.contentViewController.view.transform = CGAffineTransformMakeScale(self.contentViewScaleValue, self.contentViewScaleValue);
        } else {
            self.contentViewController.view.transform = CGAffineTransformIdentity;
        }

        CGPoint center;

        if (self.leftMenuVisible) {
            center = CGPointMake((UIDeviceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation]) ? self.contentViewInLandscapeOffsetCenterX : self.contentViewInPortraitOffsetCenterX), self.contentViewController.view.center.y);
        } else {
            center = CGPointMake((UIDeviceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation]) ? (-self.contentViewInLandscapeOffsetCenterX + CGRectGetHeight(self.view.frame)) : (-self.contentViewInPortraitOffsetCenterX) + CGRectGetWidth(self.view.frame)), self.contentViewController.view.center.y);
        }

        self.contentViewController.view.center = center;
    }
}

#pragma mark -
#pragma mark Status bar appearance management

- (void)__statusBarNeedsAppearanceUpdate
{
    // ios7刷新状态栏
    if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
        [UIView animateWithDuration:0.3f animations:^{
            [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
        }];
    }
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    UIStatusBarStyle statusBarStyle = UIStatusBarStyleDefault;

    IF_IOS7_OR_GREATER(
        statusBarStyle = self.visible ? (self.leftMenuVisible ? self.leftMenuViewController.preferredStatusBarStyle : self.rightMenuViewController.preferredStatusBarStyle) : self.contentViewController.preferredStatusBarStyle;

        if (self.contentViewController.view.frame.origin.y > 10) {
            statusBarStyle = self.leftMenuVisible ? self.leftMenuViewController.preferredStatusBarStyle : self.rightMenuViewController.preferredStatusBarStyle;
        } else {
            statusBarStyle = self.contentViewController.preferredStatusBarStyle;
        }

        );
    return statusBarStyle;
}

- (BOOL)prefersStatusBarHidden
{
    BOOL statusBarHidden = NO;

    IF_IOS7_OR_GREATER(
        statusBarHidden = self.visible ? (self.leftMenuVisible ? self.leftMenuViewController.prefersStatusBarHidden : self.rightMenuViewController.prefersStatusBarHidden) : self.contentViewController.prefersStatusBarHidden;

        if (self.contentViewController.view.frame.origin.y > 10) {
            statusBarHidden = (self.leftMenuVisible ? self.leftMenuViewController.prefersStatusBarHidden : self.rightMenuViewController.prefersStatusBarHidden);
        } else {
            statusBarHidden = self.contentViewController.prefersStatusBarHidden;
        }

        );
    return statusBarHidden;
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation
{
    UIStatusBarAnimation statusBarAnimation = UIStatusBarAnimationNone;

    IF_IOS7_OR_GREATER(
        statusBarAnimation = self.visible ? (self.leftMenuVisible ? self.leftMenuViewController.preferredStatusBarUpdateAnimation : self.rightMenuViewController.preferredStatusBarUpdateAnimation) : self.contentViewController.preferredStatusBarUpdateAnimation;

        if (self.contentViewController.view.frame.origin.y > 10) {
            statusBarAnimation = (self.leftMenuVisible ? self.leftMenuViewController.preferredStatusBarUpdateAnimation : self.rightMenuViewController.preferredStatusBarUpdateAnimation);
        } else {
            statusBarAnimation = self.contentViewController.preferredStatusBarUpdateAnimation;
        }

        );
    return statusBarAnimation;
}

#pragma mark -
#pragma mark private
- (void)__displayController:(UIViewController *)controller
{
    if (controller) {
        [self addChildViewController:controller];
        controller.view.frame = self.view.bounds;
        controller.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.menuView addSubview:controller.view];
        [controller didMoveToParentViewController:self];
    }
}

- (void)__refreshContentViewShadow
{
    if (self.contentViewShadowEnabled) {
        CALayer         *layer = self.contentViewController.view.layer;
        UIBezierPath    *path = [UIBezierPath bezierPathWithRect:layer.bounds];
        layer.shadowPath = path.CGPath;
        layer.shadowColor = self.contentViewShadowColor.CGColor;
        layer.shadowOffset = self.contentViewShadowOffset;
        layer.shadowOpacity = self.contentViewShadowOpacity;
        layer.shadowRadius = self.contentViewShadowRadius;
    }
}

@end
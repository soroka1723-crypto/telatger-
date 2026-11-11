#import <UIKit/UIKit.h>

// Lightweight visual-only controls attached to Telegram's existing window.
// This tweak does not create or replace application windows and does not
// access Telegram private APIs, networking, authentication, or message data.

@interface TLVOverlay : NSObject
@property(nonatomic, weak) UIWindow *hostWindow;
@property(nonatomic, strong) UIButton *launcherButton;
@property(nonatomic, strong) UIView *panelView;
+ (instancetype)shared;
- (void)installIfReady;
@end

@implementation TLVOverlay

+ (instancetype)shared {
    static TLVOverlay *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [TLVOverlay new];
    });
    return instance;
}

- (UIWindow *)activeKeyWindow {
    UIApplication *application = UIApplication.sharedApplication;
    if (@available(iOS 13.0, *)) {
        for (UIScene *scene in application.connectedScenes) {
            if (![scene isKindOfClass:[UIWindowScene class]] ||
                scene.activationState != UISceneActivationStateForegroundActive) continue;
            for (UIWindow *window in ((UIWindowScene *)scene).windows) {
                if (window.isKeyWindow && !window.hidden && window.rootViewController) return window;
            }
        }
    }
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    UIWindow *legacyWindow = application.keyWindow;
#pragma clang diagnostic pop
    return (legacyWindow && !legacyWindow.hidden) ? legacyWindow : nil;
}

- (void)installIfReady {
    if (![NSThread isMainThread]) {
        dispatch_async(dispatch_get_main_queue(), ^{ [self installIfReady]; });
        return;
    }

    UIWindow *window = [self activeKeyWindow];
    if (!window) return;
    if (self.launcherButton && self.hostWindow == window &&
        self.launcherButton.superview == window) return;

    [self.panelView removeFromSuperview];
    [self.launcherButton removeFromSuperview];
    self.panelView = nil;
    self.launcherButton = nil;
    self.hostWindow = window;

    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.translatesAutoresizingMaskIntoConstraints = NO;
    button.backgroundColor = [UIColor colorWithRed:0.48 green:0.35 blue:1 alpha:0.96];
    button.layer.cornerRadius = 26;
    button.layer.masksToBounds = YES;
    [button setTitle:@"✦" forState:UIControlStateNormal];
    [button setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:23 weight:UIFontWeightBold];
    [button addTarget:self action:@selector(showPanel) forControlEvents:UIControlEventTouchUpInside];
    [window addSubview:button];
    [NSLayoutConstraint activateConstraints:@[
        [button.widthAnchor constraintEqualToConstant:52],
        [button.heightAnchor constraintEqualToConstant:52],
        [button.trailingAnchor constraintEqualToAnchor:window.trailingAnchor constant:-15],
        [button.bottomAnchor constraintEqualToAnchor:window.safeAreaLayoutGuide.bottomAnchor constant:-105]
    ]];
    self.launcherButton = button;
}

- (void)showPanel {
    if (self.panelView || !self.hostWindow) return;

    UIView *shade = [[UIView alloc] init];
    shade.translatesAutoresizingMaskIntoConstraints = NO;
    shade.backgroundColor = [UIColor colorWithWhite:0 alpha:0.42];
    shade.accessibilityViewIsModal = YES;
    [self.hostWindow addSubview:shade];
    [NSLayoutConstraint activateConstraints:@[
        [shade.leadingAnchor constraintEqualToAnchor:self.hostWindow.leadingAnchor],
        [shade.trailingAnchor constraintEqualToAnchor:self.hostWindow.trailingAnchor],
        [shade.topAnchor constraintEqualToAnchor:self.hostWindow.topAnchor],
        [shade.bottomAnchor constraintEqualToAnchor:self.hostWindow.bottomAnchor]
    ]];
    self.panelView = shade;

    UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    UIVisualEffectView *card = [[UIVisualEffectView alloc] initWithEffect:blur];
    card.translatesAutoresizingMaskIntoConstraints = NO;
    card.layer.cornerRadius = 21;
    card.layer.masksToBounds = YES;
    [shade addSubview:card];
    [NSLayoutConstraint activateConstraints:@[
        [card.centerXAnchor constraintEqualToAnchor:shade.centerXAnchor],
        [card.centerYAnchor constraintEqualToAnchor:shade.centerYAnchor],
        [card.widthAnchor constraintEqualToConstant:300],
        [card.heightAnchor constraintEqualToConstant:340],
        [card.leadingAnchor constraintGreaterThanOrEqualToAnchor:shade.leadingAnchor constant:12],
        [card.trailingAnchor constraintLessThanOrEqualToAnchor:shade.trailingAnchor constant:-12]
    ]];

    UIStackView *stack = [[UIStackView alloc] init];
    stack.axis = UILayoutConstraintAxisVertical;
    stack.spacing = 13;
    stack.translatesAutoresizingMaskIntoConstraints = NO;
    [card.contentView addSubview:stack];
    [NSLayoutConstraint activateConstraints:@[
        [stack.topAnchor constraintEqualToAnchor:card.contentView.topAnchor constant:22],
        [stack.leadingAnchor constraintEqualToAnchor:card.contentView.leadingAnchor constant:20],
        [stack.trailingAnchor constraintEqualToAnchor:card.contentView.trailingAnchor constant:-20],
        [stack.bottomAnchor constraintLessThanOrEqualToAnchor:card.contentView.bottomAnchor constant:-18]
    ]];

    UILabel *title = [[UILabel alloc] init];
    title.text = @"TELATGER  ✦";
    title.textColor = UIColor.whiteColor;
    title.font = [UIFont systemFontOfSize:21 weight:UIFontWeightBold];
    [stack addArrangedSubview:title];

    UILabel *subtitle = [[UILabel alloc] init];
    subtitle.text = @"Visual settings";
    subtitle.textColor = [UIColor colorWithWhite:1 alpha:0.68];
    subtitle.font = [UIFont systemFontOfSize:13 weight:UIFontWeightMedium];
    [stack addArrangedSubview:subtitle];

    NSArray *names = @[@"Glass interface", @"Soft message shadows", @"Rounded panels", @"Accent animations"];
    for (NSString *name in names) {
        UILabel *label = [[UILabel alloc] init];
        label.text = name;
        label.textColor = UIColor.whiteColor;
        label.font = [UIFont systemFontOfSize:14 weight:UIFontWeightMedium];
        UISwitch *toggle = [[UISwitch alloc] init];
        toggle.onTintColor = [UIColor colorWithRed:0.48 green:0.35 blue:1 alpha:1];
        toggle.on = YES;
        UIStackView *row = [[UIStackView alloc] initWithArrangedSubviews:@[label, toggle]];
        row.axis = UILayoutConstraintAxisHorizontal;
        row.alignment = UIStackViewAlignmentCenter;
        row.distribution = UIStackViewDistributionEqualSpacing;
        [stack addArrangedSubview:row];
    }

    UIButton *close = [UIButton buttonWithType:UIButtonTypeSystem];
    [close setTitle:@"Close" forState:UIControlStateNormal];
    [close setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    close.backgroundColor = [UIColor colorWithRed:0.48 green:0.35 blue:1 alpha:1];
    close.layer.cornerRadius = 12;
    close.contentEdgeInsets = UIEdgeInsetsMake(10, 18, 10, 18);
    [close addTarget:self action:@selector(closePanel) forControlEvents:UIControlEventTouchUpInside];
    [stack addArrangedSubview:close];
}

- (void)closePanel {
    [self.panelView removeFromSuperview];
    self.panelView = nil;
}

- (void)applicationDidBecomeActive:(NSNotification *)note {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)),
                   dispatch_get_main_queue(), ^{
        [self installIfReady];
    });
}
@end

%ctor {
    @autoreleasepool {
        // Defer UIKit access until the main run loop is available.
        dispatch_async(dispatch_get_main_queue(), ^{
            TLVOverlay *overlay = [TLVOverlay shared];
            [[NSNotificationCenter defaultCenter] addObserver:overlay
                                                     selector:@selector(applicationDidBecomeActive:)
                                                         name:UIApplicationDidBecomeActiveNotification
                                                       object:nil];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)),
                           dispatch_get_main_queue(), ^{
                [overlay installIfReady];
            });
        });
    }
}

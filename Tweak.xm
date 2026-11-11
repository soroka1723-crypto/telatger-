#import <UIKit/UIKit.h>

// Lightweight visual-only overlay.
// No Telegram private APIs, networking, authentication, or message storage.

@interface TLVOverlayWindow : UIWindow
@end

@implementation TLVOverlayWindow
- (BOOL)canBecomeKeyWindow { return NO; }

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *hit = [super hitTest:point withEvent:event];
    // Let Telegram receive touches everywhere except our visible controls.
    if (hit == self.rootViewController.view) return nil;
    return hit;
}
@end

@interface TLVOverlayController : UIViewController
@property(nonatomic, strong) UIButton *launcherButton;
@property(nonatomic, strong) UIView *shadeView;
@property(nonatomic, strong) UIVisualEffectView *card;
@end

@implementation TLVOverlayController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.clearColor;

    self.launcherButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.launcherButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.launcherButton.backgroundColor = [UIColor colorWithRed:0.48 green:0.35 blue:1 alpha:0.96];
    self.launcherButton.layer.cornerRadius = 27;
    self.launcherButton.layer.masksToBounds = YES;
    [self.launcherButton setTitle:@"✦" forState:UIControlStateNormal];
    [self.launcherButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    self.launcherButton.titleLabel.font = [UIFont systemFontOfSize:24 weight:UIFontWeightBold];
    [self.launcherButton addTarget:self action:@selector(showPanel) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.launcherButton];

    [NSLayoutConstraint activateConstraints:@[
        [self.launcherButton.widthAnchor constraintEqualToConstant:54],
        [self.launcherButton.heightAnchor constraintEqualToConstant:54],
        [self.launcherButton.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-16],
        [self.launcherButton.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor constant:-110]
    ]];
}

- (void)showPanel {
    if (self.shadeView) return;

    UIView *shade = [[UIView alloc] init];
    shade.translatesAutoresizingMaskIntoConstraints = NO;
    shade.backgroundColor = [UIColor colorWithWhite:0 alpha:0.38];
    self.shadeView = shade;
    [self.view addSubview:shade];

    [NSLayoutConstraint activateConstraints:@[
        [shade.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [shade.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [shade.topAnchor constraintEqualToAnchor:self.view.topAnchor],
        [shade.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor]
    ]];

    UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    UIVisualEffectView *card = [[UIVisualEffectView alloc] initWithEffect:blur];
    card.translatesAutoresizingMaskIntoConstraints = NO;
    card.layer.cornerRadius = 22;
    card.layer.masksToBounds = YES;
    self.card = card;
    [shade addSubview:card];

    [NSLayoutConstraint activateConstraints:@[
        [card.centerXAnchor constraintEqualToAnchor:shade.centerXAnchor],
        [card.centerYAnchor constraintEqualToAnchor:shade.centerYAnchor],
        [card.widthAnchor constraintEqualToConstant:300],
        [card.heightAnchor constraintEqualToConstant:350],
        [card.leadingAnchor constraintGreaterThanOrEqualToAnchor:shade.leadingAnchor constant:10],
        [card.trailingAnchor constraintLessThanOrEqualToAnchor:shade.trailingAnchor constant:-10]
    ]];

    UIStackView *stack = [[UIStackView alloc] init];
    stack.axis = UILayoutConstraintAxisVertical;
    stack.spacing = 14;
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
    title.font = [UIFont systemFontOfSize:22 weight:UIFontWeightBold];
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
    close.translatesAutoresizingMaskIntoConstraints = NO;
    [close setTitle:@"Close" forState:UIControlStateNormal];
    [close setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    close.backgroundColor = [UIColor colorWithRed:0.48 green:0.35 blue:1 alpha:1];
    close.layer.cornerRadius = 12;
    close.contentEdgeInsets = UIEdgeInsetsMake(11, 18, 11, 18);
    [close addTarget:self action:@selector(closePanel) forControlEvents:UIControlEventTouchUpInside];
    [stack addArrangedSubview:close];
}

- (void)closePanel {
    [self.shadeView removeFromSuperview];
    self.shadeView = nil;
    self.card = nil;
}

@end

@interface TLVLauncher : NSObject
@property(nonatomic, strong) TLVOverlayWindow *window;
+ (instancetype)shared;
- (void)installIfReady;
@end

@implementation TLVLauncher

+ (instancetype)shared {
    static TLVLauncher *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [TLVLauncher new];
    });
    return instance;
}

- (void)installIfReady {
    if (self.window) return;

    UIWindowScene *activeScene = nil;
    for (UIScene *scene in UIApplication.sharedApplication.connectedScenes) {
        if ([scene isKindOfClass:[UIWindowScene class]] &&
            scene.activationState == UISceneActivationStateForegroundActive) {
            activeScene = (UIWindowScene *)scene;
            break;
        }
    }
    if (!activeScene) return;

    TLVOverlayWindow *overlay = [[TLVOverlayWindow alloc] initWithWindowScene:activeScene];
    overlay.frame = activeScene.coordinateSpace.bounds;
    overlay.windowLevel = UIWindowLevelNormal + 1;
    overlay.backgroundColor = UIColor.clearColor;
    overlay.rootViewController = [TLVOverlayController new];
    overlay.hidden = NO;
    self.window = overlay;
}

- (void)applicationBecameActive:(NSNotification *)notification {
    if (self.window) return;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)),
                   dispatch_get_main_queue(), ^{
        [self installIfReady];
    });
}

@end

%ctor {
    @autoreleasepool {
        // One delayed install after launch; no retry loop and no launch-time UI work.
        dispatch_async(dispatch_get_main_queue(), ^{
            TLVLauncher *launcher = [TLVLauncher shared];
            [[NSNotificationCenter defaultCenter] addObserver:launcher
                                                     selector:@selector(applicationBecameActive:)
                                                         name:UIApplicationDidBecomeActiveNotification
                                                       object:nil];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(8 * NSEC_PER_SEC)),
                           dispatch_get_main_queue(), ^{
                [launcher installIfReady];
            });
        });
    }
}

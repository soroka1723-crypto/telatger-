#import <UIKit/UIKit.h>

// Visual-only overlay. No Telegram networking, account, authentication,
// message database, or private Telegram APIs are accessed.

@interface TLVPanelController : UIViewController
@property(nonatomic, strong) UIVisualEffectView *card;
@end

@implementation TLVPanelController
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithWhite:0 alpha:0.28];
    UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemMaterialDark];
    self.card = [[UIVisualEffectView alloc] initWithEffect:blur];
    self.card.translatesAutoresizingMaskIntoConstraints = NO;
    self.card.layer.cornerRadius = 22;
    self.card.clipsToBounds = YES;
    [self.view addSubview:self.card];
    [NSLayoutConstraint activateConstraints:@[
        [self.card.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [self.card.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor],
        [self.card.widthAnchor constraintEqualToConstant:300],
        [self.card.heightAnchor constraintEqualToConstant:360]
    ]];

    UIStackView *stack = [[UIStackView alloc] init];
    stack.axis = UILayoutConstraintAxisVertical;
    stack.spacing = 15;
    stack.translatesAutoresizingMaskIntoConstraints = NO;
    [self.card.contentView addSubview:stack];
    [NSLayoutConstraint activateConstraints:@[
        [stack.topAnchor constraintEqualToAnchor:self.card.contentView.topAnchor constant:22],
        [stack.leadingAnchor constraintEqualToAnchor:self.card.contentView.leadingAnchor constant:20],
        [stack.trailingAnchor constraintEqualToAnchor:self.card.contentView.trailingAnchor constant:-20]
    ]];

    UILabel *title = [[UILabel alloc] init];
    title.text = @"TELATGER  ✦";
    title.textColor = UIColor.whiteColor;
    title.font = [UIFont systemFontOfSize:22 weight:UIFontWeightBold];
    [stack addArrangedSubview:title];

    UILabel *subtitle = [[UILabel alloc] init];
    subtitle.text = @"Visual settings";
    subtitle.textColor = [UIColor colorWithWhite:1 alpha:0.65];
    subtitle.font = [UIFont systemFontOfSize:13 weight:UIFontWeightMedium];
    [stack addArrangedSubview:subtitle];

    NSArray *names = @[@"Glass interface", @"Soft message shadows", @"Rounded panels", @"Accent animations"];
    for (NSString *name in names) {
        UISwitch *toggle = [[UISwitch alloc] init];
        toggle.onTintColor = [UIColor colorWithRed:0.48 green:0.35 blue:1 alpha:1];
        toggle.on = YES;
        UILabel *label = [[UILabel alloc] init];
        label.text = name;
        label.textColor = UIColor.whiteColor;
        label.font = [UIFont systemFontOfSize:15 weight:UIFontWeightMedium];
        UIStackView *row = [[UIStackView alloc] initWithArrangedSubviews:@[label, toggle]];
        row.axis = UILayoutConstraintAxisHorizontal;
        row.alignment = UIStackViewAlignmentCenter;
        [stack addArrangedSubview:row];
    }

    UIButton *close = [UIButton buttonWithType:UIButtonTypeSystem];
    [close setTitle:@"Close" forState:UIControlStateNormal];
    [close setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    close.backgroundColor = [UIColor colorWithRed:0.48 green:0.35 blue:1 alpha:1];
    close.layer.cornerRadius = 13;
    close.contentEdgeInsets = UIEdgeInsetsMake(11, 18, 11, 18);
    [close addTarget:self action:@selector(closePanel) forControlEvents:UIControlEventTouchUpInside];
    [stack addArrangedSubview:close];
}
- (void)closePanel { self.view.window.hidden = YES; }
@end

@interface TLVLauncher : NSObject
@property(nonatomic, strong) UIWindow *window;
@property(nonatomic, strong) UIButton *button;
@property(nonatomic, strong) UIWindow *panelWindow;
+ (instancetype)shared;
- (void)show;
@end

@implementation TLVLauncher
+ (instancetype)shared { static TLVLauncher *x; static dispatch_once_t once; dispatch_once(&once, ^{ x=[TLVLauncher new]; }); return x; }
- (void)install {
    if (self.window) return;
    UIWindowScene *scene = nil;
    for (UIScene *s in UIApplication.sharedApplication.connectedScenes) if ([s isKindOfClass:UIWindowScene.class] && s.activationState == UISceneActivationStateForegroundActive) { scene=(UIWindowScene *)s; break; }
    if (!scene) return;
    self.window = [[UIWindow alloc] initWithWindowScene:scene];
    self.window.frame = CGRectMake(0, 0, 58, 58);
    self.window.windowLevel = UIWindowLevelAlert - 2;
    self.window.backgroundColor = UIColor.clearColor;
    self.window.rootViewController = [UIViewController new];
    self.button = [UIButton buttonWithType:UIButtonTypeSystem];
    self.button.frame = self.window.bounds;
    self.button.backgroundColor = [UIColor colorWithRed:0.48 green:0.35 blue:1 alpha:0.94];
    self.button.layer.cornerRadius = 29;
    [self.button setTitle:@"✦" forState:UIControlStateNormal];
    [self.button setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    self.button.titleLabel.font = [UIFont systemFontOfSize:25 weight:UIFontWeightBold];
    [self.button addTarget:self action:@selector(show) forControlEvents:UIControlEventTouchUpInside];
    [self.window.rootViewController.view addSubview:self.button];
    self.window.hidden = NO;
    self.window.frame = CGRectMake(UIScreen.mainScreen.bounds.size.width - 72, UIScreen.mainScreen.bounds.size.height * 0.55, 58, 58);
}
- (void)show {
    UIWindowScene *scene = self.window.windowScene;
    if (!scene) return;
    self.panelWindow = [[UIWindow alloc] initWithWindowScene:scene];
    self.panelWindow.frame = UIScreen.mainScreen.bounds;
    self.panelWindow.windowLevel = UIWindowLevelAlert;
    self.panelWindow.backgroundColor = UIColor.clearColor;
    self.panelWindow.rootViewController = [TLVPanelController new];
    self.panelWindow.hidden = NO;
}
@end

%ctor {
    @autoreleasepool {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [[TLVLauncher shared] install];
        });
    }
}

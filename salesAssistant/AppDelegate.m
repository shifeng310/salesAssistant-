//
//  AppDelegate.m
//  salesAssistant
//
//  Created by feng on 7/10/13.
//  Copyright (c) 2013 feng. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <AudioToolbox/AudioToolbox.h>
#import "AppDelegate.h"
#import "SidebarViewController.h"
#import "RRToken.h"
#import "RRLoginController.h"
#import "AppDelegate.h"
#import "RRLoginModel.h"

NSString *pushStatus ()
{
	return [[UIApplication sharedApplication] enabledRemoteNotificationTypes] ?
	@"Notifications were active for this application" :
	@"Remote notifications were not active for this application";
}

static AppDelegate *instance = nil;

@implementation AppDelegate
@synthesize viewController;
@synthesize loginController;
@synthesize window;
@synthesize pushToken;

+ (AppDelegate *) getInstance
{
	return instance;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    if ([[launchOptions objectForKey:@"UIApplicationLaunchOptionsRemoteNotificationKey"] objectForKey:@"aps"])
    {
        aps_dic = [NSDictionary dictionaryWithDictionary:[[launchOptions objectForKey:@"UIApplicationLaunchOptionsRemoteNotificationKey"] objectForKey:@"aps"]];
    }
    is_active = YES;
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
	//[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque animated:NO];

#if !(TARGET_IPHONE_SIMULATOR)
    [self confirmationWasHidden:nil];
#endif

    // 创建，初始化UIwindow窗口，并指向给window变量；
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    instance = self;
    [self check];
    return YES;
   
}

- (void) confirmationWasHidden: (NSNotification *) notification
{
    if ([[[UIDevice currentDevice] systemVersion] floatValue]>=5.0)
    {
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationType)(UIRemoteNotificationTypeBadge|UIRemoteNotificationTypeAlert|UIRemoteNotificationTypeSound|UIRemoteNotificationTypeNewsstandContentAvailability)];
    }
    
    else
    {
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationType)(UIRemoteNotificationTypeBadge|UIRemoteNotificationTypeAlert|UIRemoteNotificationTypeSound)];
    }
    
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
}

// Retrieve the device token
// 保存deviceToken到应用服务器数据库中

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    if (![deviceToken length])
    {
        return;
    }
    pushToken = [[deviceToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    pushToken = [pushToken stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSLog(@"%@",pushToken);
    
}

// Provide a user explanation for when the registration fails
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
	NSString *status = [NSString stringWithFormat:@"%@\nRegistration  failed.\n\nError: %@", pushStatus(), [error localizedDescription]];
    NSLog(@"Error in registration. Error: %@", error);
    NSLog(@"%@",status);
}

// Handle an actual notification
// 处理推送消息
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    NSString * messageType = [[userInfo objectForKey:@"aps"]  objectForKey:@"type"];
    if (is_active)
    {
        NSBundle *mainBundle = [NSBundle mainBundle];
        NSURL *sounduRL = [NSURL fileURLWithPath:[mainBundle pathForResource:@"beep-beep" ofType:@"aiff"] isDirectory:NO];
        SystemSoundID systemSoundID;
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)(sounduRL), &systemSoundID);
        AudioServicesPlaySystemSound(systemSoundID);
        [self showLable:messageType];
        return;
    }
    
    if (aps_dic)
    {
        aps_dic = nil;
    }
    aps_dic = [NSDictionary dictionaryWithDictionary:[userInfo objectForKey:@"aps"]];
    [self handleNotification:messageType];
}

- (void) handleNotification:(NSString *)type
{
    //创建，初始化视图控制器，创建SidebarViewController对象的实例viewController，并将其初始化；
    self.viewController = [[SidebarViewController alloc] initWithNibName:@"SidebarViewController" bundle:nil];
    if ([type isEqualToString:@"1"]) {
        viewController.selectIndex = 1;     //将viewController视图控制器对象，赋值给rootviewController；
    }
    else if([type isEqualToString:@"2"])
    {
        viewController.selectIndex = 4;     //将viewController视图控制器对象，赋值给rootviewController；
    }

    self.window.rootViewController = self.viewController;
    //让window可视化；
    [self.window makeKeyAndVisible];

}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    is_active = YES;
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    is_active = NO;
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    is_active = YES;

}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void) startMainTab
{
    //创建，初始化视图控制器，创建SidebarViewController对象的实例viewController，并将其初始化；
    self.viewController = [[SidebarViewController alloc] initWithNibName:@"SidebarViewController" bundle:nil];
    //将viewController视图控制器对象，赋值给rootviewController；
    self.window.rootViewController = self.viewController;
    //让window可视化；
    [self.window makeKeyAndVisible];
    if ([aps_dic count])
    {
        [self performSelector:@selector(handleNotification) withObject:nil afterDelay:1.0f];
    }
}

#pragma mark -
#pragma mark UIAlertViewDelegate

- (void) alert: (NSString*)title message:(NSString*)message
{
    UIAlertView *sAlert = [[UIAlertView alloc] initWithTitle:title
													 message:message
													delegate:self
										   cancelButtonTitle:@"关闭"
										   otherButtonTitles:nil];
    [sAlert show];
}


- (void) didLoginSuccess:(id)sender
{
    [self startMainTab];
}

- (void) check
{
    //判断本地是否已经保存了用户名
    if ([RRToken check]) {
        
        //本地包含用户名，直接进入操作视图
        [self startMainTab];
    }
    else{
        // 本地没用用户名跳转到登陆界面
        
        //通过初始化将loginController类绑定RRlogin.xib文件，显示登陆界面的操作；
        self.loginController = [[RRLoginController alloc] initWithNibName:@"RRLogin" bundle:nil];
        self.loginController.delegate = self;
        self.window.rootViewController = self.loginController;
        [self.window makeKeyAndVisible];
        
    }
}

- (void)showLable:(NSString *)type
{
    [[UIApplication sharedApplication].keyWindow setWindowLevel:UIWindowLevelAlert];
    [[UIApplication sharedApplication].keyWindow setBackgroundColor:[UIColor clearColor]];
    [self.viewController.navigationController.navigationBar setFrame:CGRectMake(0, 0, 320, 44)];
    signLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 20)];
    [signLabel setBackgroundColor:[UIColor blackColor]];
    if([type isEqualToString:@"1"])
    {
        [signLabel setText:@"您有一条新分配工单,请注意及时处理!"];
    }
    else if([type isEqualToString:@"2"])
    {
        [signLabel setText:@"您有一条新系统消息,请注意及时处理!"];
    }
    
    [signLabel setTextColor:[UIColor orangeColor]];
    [signLabel setTextAlignment:NSTextAlignmentCenter];
    [signLabel setFont:[UIFont systemFontOfSize:13]];
    [[UIApplication sharedApplication].keyWindow addSubview:signLabel];
    
    CATransition *animation = [CATransition animation];
    animation.delegate = self;
    animation.duration = 0.3f;
    animation.type = kCATransitionMoveIn;
    animation.subtype = kCATransitionFromRight;
    [[signLabel layer] addAnimation:animation forKey:@"animation"];
    [UIView commitAnimations];
    
    [self performSelector:@selector(dismissLable) withObject:nil afterDelay:5.0f];

}
- (void)dismissLable
{
    [signLabel setAlpha:0];
    CATransition *transiton = [CATransition animation];
    transiton.duration = 0.5f;
    transiton.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transiton.type = kCATransitionFade;
    transiton.subtype = kCATransitionFromRight;
    [[signLabel layer] addAnimation:transiton forKey:@"transiton"];
    [UIView commitAnimations];
    [self performSelector:@selector(animationLableFinished:) withObject:self afterDelay:0.5f];
}

- (void) animationLableFinished: (id) sender
{
	[signLabel removeFromSuperview];
	[[UIApplication sharedApplication].keyWindow setWindowLevel:UIWindowLevelNormal];
}


@end

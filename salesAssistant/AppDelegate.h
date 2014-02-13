//
//  AppDelegate.h
//  salesAssistant
//
//  Created by feng on 7/10/13.
//  Copyright (c) 2013 feng. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SidebarViewController;
@class RRLoginController;

@interface AppDelegate : UIResponder <UIApplicationDelegate>
{
    NSDictionary			*aps_dic;
    BOOL                    is_active;
    UILabel                 *signLabel;
    NSString                  *pushToken;
    BOOL                    is_loading;
}

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) SidebarViewController *viewController;
@property (strong, nonatomic) RRLoginController *loginController;
@property (nonatomic, copy) NSString *pushToken;

+ (AppDelegate *) getInstance;  

- (void) check;

- (void) startMainTab;

- (void) alert:(NSString*)title message:(NSString*)message;

@end

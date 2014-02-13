//
//  ProfileEditViewController.m
//  salesAssistant
//
//  Created by 方鸿灏 on 13-7-22.
//  Copyright (c) 2013年 feng. All rights reserved.
//

#import "ProfileEditViewController.h"
#import "SidebarViewController.h"
#import "RoadRover.h"
#import "RRToken.h"
#import "RRLoader.h"
#import "RRAlertView.h"
#import "RWShowView.h"

@interface ProfileEditViewController ()

@end

@implementation ProfileEditViewController
//@synthesize tf_newName;
@synthesize tf_newNo;
@synthesize tf_newPassWord1;
@synthesize tf_newPassWord2;
@synthesize lb_name;
@synthesize bg_view;
@synthesize im_bg;
@synthesize scroll_view;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    // 父类调用子类的方法；
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"background_view.png"]]];
    [self.bg_view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"background_view.png"]]];
   // [self.view setBackgroundColor:[UIImage imageNamed:[@"background_view.png"]];
    self.title = @"修改资料";
    
    btn_fold_left = [UIButton buttonWithType:UIButtonTypeCustom];
    // ios7 界面兼容问题
    if([[[UIDevice currentDevice] systemVersion] floatValue]>=7.0)
    {
        [btn_fold_left setImage:[UIImage imageNamed:@"menu_icon_ios7.png"] forState:UIControlStateNormal];
    }
    else
    {
       [btn_fold_left setImage:[UIImage imageNamed:@"menu_icon"] forState:UIControlStateNormal];
    }
    //
    
    [btn_fold_left setFrame:CGRectMake(5.0f, 2.0f, 50.0f, 40.0f)];
    [btn_fold_left addTarget:self action:@selector(showLeftSideBar:) forControlEvents:UIControlEventTouchUpInside];
    
    scroll_view.frame = CGRectMake(0.0f, 0.0f, 320.0f, [[UIScreen mainScreen]bounds].size.height);
    bg_view.frame = CGRectMake(0.0f, 0.0f, 320.0f, [[UIScreen mainScreen]bounds].size.height);
    [scroll_view addSubview:bg_view];
    scroll_view.scrollEnabled = NO;
    scroll_view.contentSize = CGSizeMake(scroll_view.frame.size.width, scroll_view.frame.size.height * 1.5);
    scroll_view.showsHorizontalScrollIndicator = NO;
    scroll_view.showsVerticalScrollIndicator = NO;
    
    im_bg.frame = CGRectMake(0, 0, 320, 25);

   
    lb_name.text = [[RRToken getInstance] getProperty:@"username"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar addSubview:btn_fold_left];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [active_tf resignFirstResponder];
    [btn_fold_left removeFromSuperview];
}

- (void)dealloc
{
    tf_newName = nil;
    tf_newNo = nil;
    tf_newPassWord1 = nil;
    tf_newPassWord2 = nil;
    lb_name = nil;
    bg_view = nil;
    scroll_view = nil;
    im_bg = nil;
    active_tf = nil;
    self.view = nil;
}

- (IBAction)btn_submit:(id)sender
{
    [active_tf resignFirstResponder];
    [self scrollViewDown];

    if (passWord1 && (![passWord1 isEqualToString:passWord2]))
    {
        [RRAlertView show:@"两次输入的密码不一致!"];
        return;
    }
    
    if (newTel && ![self isValidateMobile:newTel])
    {
        [RRAlertView show:@"电话号码格式不正确!必须是标准手机号码!"];
        return;
    }
    
    [self save];
}

-(BOOL) isValidateMobile:(NSString *)mobile
{
    //手机号以13， 15，18开头，八个 \d 数字字符
    NSString *phoneRegex = @"^((13[0-9])|(15[^4,\\D])|(18[0,0-9]))\\d{8}$";
    NSPredicate *phoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",phoneRegex];
    return [phoneTest evaluateWithObject:mobile];
}

#pragma mark -

- (void)showLeftSideBar:(id)sender
{
    if ([[SidebarViewController share] respondsToSelector:@selector(showSideBarControllerWithDirection:)]) {
        [[SidebarViewController share] showSideBarControllerWithDirection:SideBarShowDirectionLeft];
    }
}

#pragma mark -
#pragma mark UITextField Delegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    UITextField *back_tf = (UITextField *)[self.bg_view viewWithTag:textField.tag+1];
	[textField resignFirstResponder];
    if (textField.tag < 14)
    {
        [back_tf becomeFirstResponder];
    }
    
    else
    {
        [self scrollViewDown];
    }
	return NO;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    active_tf = textField;
    if ([[UIScreen mainScreen] bounds].size.height == 568)
    {
        if ([textField tag] >= 14)
        {
            [self scrollViewUp];
        }
        
    }
    
    else if ([textField tag] >= 13)
    {
        [self scrollViewUp];
    }
    
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if ([textField.text length] == 0)
    {
        return;
    }
    
    switch ([textField tag]) {
        case 11:
            passWord1 = textField.text;
            break;
        case 12:
            passWord2 = textField.text;
            break;
//        case 13:
//            newName = textField.text;
//            break;
        case 14:
            newTel = textField.text;
            break;
        default:
            break;
    }
}

// 设置滑动页面，当键盘覆盖掉显示区域，可以启动滑动界面
- (void)scrollViewUp
{
    scroll_view.scrollEnabled = YES;
    float ext_height = active_tf.frame.origin.y - 50;
    CGRect frame = CGRectMake(0.0f, ext_height, 320.0f, [[UIScreen mainScreen] bounds].size.height);
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.20];
    [scroll_view scrollRectToVisible:frame animated:YES];
    [UIView commitAnimations];
}

- (void)scrollViewDown
{
    scroll_view.scrollEnabled = NO;
    CGRect frame = CGRectMake(0.0f, 0.0f, 320.0f, [[UIScreen mainScreen] bounds].size.height);
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.20];
    [scroll_view scrollRectToVisible:frame animated:YES];
    [UIView commitAnimations];

}

// 保存修改的数据，向服务器更新修改数据；
//
- (void) save
{
    if (is_loading)
	{
		return;
	}
    
    [RWShowView show:@"loading"];
	is_loading = YES;
	NSString *full_url = [NSString stringWithFormat:@"%@%@", BASE_URL, SETTING_URL];
	
	RRURLRequest *req = [[RRURLRequest alloc] initWithURLString:full_url];
	[req setParam:[[RRToken getInstance] getProperty:@"token"] forKey:@"token"];
    if ([passWord1 length] && [passWord2 length] && ((NSNull *)passWord1 != [NSNull null]))
    {
        [req setParam:passWord1 forKey:@"user[password]"];
    }
//    if ([newName length] && ((NSNull *)newName != [NSNull null]))
//    {
//        [req setParam:newName forKey:@"user[username]"];
//    }
    if ([newTel length] != 0)
    {
        [req setParam:newTel forKey:@"user[telnumber]"];
    }
	[req setHTTPMethod:@"POST"];
	
	RRLoader *loader = [[RRLoader alloc] initWithRequest:req];
	[loader addNotificationListener:RRLOADER_FAIL target:self action:@selector(onLoadFail:)];
	[loader addNotificationListener:RRLOADER_COMPLETE target:self action:@selector(onSave:)];
	[loader loadwithTimer];
}

- (void) onSave:(NSNotification *)notify
{
    is_loading = NO;
    [RWShowView closeAlert];
	RRLoader *loader = (RRLoader *)[notify object];
	NSDictionary *json = [loader getJSONData];
	[loader removeNotificationListener:RRLOADER_FAIL target:self];
	[loader removeNotificationListener:RRLOADER_COMPLETE target:self];
	if (![[json objectForKey:@"success"] boolValue])
	{
        [RWShowView closeAlert];
        [RRAlertView show:@"网络链接失败!" ];
  		return;
	}
    
    [RRAlertView show:@"保存成功!" ];
    
//    if (newName)
//    {
//        RRToken *token = [RRToken getInstance];
//        [token setProperty:newName forKey:@"username"];
//        [token saveToFile];
//        lb_name.text = [token getProperty:@"username"];
//    }
}

- (void) onLoadFail:(NSNotification *)notify
{
    is_loading = NO;
    [RWShowView closeAlert];
    [RRAlertView show:@"网络链接失败!" ];
  	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end

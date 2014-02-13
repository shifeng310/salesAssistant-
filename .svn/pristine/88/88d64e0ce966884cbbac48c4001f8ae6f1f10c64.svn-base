    //
//  RRLoginController.m
//  RR
//
//  Created by lyq on 11-6-22.
//  Copyright 2011 RoadRover Inc. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "RRLoginController.h"
#import "AppDelegate.h"
#import "RRLoginModel.h"


@implementation RRLoginController

@synthesize scroll_view;
@synthesize tf_username;
@synthesize tf_password;
@synthesize btn_login;
@synthesize delegate;
@synthesize no_keyboard;
@synthesize bg_im;

- (void) viewDidLoad
{
	[super viewDidLoad];
	
	model = [[RRLoginModel alloc] initWithViewController:self];
	
	tf_username.enabled = YES;
	tf_password.enabled = YES;
	btn_login.enabled = YES;
	
    CGRect src_bounds = [UIScreen mainScreen].bounds;
    if (src_bounds.size.height == 568.0f)
    {
        bg_im.image = [UIImage imageNamed:@"login_bg_568.png"];
        bg_im.frame = CGRectMake(0.0f, 0.0f, 320.0f, 568.0f);
        self.scroll_view.frame = CGRectMake(0.0f, -88.0f, 320.0f, 568.0f);
        self.tf_username.frame = CGRectMake(96.0f, 255.0f,179.0f, 31.0f);
        self.tf_password.frame = CGRectMake(96.0f, 308.0f,179.0f, 31.0f);
        self.btn_login.frame = CGRectMake(30.0f, 409.0f,260.0f, 50.0f);
    }
    else
    {
        bg_im.image = [UIImage imageNamed:@"login_bg.png"];
    }
    
    // 注册一个通知，控制键盘自动弹出和消失？
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(keyboardWasShown:)
												 name:UIKeyboardDidShowNotification object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(keyboardWillBeHidden:)
												 name:UIKeyboardWillHideNotification object:nil];
}

- (void) viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	if (!no_keyboard)
	{
		[tf_username becomeFirstResponder];
	}
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)dealloc // 销毁已经注册的通知。
{
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void) didLoginSuccess
{
	if (delegate && [delegate respondsToSelector:@selector(didLoginSuccess:)])
	{
		[delegate performSelector:@selector(didLoginSuccess:) withObject:self];
		[self dismissModalViewControllerAnimated:YES];
	}
}

- (void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{	
	AppDelegate *app = [AppDelegate getInstance];
	
	[app startMainTab];
}

- (void) didLoginFailuserData:(id)data
{
	[[AppDelegate getInstance] alert:@"登录失败" message:@"用户名或密码错误！"];
	btn_login.enabled = YES;
}

#pragma mark -

- (IBAction) btnLoginClick: (id)sender
{
	if ([tf_username.text length] == 0 ||
		[tf_password.text length] == 0)
	{
		[[AppDelegate getInstance] alert:@"登录失败" message:@"用户名和密码不能为空！"];

		return;
	}
	
    // 取消第一相应状态，tf_username,tf_password 调用后虚拟键盘就消失了
	[tf_username resignFirstResponder];
	[tf_password resignFirstResponder];
    
	
	//tf_username.enabled = NO;
	//tf_password.enabled = NO;
	btn_login.enabled = NO;
	
	[model login:tf_username.text password:tf_password.text];
}

#pragma mark -
#pragma mark UITextField Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	[textField resignFirstResponder];	
	return NO;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
	active_field = textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    active_field = nil;
}


#pragma mark -

- (void)keyboardWasShown:(NSNotification*)aNotification
{
    CGRect src_bounds = [UIScreen mainScreen].bounds;
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];
    if (src_bounds.size.height == 568.0f)
    {
        self.scroll_view.frame = CGRectMake(0.0f, -140.0f, 320.0f, 568.0f);
    }
    else
    {
        self.scroll_view.frame = CGRectMake(0.0f, -140.0f, 320.0f, 480.0f);
    }
    
    [UIView commitAnimations];
}

- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    CGRect src_bounds = [UIScreen mainScreen].bounds;
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];
    if (src_bounds.size.height == 568.0f)
    {
        self.scroll_view.frame = CGRectMake(0.0f, 0.0f, 320.0f, 568.0f);
    }
    else
    {
        self.scroll_view.frame = CGRectMake(0.0f, 0.0f, 320.0f, 480.0f);
    }
    
    [UIView commitAnimations];

}


@end

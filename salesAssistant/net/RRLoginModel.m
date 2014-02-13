//
//  RRLoginModel.m
//  lib_net
//
//  Created by lyq on 11-6-10.
//  Copyright 2011 RoadRover Inc. All rights reserved.
//

#import "RRLoginModel.h"
#import "RoadRover.h"
#import "RRToken.h"
#import "RRLoader.h"
#import "AppDelegate.h"
#import "RRLoginController.h"


@implementation RRLoginModel


#pragma mark -

- (id) initWithViewController:(id)aController
{
	self = [super init];
	
	if (nil != self)  // 这个判断什么意思
	{
		view_ctrl = aController;
	}
	
	return self;
}

- (void) dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	
}

#pragma mark -

- (void) login: (NSString *)login_name password:(NSString *)password
{
    // 这个判断做什么用的，is_loading没有赋值，是否默认为nil；
	if (is_loading)
	{
		return;
	}
	
    // 这两句话干嘛的
	is_loading = YES;
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	
    AppDelegate *app = [AppDelegate getInstance];
    // 登陆的服务器接口；
	NSString *full_url = [NSString stringWithFormat:@"%@%@", BASE_URL, LOGIN_URL];
	RRURLRequest *req = [[RRURLRequest alloc] initWithURLString:full_url];
	[req setParam:login_name forKey:@"username"];
	[req setParam:password forKey:@"pwd"];
    if (app.pushToken)
    {
        [req setParam:app.pushToken forKey:@"devicetoken"];
    }
	[req setHTTPMethod:@"POST"];
	
	RRLoader *loader = [[RRLoader alloc] initWithRequest:req];
	[loader addNotificationListener:RRLOADER_COMPLETE target:self action:@selector(onLoaded:)];   // 传入值为什么为空
	[loader addNotificationListener:RRLOADER_FAIL target:self action:@selector(onLoadFail:)];     // 传入值为什么为空
	[loader loadWithoutTimer];
	
}

- (void) onLoaded: (NSNotification *)notify
{
    // 这两句又是什么意思。
	is_loading = NO;
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	
	RRLoader *loader = (RRLoader *)[notify object];
	NSDictionary *json = [loader getJSONData];
	[loader removeNotificationListener:RRLOADER_COMPLETE target:self];
	[loader removeNotificationListener:RRLOADER_FAIL target:self];
    
		//login fail
	if (![[json objectForKey:@"success"] boolValue])
	{
		LOGEX(1, @"login fail %@", [json objectForKey:@"data"]);
		if ([view_ctrl respondsToSelector:@selector(didLoginFailuserData:)])
		{
			[view_ctrl performSelector:@selector(didLoginFailuserData:) withObject:json];
		}
		return;
	}
	
	NSDictionary *data = [json objectForKey:@"data"];
	//LOGEX(1, @"login success", nil);
	
	RRToken *token = [[RRToken alloc] initWithUID:[data objectForKey:@"userid"]];
	[token setProperty:[data objectForKey:@"token"] forKey:@"token"];
	[token setProperty:[data objectForKey:@"userid"] forKey:@"userid"];
    [token setProperty:[data objectForKey:@"name"] forKey:@"name"];
	[token setProperty:[data objectForKey:@"username"] forKey:@"username"];
	[token setProperty:[data objectForKey:@"roleid"] forKey:@"roleid"];
	[token setProperty:[data objectForKey:@"role"] forKey:@"role"];
	[token setProperty:[data objectForKey:@"lasttime"] forKey:@"lasttime"];

		//write token to local field
	[token saveToFile];
	
		//response view controller
	if ([view_ctrl respondsToSelector:@selector(didLoginSuccess)])
	{
		[view_ctrl performSelector:@selector(didLoginSuccess)];
	}
}

- (void) onLoadFail: (NSNotification *)notify
{
	is_loading = NO;
	
	RRLoader *loader = (RRLoader *)[notify object];
	[loader removeNotificationListener:RRLOADER_COMPLETE target:self];
	[loader removeNotificationListener:RRLOADER_FAIL target:self];
	RRLoginController *ctrl = (RRLoginController *)view_ctrl;
	ctrl.btn_login.enabled = YES;
}

@end

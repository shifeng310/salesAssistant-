//
//  RRLoginController.h
//  RR
//
//  Created by lyq on 11-6-22.
//  Copyright 2011 RoadRover Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RRLoginModel;

@interface RRLoginController : UIViewController <UITextFieldDelegate>
{
	UIScrollView		*scroll_view;
	
	UITextField			*tf_username;
	UITextField			*tf_password;
    UIImageView         *bg_im;
	
	UIButton			*btn_login;
	
	UITextField			*active_field;
	
	RRLoginModel		*model;
	
	id					__unsafe_unretained delegate;
	
	BOOL				no_keyboard;
}

@property (nonatomic) IBOutlet UIScrollView *scroll_view;
@property (nonatomic) IBOutlet UITextField *tf_username;
@property (nonatomic) IBOutlet UITextField *tf_password;
@property (nonatomic) IBOutlet UIButton *btn_login;
@property (nonatomic) IBOutlet UIImageView *bg_im;
@property (nonatomic, unsafe_unretained) id delegate;
@property (nonatomic, assign) BOOL no_keyboard;


- (void) didLoginSuccess;

- (void) didLoginFailuserData:(id)data;

- (IBAction) btnLoginClick:(id)sender;


@end

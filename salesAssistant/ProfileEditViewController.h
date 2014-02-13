//
//  ProfileEditViewController.h
//  salesAssistant
//
//  Created by 方鸿灏 on 13-7-22.
//  Copyright (c) 2013年 feng. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProfileEditViewController : UIViewController<UITextFieldDelegate>
{
    IBOutlet UITextField    *tf_newPassWord1;
    IBOutlet UITextField    *tf_newPassWord2;
    IBOutlet UITextField    *tf_newName;
    IBOutlet UITextField    *tf_newNo;
    IBOutlet UILabel        *lb_name;
    UIButton                *btn_fold_left;
    
    IBOutlet UIView         *bg_view;
    IBOutlet UIImageView    *im_bg;
    IBOutlet UIScrollView   *scroll_view;
    
    NSString                *passWord1;
    NSString                *passWord2;
    NSString                *newTel;
//    NSString                *newName;
    
    UITextField             *active_tf;
    
    BOOL                    is_loading;

}

@property(nonatomic,strong)UITextField *tf_newPassWord1;
@property(nonatomic,strong)UITextField *tf_newPassWord2;
//@property(nonatomic,strong)UITextField *tf_newName;
@property(nonatomic,strong)UITextField *tf_newNo;
@property(nonatomic,strong)UILabel *lb_name;
@property(nonatomic,strong)UIView *bg_view;
@property(nonatomic,strong)UIScrollView *scroll_view;
@property(nonatomic,strong)UIImageView *im_bg;

- (IBAction)btn_submit:(id)sender;

@end

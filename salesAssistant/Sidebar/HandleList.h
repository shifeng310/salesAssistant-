//
//  HandleList.h
//  salesAssistant
//
//  Created by feng on 7/25/13.
//  Copyright (c) 2013 feng. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HandleList : UITableViewController<UITextViewDelegate,UIActionSheetDelegate,UIPickerViewDataSource,UIPickerViewDelegate,UINavigationControllerDelegate>
{
    //编写“处理工单界面”
    
    IBOutlet UIButton 		        *btn_fold_left; // toolbar条中，的左侧按钮
    UITextView                      *tv_remark; // “备注” 文本框
    UITextView                      *active_txt; // 用于textview控件
    NSString                        *role;  // 纪录数据传入的登陆角色
    NSString                        *roleid; // 角色id
    NSString                        *category; // 类别
    NSString                        *state;// 状态
    NSString                        *speed;// 紧急状态
    NSString                        *stateId;//用户在“状态”一栏中选择的内容的id
    NSString                        *speedId;//用户在“紧急状态”栏中选择的内容的id
    NSMutableArray                  *history_buffer; //用来保存从服务器接口下载的历史纪录
    NSString                        *full_url; // 保存接口的地址
    NSString                        *remark; // “备注”栏
    BOOL                            is_loading; // 正在读取的
    NSString                        *orderId; // 保持当前页面的id，即由fristViewControl传递过来被点击的cell的id
    NSArray                         *state_buffer; // 保存在“状态”栏输入的信息
    NSArray                         *speed_buffer; // 保存在“紧急状态”栏输入的信息
    NSUInteger                      srcType; // 保存用户在“处理工单界面”选择的section和row所对应的序号
    UIBarButtonItem                 *btn_title; //pickerView 控件中的标题
    UIActionSheet                   *actionSheet; //注册UIActionSheet 控件
    UIToolbar                       *tool_bar_tmp;// 用于UIActionSheet控件上的 ToolBar
    UIBarButtonItem                 *btn_certain_tmp;// ToolBar 上的“确定”按钮
    UIBarButtonItem                 *btn_cancel;// ToolBar 上的“取消”按钮
}
@property(nonatomic,copy) NSString *orderId;
@end

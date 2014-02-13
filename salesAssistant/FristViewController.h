//
//  FirstViewController.h
//  SideBarNavDemo
//
//  Created by JianYe on 12-12-11.
//  Copyright (c) 2012年 JianYe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SideBarSelectedDelegate.h"
#import "EGORefreshTableHeaderView.h"

@interface FristViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>
{
    IBOutlet UIToolbar 			    *tool_bar;
    IBOutlet UIButton 		        *btn_fold_left;
    IBOutlet UILabel                *lb_top;
    IBOutlet UITableView            *list_TableView;
    
    NSString                        *titleName;
    int                             current_page;
    NSString                        *full_url;
    EGORefreshTableHeaderView       *refreshHeaderView_bottom;
	EGORefreshTableHeaderView       *refreshHeaderView;
}
@property (strong,nonatomic)IBOutlet UITableView *list_TableView;
@property (nonatomic, strong) UIToolbar *tool_bar;
@property (nonatomic, strong) UIButton *btn_fold_left;
@property (nonatomic, strong) UILabel *lb_top;
@property (assign,nonatomic)id<SideBarSelectDelegate>delegate;
@property (nonatomic,copy) NSString *titleName;
@property (nonatomic,assign)int current_page;

- (void) loadData;

@end

//
//  LeftNavViewController.h
//  SideBarNavDemo
//
//  Created by JianYe on 12-12-11.
//  Copyright (c) 2012年 JianYe. All rights reserved.
//

#import <UIKit/UIKit.h>
@class RRToken;


@protocol SideBarSelectDelegate ;

@interface LeftSideBarViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>
{
    RRToken *token ;
    int _selectIdnex;

}
@property (strong,nonatomic)IBOutlet UITableView *mainTableView;
@property (assign,nonatomic)id<SideBarSelectDelegate>delegate;
@property (nonatomic,assign)int _selectIdnex;


@end


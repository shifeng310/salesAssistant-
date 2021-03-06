//
//  FirstViewController.m
//  SideBarNavDemo
//
//  Created by JianYe on 12-12-11.
//  Copyright (c) 2012年 JianYe. All rights reserved.
//

#import "FristViewController.h"
#import "SidebarViewController.h"
#import "RRToken.h"
#import "SideBarSelectedDelegate.h"
#import "RRURLRequest.h"
#import "RWShowView.h"
#import "RRURLRequest.h"
#import "RoadRover.h"
#import "AppDelegate.h"
#import "RRToken.h"
#import "RRLoader.h"
#import "ListCell.h"
#import "RRAlertView.h"
#import "OrderDetailViewController.h"
#import "HandleList.h"

#define IPHONE_HEIGHT [UIScreen mainScreen].bounds.size.height
#define IPHONE_WIDTH [UIScreen mainScreen].bounds.size.width
#define iPhone5 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size) : NO)


@interface FristViewController ()
{
    int                _selectItem;
    BOOL               is_loading;
    NSMutableArray     *buffer;
}
@end

@implementation FristViewController
@synthesize tool_bar;
@synthesize btn_fold_left;
@synthesize lb_top;
@synthesize list_TableView;
@synthesize delegate;
@synthesize titleName;
@synthesize current_page;

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
    [super viewDidLoad];
    //判断 若为ios7，处理ios7 页面兼容问题
    if([[[UIDevice currentDevice] systemVersion] floatValue]>=7.0)
    {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.extendedLayoutIncludesOpaqueBars = NO;
        self.modalPresentationCapturesStatusBarAppearance = NO;
    }
    // 处理lb_top的显示
    RRToken *token = [RRToken getInstance];
    NSString *role = [token getProperty:@"role"];
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"background_view.png"]]];
    self.title = [NSString stringWithFormat:@"%@(%@)",titleName,role];
    
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
    [btn_fold_left setFrame:CGRectMake(5.0f, 2.0f, 50.0f, 40.0f)];
    [btn_fold_left addTarget:self action:@selector(showLeftSideBar:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *btn_back = [[UIBarButtonItem alloc]initWithTitle:@"返回" style:UIBarButtonItemStyleBordered target:nil action:nil];
    self.navigationItem.backBarButtonItem = btn_back;
    
    list_TableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.list_TableView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"background_view.png"]]];

    buffer = [NSMutableArray arrayWithCapacity:0]; // 创建一个数组指定其容量为0；
    
    //bottom refresh header
	CGRect bottom_rect = CGRectMake(0.0f, -50.0f, 320.0f, 60.0f);
	refreshHeaderView_bottom = [[EGORefreshTableHeaderView alloc] initWithoutDateLabel:bottom_rect];
	refreshHeaderView_bottom.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background_view.png"]];
	refreshHeaderView_bottom.state = EGOOPullRefreshNormalUP;
	[self.list_TableView addSubview:refreshHeaderView_bottom];
	refreshHeaderView_bottom.hidden = YES;
    
    CGRect top_rect = CGRectMake(0.0f, 0.0f - self.list_TableView.bounds.size.height, 320.0f, self.list_TableView.bounds.size.height);
	refreshHeaderView = [[EGORefreshTableHeaderView alloc] initWithoutDateLabel:top_rect];
	refreshHeaderView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background_view.png"]];
	[self.list_TableView addSubview:refreshHeaderView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar addSubview:btn_fold_left];
    [self loadData];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [btn_fold_left removeFromSuperview];
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    if([self isViewLoaded] && self.view.window == nil)
    {
        tool_bar = nil;
        btn_fold_left = nil;
        self.view = nil;
    }
}

// 注销指针对象
- (void)dealloc
{
    tool_bar = nil;
    btn_fold_left = nil;
    self.view = nil;
    lb_top = nil;
    list_TableView = nil;
    refreshHeaderView_bottom = nil;
}

#pragma mark tableview data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([buffer count] == 0)
    {
        return 1;
    }
    return [buffer count];
}

// tableview 中要显示的数据，
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 若tableview，没有下载数据。
    if (0 == [buffer count])
	{
		static NSString *cell_id = @"Cell";		
		UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:cell_id];
		if (nil == cell)
		{
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cell_id];
		}
        UIFont *font = [UIFont systemFontOfSize:15.0f];
        switch (current_page)
        {
            case 0:
                cell.textLabel.text = @"没有待处理工单";
                break;
            case 1:
                cell.textLabel.text = @"没有已分配工单";
                break;
            case 2:
                cell.textLabel.text = @"没有待回访工单";
                break;
            case 3:
                cell.textLabel.text = @"没有已关闭工单";
                break;
            case 4:
                cell.textLabel.text = @"没有系统消息";
            default:
                break;
        }
		cell.textLabel.font = font;
		cell.textLabel.textAlignment = UITextAlignmentCenter;
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		return cell;
	}
	
    static NSString *CellIdentifier = @"ListCell";
    NSMutableDictionary *area_info = [buffer objectAtIndex:indexPath.row];
    [area_info setObject:[NSString stringWithFormat:@"%d",indexPath.row ] forKey:@"row"];
    [area_info setObject:[NSString stringWithFormat:@"%d",current_page] forKey:@"type"];
    ListCell *cell = (ListCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (nil == cell)
    {
        UIViewController *uc = [[UIViewController alloc] initWithNibName:CellIdentifier bundle:nil];
        
        cell = (ListCell *)uc.view;
        
        // 给不同的cell 填写数据
        [cell setContent:area_info];
    }
    if ([[area_info objectForKey:@"type"] isEqualToString:@"4"]) {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    else
    {
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
    }
    
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary *dic = [buffer objectAtIndex:indexPath.row];
    OrderDetailViewController *ctrl = [[OrderDetailViewController alloc] initWithStyle:UITableViewStyleGrouped];
    if (current_page == 1)
    {
        ctrl.state = ListSourceTypeEdit;
    }
    
    else if (current_page == 0)
    {
        ctrl.state = ListSourceTypeEdit;
    }

    else if (current_page == 2)
    {
        ctrl.state = ListSourceTypeDetail;
    }

    else if (current_page == 3)
    {
        ctrl.state = ListSourceTypeDetail;
    }
    else if (current_page == 4)
    {
        return;
    }

    ctrl.page = [NSString stringWithFormat:@"%d",current_page];
    ctrl.orderId = [dic objectForKey:@"id"];
    [self.navigationController pushViewController:ctrl animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([buffer count] == 0)
    {
        return 44;
    }
    return [ListCell calCellHeight:[buffer objectAtIndex:indexPath.row]];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath.row + 1 == [buffer count] &&
		tableView.contentSize.height > tableView.bounds.size.height)
	{
		CGRect bottom_rect = CGRectMake(0.0f, tableView.contentSize.height, 320.0f, 60.0f);
		refreshHeaderView_bottom.frame = bottom_rect;
		refreshHeaderView_bottom.hidden = NO;
	}
}

- (void)scrollViewDidScroll: (UIScrollView *)scrollView
{
	if (!scrollView.isDragging)
	{
		return;
	}
    
    if (refreshHeaderView.state == EGOOPullRefreshPulling && scrollView.contentOffset.y > -65.0f && scrollView.contentOffset.y < 0.0f)
	{
		[refreshHeaderView setState:EGOOPullRefreshNormal];
	}
	else if (refreshHeaderView.state == EGOOPullRefreshNormal && scrollView.contentOffset.y < -65.0f)
	{
		[refreshHeaderView setState:EGOOPullRefreshPulling];
	}
	
	if (refreshHeaderView_bottom.state == EGOOPullRefreshPulling &&
		scrollView.contentOffset.y + scrollView.bounds.size.height - scrollView.contentSize.height < 65.0f)
	{
		[refreshHeaderView_bottom setState:EGOOPullRefreshNormalUP];
	}
	else if (refreshHeaderView_bottom.state == EGOOPullRefreshNormalUP &&
			 scrollView.contentOffset.y + scrollView.bounds.size.height - scrollView.contentSize.height > 65.0f)
	{
		[refreshHeaderView_bottom setState:EGOOPullRefreshPulling];
	}
}

// 上下刷新的控制
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
	if (scrollView.contentOffset.y < - 65.0f)
	{
		[refreshHeaderView setState:EGOOPullRefreshLoading];
		self.list_TableView.contentInset = UIEdgeInsetsMake(60.0f, 0.0f, 0.0f, 0.0f);
        [buffer removeAllObjects];
        [self loadData];
	}
    else if (scrollView.contentOffset.y + scrollView.bounds.size.height - scrollView.contentSize.height > 65.0f)
	{
		[refreshHeaderView_bottom setState:EGOOPullRefreshLoading];
		self.list_TableView.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, 60.0f, 0.0f);
		[self loadData];
	}
}


#pragma mark - ibaction

- (IBAction)showLeftSideBar:(id)sender
{
    if ([[SidebarViewController share] respondsToSelector:@selector(showSideBarControllerWithDirection:)]) {
        [[SidebarViewController share] showSideBarControllerWithDirection:SideBarShowDirectionLeft];
    }
}
- (IBAction)showRightSideBar:(id)sender
{
    if ([[SidebarViewController share] respondsToSelector:@selector(showSideBarControllerWithDirection:)]) {
        [[SidebarViewController share] showSideBarControllerWithDirection:SideBarShowDirectionRight];
    }
}


#pragma mark - net

- (void) loadData
{
    [buffer removeAllObjects];
    is_loading = YES;
	[RWShowView show:@"loading"];
    
	// 链接服务器
     [self selectURL:current_page];
    
}

- (void) onLoadData:(NSNotification *)notify
{
    is_loading = NO;
    [RWShowView closeAlert];
	RRLoader *loader = (RRLoader *)[notify object];
	NSDictionary *json = [loader getJSONData];
	[loader removeNotificationListener:RRLOADER_FAIL target:self];
	[loader removeNotificationListener:RRLOADER_COMPLETE target:self];
	
	if (![[json objectForKey:@"success"] boolValue])
	{
        [self updateTableView];
		return;
	}
	
	[buffer removeAllObjects];
    
	NSArray *arr = [[json objectForKey:@"data"] objectForKey:@"list"];
	if (0 == [arr count])
	{
        [self updateTableView];
		return;
	}
    [buffer addObjectsFromArray:arr];
    [self updateTableView];
}

- (void) onFetchFail:(NSNotification *)notify
{
    is_loading = NO;
	[RWShowView closeAlert];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.list_TableView reloadData];
}

- (void) updateTableView
{
	[refreshHeaderView setState:EGOOPullRefreshNormal];
	[RWShowView closeAlert];
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:.2];
	self.list_TableView.contentInset = UIEdgeInsetsZero;
	[UIView commitAnimations];
	[self.list_TableView reloadData];
}

// 根据点击在leftsiderbarviewcontroller页面中，具体的cell的位置信息，链接相应的接口

-(void) selectURL:(NSUInteger) currentpage
{
    if (current_page == 4) {
       full_url = [NSString stringWithFormat:@"%@%@",BASE_URL,MESSAGE_LIST];
    }
    else
    {
        full_url = [NSString stringWithFormat:@"%@%@", BASE_URL,LIST_URL];
    }
    
    RRURLRequest *req = [[RRURLRequest alloc] initWithURLString:full_url];
    RRToken *token = [RRToken getInstance];
    [req setParam:[token getProperty:@"token"] forKey:@"token"];

    if (currentpage == 0)
    {
        [req setParam:@"2" forKey:@"status"];

    }
    if (currentpage == 1)
    {
        [req setParam:@"1" forKey:@"status"];
    }
    if (currentpage == 2)
    {
        [req setParam:@"3" forKey:@"status"];

    }
    if (currentpage == 3)
    {
        [req setParam:@"4" forKey:@"status"];
    }

    if ([buffer count])
    {
        [req setParam:[NSString stringWithFormat:@"%u",[buffer count]] forKey:@"startpos"];
    }
    [req setHTTPMethod:@"POST"];
    RRLoader *loader = [[RRLoader alloc] initWithRequest:req];
    
    [loader addNotificationListener:RRLOADER_FAIL target:self action:@selector(onFetchFail:)];
    if ([buffer count])
    {
        [loader addNotificationListener:RRLOADER_COMPLETE target:self action:@selector(onFechOld:)];
    }
    else
    {
        [loader addNotificationListener:RRLOADER_COMPLETE target:self action:@selector(onLoadData:)];
    }
    [loader loadwithTimer];
    [RWShowView show:@"loading"];
}

- (void) onFechOld:(NSNotification *)notify
{
    is_loading = NO;
    [RWShowView closeAlert];
	RRLoader *loader = (RRLoader *)[notify object];
	NSDictionary *json = [loader getJSONData];
	[loader removeNotificationListener:RRLOADER_FAIL target:self];
	[loader removeNotificationListener:RRLOADER_COMPLETE target:self];
	
	if (![[json objectForKey:@"success"] boolValue])
	{
        [self updateTableViewBefore];
		return;
	}
	
	NSArray *arr = [[json objectForKey:@"data"] objectForKey:@"list"];
	if (0 == [arr count])
	{
        [self updateTableViewBefore];
		return;
	}
    [buffer addObjectsFromArray:arr];
    [self updateTableViewBefore];
}

- (void) updateTableViewBefore
{
	[refreshHeaderView_bottom setState:EGOOPullRefreshNormalUP];
	refreshHeaderView_bottom.hidden = YES;
	
	self.list_TableView.contentInset = UIEdgeInsetsZero;
	[self.list_TableView reloadData];
    
}

@end

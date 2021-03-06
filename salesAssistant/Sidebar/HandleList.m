//
//  HandleList.m
//  salesAssistant
//
//  Created by feng on 7/25/13.
//  Copyright (c) 2013 feng. All rights reserved.
//

#import "HandleList.h"
#import "RRToken.h"
#import "HistoryCell.h"
#import "RRURLRequest.h"
#import "RoadRover.h"
#import "RWShowView.h"
#import "RRLoader.h"
#import "RRAlertView.h"

@interface HandleList()
@end


@implementation HandleList

@synthesize orderId;

//  初始化
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

// 释放内存
- (void)dealloc
{
    btn_fold_left = nil;
    tv_remark = nil;
    active_txt = nil;
    history_buffer = nil;
    state_buffer = nil;
    speed_buffer = nil;
    btn_title = nil;
    actionSheet = nil;
    tool_bar_tmp = nil;
    btn_certain_tmp = nil;
    btn_cancel = nil;
}

//
-(void) viewDidLoad
{
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    [self.tableView setBackgroundView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background_view.png"]]];
    RRToken *token = [RRToken getInstance];                             //获取token，通过token获取当前使用者的角色
    roleid = [token getProperty:@"roleid"];
    role = [token getProperty:@"role"];
    self.title = [NSString stringWithFormat:@"处理工单(%@)",role];
    
    state_buffer=@[@"已处理",@"关闭"];
    speed_buffer=@[@"紧急",@"较紧急",@"非常紧急"];
    

    //设置actionsheet中的 toolbar上的按钮
    btn_certain_tmp = [[UIBarButtonItem alloc]initWithTitle:@"确定" style:UIBarButtonItemStyleDone target:self action:@selector(btn_certain_tmp_click:)];
    btn_cancel = [[UIBarButtonItem alloc]initWithTitle:@"取消" style:UIBarButtonItemStyleBordered target:self action:@selector(btn_cancel_click:)];
    btn_title = [[UIBarButtonItem alloc]initWithTitle:@"选择省份" style:UIBarButtonItemStylePlain target:self action:nil];
    UIBarButtonItem *flex = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    NSArray *arr = @[btn_cancel,flex,btn_title,flex,btn_certain_tmp];
    tool_bar_tmp = [[UIToolbar alloc]initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 44.0f)];
    tool_bar_tmp.barStyle = UIBarStyleBlack;
    tool_bar_tmp.translucent = YES;
    [tool_bar_tmp setItems:arr animated:NO];
    
    // 加载数据
    [self loadData];
    
}

#pragma mark - Table view data source

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section

{
    switch (section) {
        case 0:
            return 4;
            break;     
        case 1:
            return [history_buffer count];
            break;
        case 2:
            return 1;
            break;
        default:
            break;
    }
    return 0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cell_id = [NSString stringWithFormat:@"cell_section%d_row%d",indexPath.section,indexPath.row];
    
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:cell_id];
    if (nil == cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cell_id];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.textColor = [UIColor darkGrayColor];
    
    // 若cell对应的view已存在，则删除
    if ([cell viewWithTag:(indexPath.section + 1)*10 + indexPath.row])
    {
        [[cell viewWithTag:(indexPath.section + 1)*10 + indexPath.row] removeFromSuperview];
    }
    
    UITextView *txt = [[UITextView alloc]initWithFrame:CGRectMake(100.0f, 10.0f, 200.0f, 25.0f)];
    txt.delegate = self;
    txt.tag = (indexPath.section + 1)*10 + indexPath.row;
    txt.textColor = [UIColor lightGrayColor];
    txt.backgroundColor = [UIColor clearColor];
    txt.scrollEnabled = NO;
    txt.returnKeyType = UIReturnKeyDone;
    
    if(indexPath.section == 0)
    {
        switch (indexPath.row) {
            case 0:
                cell.textLabel.text =@"类别";
                txt.text = @"售后服务";
                txt.userInteractionEnabled = NO;
                [cell addSubview:txt];
                break;
            case 1:
            {
                cell.textLabel.text =@"状态";
                if ([cell viewWithTag:1])
                {
                    [[cell viewWithTag:1] removeFromSuperview];
                }
                if ([cell viewWithTag:2])
                {
                    [[cell viewWithTag:2] removeFromSuperview];
                }

                UILabel *lb = [[UILabel alloc] initWithFrame:CGRectMake(100.0f, 15.0f, 180.0f, 15.0f)];
                lb.tag = 1;
                lb.textColor = [UIColor lightGrayColor];
                lb.font = [UIFont systemFontOfSize:13];
                lb.backgroundColor = [UIColor clearColor];
                UIImageView *im = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"dropdown_arrow.png"]];
                im.frame = CGRectMake(280.0f, 7, 30, 30);
                im.tag = 2;
                lb.text = state;
                if ([roleid isEqualToString:@"2"]) {
                    state = @"已处理";
                    stateId =@"3";
                }
                [cell addSubview:lb];
                [cell addSubview:im];
                
            }
                break;
            case 2:
            {
                cell.textLabel.text =@"紧急级别";
                if ([cell viewWithTag:3])
                {
                    [[cell viewWithTag:3] removeFromSuperview];
                }
                if ([cell viewWithTag:4])
                {
                    [[cell viewWithTag:4] removeFromSuperview];
                }

                UILabel *lb = [[UILabel alloc] initWithFrame:CGRectMake(100.0f, 15.0f, 180.0f, 15.0f)];
                lb.tag = 3;
                lb.textColor = [UIColor lightGrayColor];
                lb.font = [UIFont systemFontOfSize:13];
                lb.backgroundColor = [UIColor clearColor];
                UIImageView *im = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"dropdown_arrow.png"]];
                im.frame = CGRectMake(280.0f, 7, 30, 30);
                im.tag = 4;
                lb.text = speed;
                [cell addSubview:lb];
                [cell addSubview:im];
            }
                break;
            case 3:
            {
                if ([cell viewWithTag:5])
                {
                    [[cell viewWithTag:5] removeFromSuperview];
                }
                UILabel *lb = [[UILabel alloc] initWithFrame:CGRectMake(20.0f, 5.0f, 50.0f, 25.0f)];
                lb.textColor = [UIColor darkGrayColor];
                lb.font = [UIFont fontWithName:@"Helvetica-Bold" size:17];
                lb.backgroundColor = [UIColor clearColor];
                lb.text = @"备注";
                lb.textAlignment = 0;
                lb.tag = 5;
                [cell addSubview:lb];
                
                txt.frame = CGRectMake(65, 5.0, 230, 70);
                txt.text = remark;
                [cell addSubview:txt];
            }
                break;
            default:
                break;
        }
    }
    else if (indexPath.section == 1) {
        
        static NSString *CellIdentifier = @"HistoryCell";     // 绑定cell的xib文件，
        // 将获取到json数据的数组，存到字典里
        NSMutableDictionary *area_info = [history_buffer objectAtIndex:indexPath.row];
        HistoryCell *cell = (HistoryCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (nil == cell)
        {
            UIViewController *uc = [[UIViewController alloc] initWithNibName:CellIdentifier bundle:nil];
            cell = (HistoryCell *)uc.view;
            [cell setContent:area_info];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
         return cell;
    }
    else if(indexPath.section == 2){
        UIView *bv = [[UIView alloc] initWithFrame:cell.frame];
        cell.backgroundView = bv;
        if ([cell viewWithTag:(indexPath.section + 1)*10 + indexPath.row])
        {
            [[cell viewWithTag:(indexPath.section + 1)*10 + indexPath.row] removeFromSuperview];
        }
        
        if([[[UIDevice currentDevice] systemVersion] floatValue]>=7.0)
        {
            UIImageView *iv_bg = [[UIImageView alloc] init];
            iv_bg.tag = (indexPath.section + 1)*10 + indexPath.row;
            [cell.contentView addSubview:iv_bg];
            UILabel *lb = [[UILabel alloc] initWithFrame:CGRectMake(60.0f, 15.0f, 180.0f, 18.0f)];
            lb.textColor = [UIColor whiteColor];
            lb.font = [UIFont fontWithName:@"Helvetica-Bold" size:18.0f];
            lb.backgroundColor = [UIColor clearColor];
            lb.text = @"提交";
            lb.textAlignment = UITextAlignmentCenter;
            [iv_bg addSubview:lb];
            
        }
        else
        {
            UIImageView *iv_bg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"submit_bg.png"]];
            iv_bg.tag = (indexPath.section + 1)*10 + indexPath.row;
            [cell.contentView addSubview:iv_bg];
            UILabel *lb = [[UILabel alloc] initWithFrame:CGRectMake(60.0f, 15.0f, 180.0f, 18.0f)];
            lb.textColor = [UIColor whiteColor];
            lb.font = [UIFont fontWithName:@"Helvetica-Bold" size:18.0f];
            lb.backgroundColor = [UIColor clearColor];
            lb.text = @"提交";
            lb.textAlignment = UITextAlignmentCenter;
            [iv_bg addSubview:lb];
        }
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    srcType = (indexPath.section + 1)*10 + indexPath.row;
    if (indexPath.section == 0 && indexPath.row == 1)
    {
        if ([roleid isEqualToString:@"3"])
        {
            [self actionWithType];
        }
     }
    
   else if (indexPath.section == 0 && indexPath.row == 2) {
         [self actionWithType];
    }
   else if (indexPath.section == 2)
   {
       if ([roleid isEqualToString:@"2"])
       {
           stateId = @"3";
       }
       
       [self submitData];
   }
    
}

// 设置cell的header
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{ 
    UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 40.0f)];
    v.backgroundColor = [UIColor clearColor];
    UILabel *lb = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, 5.0f, 100.0f, 30.0f)];
    lb.font = [UIFont fontWithName:@"Helvetica" size:15];
    lb.backgroundColor = [UIColor clearColor];
    UIImageView *im = [[UIImageView alloc] initWithImage:[UIImage  imageNamed:@"fengexian_more"]];
    im.frame = CGRectMake(79.0f, 18.0f, 230.0f, 2.0f);
    switch (section) {
        case 1:
            lb.text = @"历史纪录";
            lb.textColor = [UIColor colorWithRed:255.0f/255.0f green:96.0f/255.0f blue:0.0f alpha:1.0f];
            [v addSubview:lb];
            [v addSubview:im];
            return v;
            break;
        default:
            break;
    }
    return nil;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        switch (indexPath.row) {
            case 3:
                return 80.0f;
                break;
            default:
                break;
        }
    }
    if (indexPath.section == 1) {
        return 80.0f;
    }
    return 44.0f;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    switch (section) {
      
        case 1:
            return 44.0f;
            break;
            
        default:
            break;
    }
    return 0;
}

-(void)loadData
{
    // 设置网络参数和接口路径
    if (is_loading)
	{
		return;
	}
    is_loading = YES;
	[RWShowView show:@"loading"];
    full_url = [NSString stringWithFormat:@"%@%@",BASE_URL,VIEWHISTORY_URL];
    RRURLRequest *req = [[RRURLRequest alloc] initWithURLString:full_url];
	RRToken *token_tmp = [RRToken getInstance];
    [req setParam:[token_tmp getProperty:@"token"] forKey:@"token"];
    [req setParam:self.orderId forKey:@"id"];
	[req setHTTPMethod:@"POST"];
    
    // 取得网络链接。并触发 成功连接和连接失败 两种不同的方法。
    RRLoader *loader = [[RRLoader alloc] initWithRequest:req];
	[loader addNotificationListener:RRLOADER_FAIL target:self action:@selector(onFetchFail:)];
	[loader addNotificationListener:RRLOADER_COMPLETE target:self action:@selector(onLoadData:)];
	[loader loadwithTimer];
	[RWShowView show:@"loading"];
}

-(void)submitData
{
    full_url = [NSString stringWithFormat:@"%@%@", BASE_URL,HANDLE_URL];
    RRURLRequest *req = [[RRURLRequest alloc] initWithURLString:full_url];
    RRToken *token = [RRToken getInstance];
    [req setParam:[token getProperty:@"token"] forKey:@"token"];
    [req setParam:stateId forKey:@"order[status]"];
    if ([speedId length])
    {
        [req setParam:speedId forKey:@"order[level]"];
    }
    if ([remark length])
    {
        [req setParam:remark forKey:@"remark"];
    }
    [req setParam:self.orderId forKey:@"id"];

    [req setHTTPMethod:@"POST"];
    
    RRLoader *loader = [[RRLoader alloc] initWithRequest:req];
	[loader addNotificationListener:RRLOADER_FAIL target:self action:@selector(onFetchFail:)];
	[loader addNotificationListener:RRLOADER_COMPLETE target:self action:@selector(onSubmitData:)];
	[loader loadwithTimer];
	[RWShowView show:@"loading"];
}

- (void)onSubmitData:(NSNotification *)notify
{
    is_loading = NO;
    [RWShowView closeAlert];
    // 建立链接，获取json的内容，打印json，查找需要的数据
	RRLoader *loader = (RRLoader *)[notify object];
	NSDictionary *json = [loader getJSONData];
	[loader removeNotificationListener:RRLOADER_FAIL target:self];
	[loader removeNotificationListener:RRLOADER_COMPLETE target:self];
	// 若返回不成功则继续reloadData
	if (![[json objectForKey:@"success"] boolValue])
	{
        [RRAlertView show:[[json objectForKey:@"data"] objectAtIndex:0]];
        [self.tableView reloadData];
		return;
	}
    [RRAlertView show:@"处理成功!"];
    [self performSelector:@selector(popToViewController) withObject:nil afterDelay:1.0];
}

- (void) popToViewController
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void) onLoadData:(NSNotification *)notify
{
    is_loading = NO;
    [RWShowView closeAlert];
    // 建立链接，获取json的内容，打印json，查找需要的数据
	RRLoader *loader = (RRLoader *)[notify object];
	NSDictionary *json = [loader getJSONData];
	[loader removeNotificationListener:RRLOADER_FAIL target:self];
	[loader removeNotificationListener:RRLOADER_COMPLETE target:self];
	// 若返回不成功则继续reloadData
	if (![[json objectForKey:@"success"] boolValue])
	{   
        [self.tableView reloadData];
		return;
	}
	// 将获取的json数据存放到数组里面
    history_buffer = [NSMutableArray arrayWithArray:[[json objectForKey:@"data"] objectForKey:@"history"]];
	if (0 == [history_buffer count])
	{
        [self.tableView  reloadData];
		return;
	}
    [self.tableView reloadData];
}

-(void)onFetchFail
{
    is_loading = NO;
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)ActionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [actionSheet dismissWithClickedButtonIndex:buttonIndex animated:YES];

}


#pragma mark UIPickerViewDelegate

//设置pickerview的滚轮的列数
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
	return 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (srcType == 11) {
        return [state_buffer count];
    }
    return [speed_buffer count];
    
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (srcType == 11) {
        return [state_buffer objectAtIndex:row];
    }
    return [speed_buffer objectAtIndex:row];
}

#pragma mark picker Delegate Methods

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    
}

- (void) actionWithType
{
    NSString *title = @"\n\n\n\n\n\n\n\n\n\n\n\n\n\n";;
    actionSheet = [[UIActionSheet alloc] initWithTitle:title delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil, nil];
    switch (srcType) {
        case 11:
            btn_title.title = @"选择状态";
            break;
        case 12:
            btn_title.title = @"选择紧急级别";
            break;
        default:
            break;
    }
    actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
    [actionSheet showInView:self.tableView];
    UIPickerView *picker_View = [[UIPickerView alloc] init];
    picker_View.frame = CGRectMake(20.0f,50.0f, 280.0f, 216.0f);
    picker_View.tag = srcType;
    picker_View.delegate = self;
    picker_View.dataSource = self;
    picker_View.showsSelectionIndicator = YES;
    [actionSheet addSubview:picker_View];
    [actionSheet addSubview:tool_bar_tmp];
}
// pickerview 中取消按钮的操作
- (IBAction)btn_cancel_click:(id)sender
{
    [self performSelector:@selector(actionSheet:clickedButtonAtIndex:) withObject:0];
}

// pickerview 中确定按钮的操作
- (void)btn_certain_tmp_click:(id)sender
{
    UIPickerView *picker_View = (UIPickerView *)[actionSheet viewWithTag:srcType];
    switch (srcType) {
        case 11:
            state = [state_buffer objectAtIndex:[picker_View selectedRowInComponent:0]];
            switch ([picker_View selectedRowInComponent:0]) {
                case 0:
                    stateId = @"3";
                    break;
                case 1:
                    stateId = @"4";
                    break;
                default:
                    break;
            }
            break;
        case 12:
        {
            speed = [speed_buffer objectAtIndex:[picker_View selectedRowInComponent:0]];
            switch ([picker_View selectedRowInComponent:0]) {
                case 0:
                    speedId = @"1";
                    break;
                case 1:
                    speedId = @"2";
                    break;
                case 2:
                    speedId = @"3";
                    break;
                default:
                    break;
            }
        }
            break;
        default:
            break;
    }    
    [self.tableView reloadData];
    [self performSelector:@selector(actionSheet:clickedButtonAtIndex:) withObject:0];
}

#pragma mark - textViewDelegate
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    //textView.text = @"";
    [active_txt resignFirstResponder];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    active_txt = textView;
    
    remark = textView.text;
    [self.tableView reloadData];
    
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if (1 == range.length) {//按下回格键
        return YES;
    }
    
    if ([text isEqualToString:@"\n"]) {//按下return键
        //这里隐藏键盘，不做任何处理
        [textView resignFirstResponder];
        return NO;
    }
    
    return YES;
}


@end

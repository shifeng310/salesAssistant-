//
//  OrderDetailViewController.m
//  salesAssistant
//
//  Created by 方鸿灏 on 13-7-23.
//  Copyright (c) 2013年 feng. All rights reserved.
//

#import "OrderDetailViewController.h"
#import "RoadRover.h"
#import "RRAlertView.h"
#import "RWShowView.h"
#import "RWHomeCache.h"
#import "RRToken.h"
#import "RRLoader.h"
#import "SidebarViewController.h"
#import "RRViewPhotoController.h"
#import "HistoryCell.h"
#import "RRRemoteImage.h"
#import "RWImageBuffer.h"
#import "HandleList.h"


@interface OrderDetailViewController ()

@end

@implementation OrderDetailViewController

@synthesize state;
@synthesize orderId;
@synthesize page;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    switch (state)
    {
        case ListSourceTypeAdd:
            self.title = @"新增工单";
            break;
        case ListSourceTypeEdit:
            self.title = @"编辑工单";
            break;
        case ListSourceTypeDetail:
            self.title = @"工单详情";
            break;
        default:
            break;
    }
    
    // 检查省份列表的更新
//    RRToken * token_Province = [RRToken getInstance];
//    
//    // 判断token中的 Province_version 属性，若值为空，则更替省份城市文档。
//    if ([token_Province getProperty:@"provinceVersion"] == nil) {
//        // 删除原有的省份城市文档列表
    
//        // 将“province_version”属性，key值"1" 增加到token中
//        [token_Province setProperty:@"1" forKey:@"provinceVersion"];
//        [token_Province saveToFile];
//    }
    
    // 检查省份列表的更新,若为老版本则删除保持省份列表的homecache文件夹
    if (![RRToken checkProvinceVersion]) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		[defaults setObject:@"1" forKey:@"provinceVersion"];
        [defaults synchronize];
        [RWHomeCache deleteFile:@"province"];

    }

    province_buffer = [NSMutableArray arrayWithCapacity:0];
    provinceSort_buffer = [NSMutableArray arrayWithCapacity:0];
    city_buffer = [NSMutableArray arrayWithCapacity:0];
    worker_buffer = [NSMutableArray arrayWithCapacity:0];

    saleType_buffer = @[@"经销商",@"4S店",@"技服佳店"];
    brand_buffer = @[@"畅新",@"LC",@"技服佳",@"畅安",@"畅安S",@"畅云",@"阿尔派",@"吉利",@"广汽菲亚特",@"东风标致雪铁龙"];
    station_buffer = @[@"2271",@"2272",@"2272+",@"2273",@"2273+",@"I10"];
    appearancetype_buffer = @[@"综合",@"DVD不良",@"翻新",@"屏显",@"开关机",@"触摸屏",@"TF/SD/USB",
                              @"导航",@"结构外观",@"旋钮/按钮",@"声音",@"CCD",@"收音机",@"软件",@"地图",
                              @"死机",@"蓝牙",@"电流/漏电",@"风扇",@"空调",@"MCU",@"通讯协议",@"异响",
                              @"AV/TV",@"灯",@"时间",@"方控",@"IPOD",@"其他"];
    reasontype_buffer = @[@"IC问题",@"模块问题",@"触摸屏/显示屏",@"机芯结构不良",@"机芯解码板不良",
                          @"虚/假焊问题",@"短路",@"FPC排线问题",@"人为问题",@"物料问题",@"工艺问题",@"设计问题",@"其他不良"];
    servicetype_buffer = @[@"外出服务",@"装车服务",@"维修服务",@"厂内服务"];

    
	self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    [self.tableView setBackgroundView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background_view.png"]]];

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
    
    UIBarButtonItem *b;
    if ([page isEqualToString:@"2"] && [[[RRToken getInstance] getProperty:@"roleid"] isEqualToString:@"2"])
    {
        b = [[UIBarButtonItem alloc] initWithTitle:@"上一步" style:UIBarButtonItemStyleBordered target:self action:@selector(btn_next_click:)];
    }
    else if ([[[RRToken getInstance] getProperty:@"roleid"] isEqualToString:@"2"])
    {
        b = [[UIBarButtonItem alloc] initWithTitle:@"下一步" style:UIBarButtonItemStyleBordered target:self action:@selector(btn_next_click:)];

    }
    btn_certain_tmp = [[UIBarButtonItem alloc]initWithTitle:@"确定" style:UIBarButtonItemStyleDone target:self action:@selector(btn_certain_tmp_click:)];
    btn_cancel = [[UIBarButtonItem alloc]initWithTitle:@"取消" style:UIBarButtonItemStyleBordered target:self action:@selector(btn_cancel_click:)];
    btn_title = [[UIBarButtonItem alloc]initWithTitle:@"选择省份" style:UIBarButtonItemStylePlain target:self action:nil];
    
    UIBarButtonItem *flex = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    NSArray *arr = @[btn_cancel,flex,btn_title,flex,btn_certain_tmp];
    tool_bar_tmp = [[UIToolbar alloc]initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 44.0f)];
    tool_bar_tmp.barStyle = UIBarStyleBlack;
    tool_bar_tmp.translucent = YES;
    [tool_bar_tmp setItems:arr animated:NO];
    
    if (state == ListSourceTypeDetail)
    {
        if ([page isEqualToString:@"2"] && [[[RRToken getInstance] getProperty:@"roleid"] isEqualToString:@"2"])
        {
            self.navigationItem.rightBarButtonItem = b;
        }
        [self loadData];
    }
    else if (state == ListSourceTypeEdit)
    {
        [self loadData];
        self.navigationItem.rightBarButtonItem = b;

    }
    else if (state == ListSourceTypeAdd)
    {
        self.navigationItem.rightBarButtonItem = b;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (state == ListSourceTypeAdd)
    {
        [self.navigationController.navigationBar addSubview:btn_fold_left];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [btn_fold_left removeFromSuperview];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    tool_bar_tmp = nil;
    btn_certain_tmp = nil;
    btn_cancel = nil;
    btn_title = nil;
    actionSheet = nil;
    image = nil;
    
    btn_fold_left = nil;
    btn_submit = nil;
    active_txt = nil;
    
    province_buffer = nil;
   // province_buffer_byLetterOrder = nil;
    city_buffer = nil;
    worker_buffer = nil;
    order_dic = nil;
    info_dic = nil;
    history_buffer = nil;
    
    saleType_buffer = nil;
    brand_buffer = nil;
    station_buffer = nil;
    appearancetype_buffer = nil;
    reasontype_buffer = nil;
    servicetype_buffer = nil;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    switch (state)
    {
        case ListSourceTypeAdd:
        case ListSourceTypeDetail:
            return 13;
            break;
        case ListSourceTypeEdit:
            return 12;
            break;
        default:
            break;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section)
    {
        case 0:
            return 4;
            break;
        case 1:
            return 3;
            break;
        case 2:
            return 1;
            break;
        case 3:
            return 4;
            break;
        case 4:
            return 3;
            break;
        case 5:
            return 3;
            break;
        case 6:
            return 2;
            break;
        case 7:
            return 3;
            break;
        case 8:
            return 1;
            break;
        case 9:
            return 1;
            break;
        case 10:
            return 1;
            break;
        case 11:
              return 1;
            break;
        case 12:
            if (state != ListSourceTypeAdd)
            {
                return [history_buffer count];
            }
            return 1;
            break;
        default:
            break;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSString *cell_id = [NSString stringWithFormat:@"cell_section%d_row%d",indexPath.section,indexPath.row];
    
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:cell_id];
    if (nil == cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cell_id];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.textColor = [UIColor darkGrayColor];
    
    if ([cell viewWithTag:(indexPath.section + 1)*10 + indexPath.row])
    {
        [[cell viewWithTag:(indexPath.section + 1)*10 + indexPath.row] removeFromSuperview];
    }
    
    UITextView *txt = [[UITextView alloc]initWithFrame:CGRectMake(100.0f, 10.0f, 200.0f, 25.0f)];
    txt.delegate = self;
    txt.tag = (indexPath.section + 1)*10 + indexPath.row;
    txt.textColor = [UIColor lightGrayColor];
    txt.font = [UIFont systemFontOfSize:14.0f];
    txt.backgroundColor = [UIColor clearColor];
    txt.scrollEnabled = NO;
    txt.returnKeyType = UIReturnKeyDone;
    if (state == ListSourceTypeDetail)
    {
        txt.userInteractionEnabled = NO;
    }
    
    if (indexPath.section == 0)
    {
        switch (indexPath.row)
        {
            case 0:
                cell.textLabel.text = @"客户名称:";
                txt.text = customername;
                [cell addSubview:txt];
                break;
            case 1:
                cell.textLabel.text = @"客户电话:";
                txt.text = customertel;
                [cell addSubview:txt];
                break;
            case 2:
            {
                cell.textLabel.text = @"维修省份:";
                
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
                lb.font = [UIFont systemFontOfSize:14];
                lb.backgroundColor = [UIColor clearColor];
                if ([province length])
                {
                    lb.text = province;
                }
                else
                {
                    lb.text = @"请选择省份";
                }
                
                UIImageView *im = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"dropdown_arrow.png"]];
                im.frame = CGRectMake(280.0f, 7, 30, 30);
                im.tag = 2;
                [cell addSubview:lb];
                if (state != ListSourceTypeDetail)
                {
                    [cell addSubview:im];
                }
            }
                break;
            case 3:
            {
                cell.textLabel.text = @"维修城市:";
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
                lb.font = [UIFont systemFontOfSize:14];
                lb.backgroundColor = [UIColor clearColor];
                if ([city length])
                {
                    lb.text = city;
                }
                else
                {
                    lb.text = @"请选择城市";
                }
                
                UIImageView *im = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"dropdown_arrow.png"]];
                im.frame = CGRectMake(280.0f, 7, 30, 30);
                im.tag = 4;
                [cell addSubview:lb];
                if (state != ListSourceTypeDetail)
                {
                    [cell addSubview:im];
                }
            }
                break;
            default:
                break;
        }
    }
    
    else if (indexPath.section == 1)
    {
        switch (indexPath.row)
        {
            case 0:
            {
                cell.textLabel.text = @"维修人员:";
                if ([cell viewWithTag:5])
                {
                    [[cell viewWithTag:5] removeFromSuperview];
                }
                if ([cell viewWithTag:6])
                {
                    [[cell viewWithTag:6] removeFromSuperview];
                }
                
                UILabel *lb = [[UILabel alloc] initWithFrame:CGRectMake(100.0f, 15.0f, 180.0f, 15.0f)];
                lb.tag = 5;
                lb.textColor = [UIColor lightGrayColor];
                lb.font = [UIFont systemFontOfSize:14];
                lb.backgroundColor = [UIColor clearColor];
                if ([workname length])
                {
                    lb.text = workname;
                }
                else
                {
                    lb.text = @"请选择维修人员";
                }
                
                UIImageView *im = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"dropdown_arrow.png"]];
                im.frame = CGRectMake(280.0f, 7, 30, 30);
                im.tag = 6;
                [cell addSubview:lb];
                if (state != ListSourceTypeDetail)
                {
                    [cell addSubview:im];
                }
            }
                break;
            case 1:
            {
                cell.textLabel.text = @"产品型号:";
                txt.text = equiptype;
                [cell addSubview:txt];
            }
                break;
            case 2:
            {
                cell.textLabel.text = @"购买日期:";
                if ([cell viewWithTag:7])
                {
                    [[cell viewWithTag:7] removeFromSuperview];
                }
                if ([cell viewWithTag:8])
                {
                    [[cell viewWithTag:8] removeFromSuperview];
                }
                
                UILabel *lb = [[UILabel alloc] initWithFrame:CGRectMake(100.0f, 15.0f, 180.0f, 15.0f)];
                lb.tag = 7;
                lb.textColor = [UIColor lightGrayColor];
                lb.font = [UIFont systemFontOfSize:14];
                lb.backgroundColor = [UIColor clearColor];
                if ([saletime length])
                {
                    lb.text = saletime;
                }
                else
                {
                    lb.text = @"请选择购买日期";
                }
                
                UIImageView *im = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"dropdown_arrow.png"]];
                im.frame = CGRectMake(280.0f, 7, 30, 30);
                im.tag = 8;
                [cell addSubview:lb];
                if (state != ListSourceTypeDetail)
                {
                    [cell addSubview:im];
                }

            }
                break;
            default:
                break;
        }
    }
    
    else if (indexPath.section == 2)
    {
        CGSize text_frm_size = [appearance sizeWithFont:[UIFont systemFontOfSize:14]
                                         constrainedToSize:CGSizeMake(300.0f, 1000.0f)
                                             lineBreakMode:NSLineBreakByCharWrapping];

        if ([appearance length])
        {
            txt.frame = CGRectMake(10, 0, 300, text_frm_size.height + 15);
        }
        else
        {
            txt.frame = CGRectMake(10, 0, 300, 44);
        }
        txt.text = appearance;
        [cell addSubview:txt];
    }

    else if (indexPath.section == 3)
    {
        switch (indexPath.row)
        {
            case 0:
            {
                cell.textLabel.text = @"销售类型:";
                if ([cell viewWithTag:9])
                {
                    [[cell viewWithTag:9] removeFromSuperview];
                }
                if ([cell viewWithTag:10000])
                {
                    [[cell viewWithTag:10000] removeFromSuperview];
                }
                
                UILabel *lb = [[UILabel alloc] initWithFrame:CGRectMake(100.0f, 15.0f, 180.0f, 15.0f)];
                lb.tag = 9;
                lb.textColor = [UIColor lightGrayColor];
                lb.font = [UIFont systemFontOfSize:14];
                lb.backgroundColor = [UIColor clearColor];
                if ([saletype length])
                {
                    lb.text = saletype;
                }
                
                UIImageView *im = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"dropdown_arrow.png"]];
                im.frame = CGRectMake(280.0f, 7, 30, 30);
                im.tag =10000;
                [cell addSubview:lb];
                if (state != ListSourceTypeDetail)
                {
                    [cell addSubview:im];
                }
            }
                break;
            case 1:
            {
                cell.textLabel.text = @"销售点电话:";
                txt.frame = CGRectMake(110.0f, 15.0f, 190, 25);
                txt.text = saletel;
                [cell addSubview:txt];
            }
                break;
            case 2:
            {
                cell.textLabel.text = @"维修日期:";
                if ([cell viewWithTag:10001])
                {
                    [[cell viewWithTag:10001] removeFromSuperview];
                }
                if ([cell viewWithTag:(indexPath.section + 1)*10 + indexPath.row])
                {
                    [[cell viewWithTag:(indexPath.section + 1)*10 + indexPath.row] removeFromSuperview];
                }

                UILabel *lb = [[UILabel alloc] initWithFrame:CGRectMake(100.0f, 15.0f, 180.0f, 15.0f)];
                lb.tag = (indexPath.section + 1)*10 + indexPath.row;
                lb.textColor = [UIColor lightGrayColor];
                lb.font = [UIFont systemFontOfSize:14];
                lb.backgroundColor = [UIColor clearColor];
                if ([worktime length])
                {
                    lb.text = worktime;
                }
                
                UIImageView *im = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"dropdown_arrow.png"]];
                im.frame = CGRectMake(280.0f, 7, 30, 30);
                im.tag =10001;
                [cell addSubview:lb];
                if (state != ListSourceTypeDetail)
                {
                    [cell addSubview:im];
                }
            }
                break;
            case 3:
            {
                cell.textLabel.text = @"机身号:";
                txt.text = equipid;
                [cell addSubview:txt];
            }
                break;
            default:
                break;
        }
    }

    else if (indexPath.section == 4)
    {
        switch (indexPath.row)
        {
            case 0:
                cell.textLabel.text = @"4S店名称:";
                txt.text = shopname;
                [cell addSubview:txt];
                break;
            case 1:
                cell.textLabel.text = @"4S店联系电话:";
                txt.frame = CGRectMake(130.0f, 10.0f, 190, 25);
                txt.text = shoptel;
                txt.backgroundColor = [UIColor clearColor];
                [cell addSubview:txt];
                break;
            case 2:
                cell.textLabel.text = @"车牌号码:";
                txt.text = customercarno;
                [cell addSubview:txt];
                break;
            default:
                break;
        }
    }

    else if (indexPath.section == 5)
    {
        switch (indexPath.row)
        {
            case 0:
            {
                cell.textLabel.text = @"品牌:";
                if ([cell viewWithTag:10002])
                {
                    [[cell viewWithTag:10002] removeFromSuperview];
                }
                if ([cell viewWithTag:(indexPath.section + 1)*10 + indexPath.row])
                {
                    [[cell viewWithTag:(indexPath.section + 1)*10 + indexPath.row] removeFromSuperview];
                }
                
                UILabel *lb = [[UILabel alloc] initWithFrame:CGRectMake(100.0f, 15.0f, 180.0f, 15.0f)];
                lb.tag = (indexPath.section + 1)*10 + indexPath.row;
                lb.textColor = [UIColor lightGrayColor];
                lb.font = [UIFont systemFontOfSize:14];
                lb.backgroundColor = [UIColor clearColor];
                if ([brand length])
                {
                    lb.text = brand;
                }
                
                UIImageView *im = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"dropdown_arrow.png"]];
                im.frame = CGRectMake(280.0f, 7, 30, 30);
                im.tag =10002;
                [cell addSubview:lb];
                if (state != ListSourceTypeDetail)
                {
                    [cell addSubview:im];
                }
            }
                break;
            case 1:
            {
                cell.textLabel.text = @"平台:";
                if ([cell viewWithTag:10003])
                {
                    [[cell viewWithTag:10003] removeFromSuperview];
                }
                if ([cell viewWithTag:(indexPath.section + 1)*10 + indexPath.row])
                {
                    [[cell viewWithTag:(indexPath.section + 1)*10 + indexPath.row] removeFromSuperview];
                }
                
                UILabel *lb = [[UILabel alloc] initWithFrame:CGRectMake(100.0f, 15.0f, 180.0f, 15.0f)];
                lb.tag = (indexPath.section + 1)*10 + indexPath.row;
                lb.textColor = [UIColor lightGrayColor];
                lb.font = [UIFont systemFontOfSize:14];
                lb.backgroundColor = [UIColor clearColor];
                if ([station length])
                {
                    lb.text = station;
                }
                
                UIImageView *im = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"dropdown_arrow.png"]];
                im.frame = CGRectMake(280.0f, 7, 30, 30);
                im.tag =10003;
                [cell addSubview:lb];
                if (state != ListSourceTypeDetail)
                {
                    [cell addSubview:im];
                }
            }
                break;
            case 2:
                cell.textLabel.text = @"更换的配件:";
                txt.frame = CGRectMake(110.0f, 10.0f, 190, 30);
                txt.text = parts;
                [cell addSubview:txt];
                break;
            default:
                break;
        }
    }

    else if (indexPath.section == 6)
    {
        switch (indexPath.row)
        {
            case 0:
            {
                cell.textLabel.text = @"是否收费:";
                
                if ([cell viewWithTag:10004])
                {
                    [[cell viewWithTag:10004] removeFromSuperview];
                }
                if ([cell viewWithTag:10005])
                {
                    [[cell viewWithTag:10005] removeFromSuperview];
                }
                if ([cell viewWithTag:10006])
                {
                    [[cell viewWithTag:10006] removeFromSuperview];
                }
                if ([cell viewWithTag:10007])
                {
                    [[cell viewWithTag:10007] removeFromSuperview];
                }
                
                index_path = indexPath;
                UIButton *b = [UIButton buttonWithType:UIButtonTypeCustom];
                [b setFrame:CGRectMake(100.0f, 2.0f, 40.0f, 40.0f)];
                b.tag = 10004;
                [b addTarget:self action:@selector(btn_charge_click:) forControlEvents:UIControlEventTouchUpInside];
                [cell addSubview:b];
                
                UILabel *lb = [[UILabel alloc] initWithFrame:CGRectMake(b.frame.origin.x + b.frame.size.width + 5, 15.0f, 20.0f, 15.0f)];
                lb.tag = 10005;
                lb.textColor = [UIColor lightGrayColor];
                lb.font = [UIFont systemFontOfSize:14];
                lb.backgroundColor = [UIColor clearColor];
                lb.text = @"是";
                [cell addSubview:lb];
                
                UIButton *c = [UIButton buttonWithType:UIButtonTypeCustom];
                [c setFrame:CGRectMake(170.0f, 2.0f, 40.0f, 40.0f)];
                c.tag = 10006;
                [c addTarget:self action:@selector(btn_charge_click:) forControlEvents:UIControlEventTouchUpInside];
                [cell addSubview:c];
                
                UILabel *l = [[UILabel alloc] initWithFrame:CGRectMake(c.frame.origin.x + c.frame.size.width + 5, 15.0f, 20.0f, 15.0f)];
                l.tag = 10007;
                l.textColor = [UIColor lightGrayColor];
                l.font = [UIFont systemFontOfSize:14];
                l.backgroundColor = [UIColor clearColor];
                l.text = @"否";
                [cell addSubview:l];
                
                if ([chargetag integerValue] == 1)
                {
                    [b setImage:[UIImage imageNamed:@"select.png"] forState:UIControlStateNormal];
                    [c setImage:[UIImage imageNamed:@"unselect.png"] forState:UIControlStateNormal];
                }
                else
                {
                    [c setImage:[UIImage imageNamed:@"select.png"] forState:UIControlStateNormal];
                    [b setImage:[UIImage imageNamed:@"unselect.png"] forState:UIControlStateNormal];
                }
            }
                break;
            case 1:
                cell.textLabel.text = @"金额(RMB)元:";
                txt.frame = CGRectMake(123.0f, 5.0f, 190, 25);
                txt.text = charge;
                [cell addSubview:txt];
                break;
            default:
                break;
        }
    }

    else if (indexPath.section == 7)
    {
        switch (indexPath.row)
        {
            case 0:
            {
                cell.textLabel.text = @"不良现象类型:";
                if ([cell viewWithTag:10008])
                {
                    [[cell viewWithTag:10008] removeFromSuperview];
                }
                if ([cell viewWithTag:(indexPath.section + 1)*10 + indexPath.row])
                {
                    [[cell viewWithTag:(indexPath.section + 1)*10 + indexPath.row] removeFromSuperview];
                }
                
                UILabel *lb = [[UILabel alloc] initWithFrame:CGRectMake(130.0f, 15.0f, 180.0f, 15.0f)];
                lb.tag = (indexPath.section + 1)*10 + indexPath.row;
                lb.textColor = [UIColor lightGrayColor];
                lb.font = [UIFont systemFontOfSize:14];
                lb.backgroundColor = [UIColor clearColor];
                if ([appearancetype length])
                {
                    lb.text = appearancetype;
                }
                
                UIImageView *im = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"dropdown_arrow.png"]];
                im.frame = CGRectMake(280.0f, 7, 30, 30);
                im.tag =10008;
                [cell addSubview:lb];
                if (state != ListSourceTypeDetail)
                {
                    [cell addSubview:im];
                }
            }
                break;
            case 1:
            {
                cell.textLabel.text = @"原因类型:";
                if ([cell viewWithTag:10009])
                {
                    [[cell viewWithTag:10009] removeFromSuperview];
                }
                if ([cell viewWithTag:(indexPath.section + 1)*10 + indexPath.row])
                {
                    [[cell viewWithTag:(indexPath.section + 1)*10 + indexPath.row] removeFromSuperview];
                }
                
                UILabel *lb = [[UILabel alloc] initWithFrame:CGRectMake(100.0f, 15.0f, 180.0f, 15.0f)];
                lb.tag = (indexPath.section + 1)*10 + indexPath.row;
                lb.textColor = [UIColor lightGrayColor];
                lb.font = [UIFont systemFontOfSize:14];
                lb.backgroundColor = [UIColor clearColor];
                if ([reasontype length])
                {
                    lb.text = reasontype;
                }
                
                UIImageView *im = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"dropdown_arrow.png"]];
                im.frame = CGRectMake(280.0f, 7, 30, 30);
                im.tag =10009;
                [cell addSubview:lb];
                if (state != ListSourceTypeDetail)
                {
                    [cell addSubview:im];
                }
            }
                break;
            case 2:
            {
                cell.textLabel.text = @"服务类型:";
                if ([cell viewWithTag:100010])
                {
                    [[cell viewWithTag:100010] removeFromSuperview];
                }
                if ([cell viewWithTag:(indexPath.section + 1)*10 + indexPath.row])
                {
                    [[cell viewWithTag:(indexPath.section + 1)*10 + indexPath.row] removeFromSuperview];
                }
                
                UILabel *lb = [[UILabel alloc] initWithFrame:CGRectMake(100.0f, 15.0f, 180.0f, 15.0f)];
                lb.tag = (indexPath.section + 1)*10 + indexPath.row;
                lb.textColor = [UIColor lightGrayColor];
                lb.font = [UIFont systemFontOfSize:14];
                lb.backgroundColor = [UIColor clearColor];
                if ([servicetype length])
                {
                    lb.text = servicetype;
                }
                
                UIImageView *im = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"dropdown_arrow.png"]];
                im.frame = CGRectMake(280.0f, 7, 30, 30);
                im.tag =100010;
                [cell addSubview:lb];
                if (state != ListSourceTypeDetail)
                {
                    [cell addSubview:im];
                }
            }
                break;
            default:
                break;
        }
    }

    else if (indexPath.section == 8)
    {
        CGSize text_frm_size = [reason sizeWithFont:[UIFont systemFontOfSize:14]
                                      constrainedToSize:CGSizeMake(300.0f, 1000.0f)
                                          lineBreakMode:NSLineBreakByCharWrapping];
        
        if ([reason length])
        {
            txt.frame = CGRectMake(10, 0, 300, text_frm_size.height + 15);
        }
        else
        {
            txt.frame = CGRectMake(10, 0, 300, 44);
        }
        txt.text = reason;
        [cell addSubview:txt];

    }
    
    else if (indexPath.section == 9)
    {
        CGSize text_frm_size = [solutions sizeWithFont:[UIFont systemFontOfSize:14]
                                      constrainedToSize:CGSizeMake(300.0f, 1000.0f)
                                          lineBreakMode:NSLineBreakByCharWrapping];
        
        if ([solutions length])
        {
            txt.frame = CGRectMake(10, 0, 300, text_frm_size.height + 15);
        }
        else
        {
            txt.frame = CGRectMake(10, 0, 300, 44);
        }
        txt.text = solutions;
        [cell addSubview:txt];
    }

    else if (indexPath.section == 10)
    {
        CGSize text_frm_size = [remark sizeWithFont:[UIFont systemFontOfSize:14]
                                     constrainedToSize:CGSizeMake(300.0f, 1000.0f)
                                         lineBreakMode:NSLineBreakByCharWrapping];
        
        if ([remark length])
        {
            txt.frame = CGRectMake(10, 0, 300, text_frm_size.height + 15);
        }
        else
        {
            txt.frame = CGRectMake(10, 0, 300, 44);
        }
        txt.text = remark;
        [cell addSubview:txt];
    }

    else if (indexPath.section == 11)
    {
        if (state == ListSourceTypeAdd)
        {
            UIView *bv = [[UIView alloc] initWithFrame:cell.frame];
            cell.backgroundView = bv;
            if ([cell viewWithTag:(indexPath.section + 1)*10 + indexPath.row])
            {
                [[cell viewWithTag:(indexPath.section + 1)*10 + indexPath.row] removeFromSuperview];
            }
            
            if([[[UIDevice currentDevice] systemVersion] floatValue]>=7.0)
            {
                UILabel *lb = [[UILabel alloc] initWithFrame:CGRectMake(60.0f, 13.0f, 180.0f, 18.0f)];
                lb.textColor = [UIColor whiteColor];
                lb.font = [UIFont fontWithName:@"Helvetica-Bold" size:18.0f];
                lb.backgroundColor = [UIColor clearColor];
                lb.text = @"上传图片";
                lb.textColor = [UIColor darkGrayColor];
                lb.textAlignment = UITextAlignmentCenter;
                [cell.contentView addSubview:lb];
                
                cell.backgroundColor = [UIColor colorWithRed:234.0f/255.0f green:237.0f/255.0f blue:240.0f/255.0f alpha:1.0f];
            }
            else
            {
                UIImageView *iv_bg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"updataPicture_bg.png"]];
                iv_bg.tag = (indexPath.section + 1)*10 + indexPath.row;
                [cell.contentView addSubview:iv_bg];
                
                UILabel *lb = [[UILabel alloc] initWithFrame:CGRectMake(60.0f, 15.0f, 180.0f, 18.0f)];
                lb.textColor = [UIColor darkGrayColor];
                lb.font = [UIFont systemFontOfSize:18];
                lb.backgroundColor = [UIColor clearColor];
                lb.text = @"上传图片";
                lb.textAlignment = UITextAlignmentCenter;
                [iv_bg addSubview:lb];
            }
            //

          
        }
        else if (state == ListSourceTypeEdit)
        {
            UIView *bv = [[UIView alloc] initWithFrame:cell.frame];
            cell.backgroundView = bv;
            if ([cell viewWithTag:(indexPath.section + 1)*10 + indexPath.row])
            {
                [[cell viewWithTag:(indexPath.section + 1)*10 + indexPath.row] removeFromSuperview];
            }
            //
            
            if([[[UIDevice currentDevice] systemVersion] floatValue]>=7.0)
            {
                UILabel *lb = [[UILabel alloc] initWithFrame:CGRectMake(60.0f, 13.0f, 180.0f, 18.0f)];
                lb.textColor = [UIColor whiteColor];
                lb.font = [UIFont fontWithName:@"Helvetica-Bold" size:18.0f];
                lb.backgroundColor = [UIColor clearColor];
                lb.text = @"保 存";
                lb.textColor = [UIColor whiteColor];
                lb.textAlignment = UITextAlignmentCenter;
                [cell.contentView addSubview:lb];
                
                cell.backgroundColor = [UIColor colorWithRed:253.0f/255.0f green:146.0f/255.0f blue:38.0f/255.0f alpha:1.0f];
            }
            else
            {
                UIImageView *iv_bg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"submit_bg.png"]];
                iv_bg.tag = (indexPath.section + 1)*10 + indexPath.row;
                [cell.contentView addSubview:iv_bg];
                
                UILabel *lb = [[UILabel alloc] initWithFrame:CGRectMake(60.0f, 15.0f, 180.0f, 18.0f)];
                lb.textColor = [UIColor whiteColor];
                lb.font = [UIFont fontWithName:@"Helvetica-Bold" size:10.0f];
                lb.backgroundColor = [UIColor clearColor];
                lb.text = @"保存";
                lb.textAlignment = UITextAlignmentCenter;
                [iv_bg addSubview:lb];
            }
            
            //


        }
        
        else if (state == ListSourceTypeDetail)
        {
            txt.frame = CGRectMake(10, 0, 300, 100);
            txt.text = huifang;
            [cell addSubview:txt];
        }
    }
    
    else if (indexPath.section == 12)
    {
        if (state == ListSourceTypeAdd)
        {
            UIView *bv = [[UIView alloc] initWithFrame:cell.frame];
            cell.backgroundView = bv;
            if ([cell viewWithTag:(indexPath.section + 1)*10 + indexPath.row])
            {
                [[cell viewWithTag:(indexPath.section + 1)*10 + indexPath.row] removeFromSuperview];
            }
            
            //
            if([[[UIDevice currentDevice] systemVersion] floatValue]>=7.0)
            {
                UIImageView *iv_bg = [[UIImageView alloc] init];
                iv_bg.tag = (indexPath.section + 1)*10 + indexPath.row;
                [cell.contentView addSubview:iv_bg];
                UILabel *lb = [[UILabel alloc] initWithFrame:CGRectMake(60.0f, 15.0f, 180.0f, 18.0f)];
                lb.textColor = [UIColor whiteColor];
                lb.font = [UIFont fontWithName:@"Helvetica-Bold" size:18.0f];
                lb.backgroundColor = [UIColor clearColor];
                lb.text = @"提 交";
                lb.textAlignment = UITextAlignmentCenter;
                [iv_bg addSubview:lb];
                cell.backgroundColor = [UIColor colorWithRed:253.0f/255.0f green:146.0f/255.0f blue:38.0f/255.0f alpha:1.0f];
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
                lb.text = @"提 交";
                lb.textAlignment = UITextAlignmentCenter;
                [iv_bg addSubview:lb];
            }

            //

        }
        else
        {
            static NSString *CellIdentifier = @"HistoryCell";
            NSMutableDictionary *area_info = [history_buffer objectAtIndex:indexPath.row];
            HistoryCell *cell = (HistoryCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            
            if (nil == cell)
            {
                UIViewController *uc = [[UIViewController alloc] initWithNibName:CellIdentifier bundle:nil];
                cell = (HistoryCell *)uc.view;
                [cell setContent:area_info];
            }
            return cell;

        }
    }


    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 40.0f)];
    v.backgroundColor = [UIColor clearColor];
    
    UILabel *lb = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, 5.0f, 100.0f, 30.0f)];
    lb.font = [UIFont fontWithName:@"Helvetica" size:15];
    lb.backgroundColor = [UIColor clearColor];
    
    UIImageView *im = [[UIImageView alloc] initWithImage:[UIImage  imageNamed:@"fengexian_more"]];
    im.frame = CGRectMake(79.0f, 18.0f, 230.0f, 2.0f);
    switch (section)
    {
        case 0:
            lb.text = @"客服填写";
            lb.textColor = [UIColor colorWithRed:255.0f/255.0f green:96.0f/255.0f blue:0.0f alpha:1.0f];
            [v addSubview:im];
            break;
        case 2:
            lb.text = @"问题描述";
            lb.textColor = [UIColor lightGrayColor];
            break;
        case 3:
            lb.text = @"售后填写";
            lb.textColor = [UIColor colorWithRed:255.0f/255.0f green:96.0f/255.0f blue:0.0f alpha:1.0f];
            [v addSubview:im];
            break;
        case 8:
            lb.text = @"具体原因";
            lb.textColor = [UIColor lightGrayColor];
            break;
        case 9:
            lb.text = @"解决方案";
            lb.textColor = [UIColor lightGrayColor];
            break;
        case 10:
            lb.text = @"备注";
            lb.textColor = [UIColor lightGrayColor];
            break;
        case 11:
            if (state == ListSourceTypeDetail)
            {
                lb.text = @"回访事项";
                lb.textColor = [UIColor lightGrayColor];
            }
            break;
        case 12:
            if (state == ListSourceTypeDetail)
            {
                lb.text = @"历史记录";
                lb.textColor = [UIColor lightGrayColor];
            }
            break;
        default:
            break;
    }
    [v addSubview:lb];
    
    if ([lb.text length])
    {
        return v;
    }
    return nil;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if (section == 10 && (image || [imgurl length]))
    {
        UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 200.0f)];
        v.backgroundColor = [UIColor clearColor];
        
        if (image)
        {
            imageview = [[UIImageView alloc] initWithImage:image];
        }
        else
        {
            UIImage *avatar_im = [RWImageBuffer readFromFile:imgurl];
            if (avatar_im)
            {
                image = avatar_im;
                imageview = [[UIImageView alloc] initWithImage:avatar_im];

            }
            else
            {
                RRRemoteImage *r_img = [[RRRemoteImage alloc] initWithURLString:imgurl
                                                                     parentView:imageview
                                                                       delegate:self
                                                               defaultImageName:@"home_beauty_default.png"];
                
                imageview = [[UIImageView alloc] initWithImage:r_img];
            }
        }
        imageview.frame= CGRectMake(60.0f, 10.0f, 200.0f, 190.0f);
        [v addSubview:imageview];
        
        imageview.userInteractionEnabled = YES;
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didViewCurrentPhoto:)];
        [imageview addGestureRecognizer:singleTap];
        return v;
    }
    
    return nil;
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    switch (section)
    {
        case 0:
        case 2:
        case 3:
        case 8:
        case 9:
        case 10:
            return 40.0f;
        case 11:
            if (state == ListSourceTypeDetail)
            {
                return 40.0f;
            }
            break;
        case 12:
            if (state == ListSourceTypeDetail)
            {
                return 40.0f;
            }
            break;
        default:
            break;
    }
    
    return 0.0f;

}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section == 10 && (image || [imgurl length]))
    {
        return 200.0f;
    }
    return 0.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGSize text_frm_size = CGSizeMake(300.0f, 44.0f);
    switch (indexPath.section)
    {
        case 2:
            if ([appearance length])
            {
                text_frm_size = [appearance sizeWithFont:[UIFont systemFontOfSize:14]
                                       constrainedToSize:CGSizeMake(300.0f, 1000.0f)
                                           lineBreakMode:NSLineBreakByCharWrapping];
                text_frm_size.height += 20;
            }
             break;
        case 8:
            if ([reason length])
            {
                text_frm_size = [reason sizeWithFont:[UIFont systemFontOfSize:14]
                                   constrainedToSize:CGSizeMake(300.0f, 1000.0f)
                                       lineBreakMode:NSLineBreakByCharWrapping];
                text_frm_size.height += 20;

            }
            break;
        case 9:
            if ([solutions length])
            {
                text_frm_size = [solutions sizeWithFont:[UIFont systemFontOfSize:14]
                                      constrainedToSize:CGSizeMake(300.0f, 1000.0f)
                                          lineBreakMode:NSLineBreakByCharWrapping];
                text_frm_size.height += 20;

            }
            break;
        case 10:
            if ([remark length])
            {
                text_frm_size = [remark sizeWithFont:[UIFont systemFontOfSize:14]
                                   constrainedToSize:CGSizeMake(300.0f, 1000.0f)
                                       lineBreakMode:NSLineBreakByCharWrapping];
                text_frm_size.height += 20;
            }
            break;
        case  11:
        {
            if (state == ListSourceTypeDetail)
            {
                text_frm_size.height += 100;
            }
        }
            break;
        case 12:
        {
            if (state != ListSourceTypeAdd)
            {
                text_frm_size.height = [HistoryCell calCellHeight:[history_buffer objectAtIndex:indexPath.row]];
            }
        }
        default:
            break;
    }
    
    return text_frm_size.height;

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    srcType = (indexPath.section + 1)*10 + indexPath.row;
    
    if (indexPath.section == 0 && indexPath.row == 2 && state != ListSourceTypeDetail)
    {
        [self fentchProvinceId];
    }
    else if (indexPath.section == 0 && indexPath.row == 3 && state != ListSourceTypeDetail)
    {
        [self fentchCityId];
    }
    else if (indexPath.section == 1 && indexPath.row == 0 && state != ListSourceTypeDetail)
    {
        if ([cityid length] == 0)
        {
            [RRAlertView show:@"请先选择城市!"];
            return;
        }
        [self fentchWorker];
    }
    else if (indexPath.section == 1 && indexPath.row == 2)
    {
        [self actionWithType:1];
    }
    else if (indexPath.section == 3 && indexPath.row == 0)
    {
        [self actionWithType:0];
    }
    else if (indexPath.section == 3 && indexPath.row == 2)
    {
        [self actionWithType:1];
    }
    else if (indexPath.section == 5 && indexPath.row == 0)
    {
        [self actionWithType:0];
    }
    else if (indexPath.section == 5 && indexPath.row == 1)
    {
        [self actionWithType:0];
    }
    else if (indexPath.section == 7 && (indexPath.row == 0 ||indexPath.row == 1 ||indexPath.row == 2))
    {
        [self actionWithType:0];
    }
    
    else if (indexPath.section == 11 && state == ListSourceTypeAdd)
    {
        [self actionWithType:2];
    }

    else if (indexPath.section == 11 && state == ListSourceTypeEdit)
    {
        [self handleOrder];
    }

    else if (indexPath.section == 12 && state == ListSourceTypeAdd)
    {
        [self handleOrder];
    }
}

#pragma mark -
- (void)showLeftSideBar:(id)sender
{
    if ([[SidebarViewController share] respondsToSelector:@selector(showSideBarControllerWithDirection:)]) {
        [[SidebarViewController share] showSideBarControllerWithDirection:SideBarShowDirectionLeft];
    }
}

- (void)btn_submit_click:(id)sender
{
    [self handleOrder];
}

- (void)btn_charge_click:(id)seder
{
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:index_path];
    UIButton *b = (UIButton *)[cell viewWithTag:10004];
    UIButton *c = (UIButton *)[cell viewWithTag:10006];
    
    if ([chargetag integerValue] == 2 || [chargetag integerValue] == 0 )
    {
        chargetag = @"1";
        [b setImage:[UIImage imageNamed:@"select.png"] forState:UIControlStateNormal];
        [c setImage:[UIImage imageNamed:@"unselect.png"] forState:UIControlStateNormal];
    }
    else if ([chargetag integerValue] == 1 || [chargetag integerValue] == 0 )
    {
        chargetag = @"2";
        [c setImage:[UIImage imageNamed:@"select.png"] forState:UIControlStateNormal];
        [b setImage:[UIImage imageNamed:@"unselect.png"] forState:UIControlStateNormal];
    }

}

- (void) didViewCurrentPhoto:(id)sender
{
	RRViewPhotoController *ctrl = [[RRViewPhotoController alloc] initWithNibName:@"RRViewPhoto" bundle:nil];
	ctrl.hidesBottomBarWhenPushed = YES;
	ctrl.delegate = self;
	ctrl.im_image = image;
	[self.navigationController pushViewController:ctrl animated:YES];
}

- (void) didCleanPhoto
{
	image = nil;
    [self.tableView reloadData];
}

- (void)btn_next_click:(id)sender
{
    [self handleOrderWithTag:[page integerValue]];
}

#pragma mark - textViewDelegate
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    if (state == ListSourceTypeDetail)
    {
        return NO;
    }
    
    return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    textView.text = @"";
    [active_txt resignFirstResponder];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    active_txt = textView;
    
    switch (textView.tag)
    {
        case 10:
            customername = textView.text;
            break;
        case 11:
            customertel = textView.text;
            break;
        case 21:
            equiptype = textView.text;
            break;
        case 30:
            appearance = textView.text;
            break;
        case 41:
            saletel = textView.text;
            break;
        case 43:
            equipid = textView.text;
            break;
        case 50:
            shopname = textView.text;
            break;
        case 51:
            shoptel = textView.text;
            break;
        case 52:
            customercarno = textView.text;
            break;
        case 62:
            parts = textView.text;
            break;
        case 71:
            charge = textView.text;
            break;
        case 90:
            reason = textView.text;
            break;
        case 100:
            solutions = textView.text;
            break;
        case 110:
            remark = textView.text;
            break;
        default:
            break;
    }
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

- (void)loadData
{
    if (is_loading)
	{
		return;
	}
	
	is_loading = YES;
	[RWShowView show:@"loading"];
	NSString *full_url = [NSString stringWithFormat:@"%@%@", BASE_URL, VIEWINFO_URL];
	RRURLRequest *req = [[RRURLRequest alloc] initWithURLString:full_url];
	RRToken *token_tmp = [RRToken getInstance];
    [req setParam:[token_tmp getProperty:@"token"] forKey:@"token"];
    [req setParam:self.orderId forKey:@"id"];
	[req setHTTPMethod:@"POST"];
	
	RRLoader *loader = [[RRLoader alloc] initWithRequest:req];
	[loader addNotificationListener:RRLOADER_FAIL target:self action:@selector(onFetchFail:)];
	[loader addNotificationListener:RRLOADER_COMPLETE target:self action:@selector(onLoadData:)];
	[loader loadwithTimer];
	[RWShowView show:@"loading"];
    
}

- (void)onLoadData:(NSNotification *)notify
{
    is_loading = NO;
    [RWShowView closeAlert];
	RRLoader *loader = (RRLoader *)[notify object];
	NSDictionary *json = [loader getJSONData];
    
	[loader removeNotificationListener:RRLOADER_FAIL target:self];
	[loader removeNotificationListener:RRLOADER_COMPLETE target:self];
	
	if (![[json objectForKey:@"success"] boolValue])
	{
        [RRAlertView show:@"没有请求到数据!"];
        [RWShowView closeAlert];
		return;
    }
    
    if (![[json objectForKey:@"data"] count])
    {
        [RRAlertView show:@"没有请求到数据!"];
        return;
    }
    
    info_dic = [NSMutableDictionary dictionaryWithDictionary:[[json objectForKey:@"data"] objectForKey:@"info"]];
    history_buffer = [NSMutableArray arrayWithArray:[[json objectForKey:@"data"] objectForKey:@"history"]];
    order_dic = [NSMutableDictionary dictionaryWithDictionary:[[json objectForKey:@"data"] objectForKey:@"order"]];
    [self handleData];
    return;
}

- (void)handleData
{
    if ([info_dic objectForKey:@"province"] && (NSNull *)[info_dic objectForKey:@"province"] != [NSNull null])
    {
        province = [info_dic objectForKey:@"province"];
    }
    if ([info_dic objectForKey:@"provinceid"]&& (NSNull *)[info_dic objectForKey:@"provinceid"] != [NSNull null])
    {
        provinceid = [info_dic objectForKey:@"provinceid"];
    }
    if ([info_dic objectForKey:@"cityid"]&& (NSNull *)[info_dic objectForKey:@"cityid"] != [NSNull null])
    {
        cityid = [info_dic objectForKey:@"cityid"];
    }
    if ([info_dic objectForKey:@"city"]&& (NSNull *)[info_dic objectForKey:@"city"] != [NSNull null])
    {
        city = [info_dic objectForKey:@"city"];
    }
    if ([info_dic objectForKey:@"brand"] && (NSNull *)[info_dic objectForKey:@"brand"] != [NSNull null])
    {
        brand = [info_dic objectForKey:@"brand" ];
    }
    if ([info_dic objectForKey:@"station"] && (NSNull *)[info_dic objectForKey:@"station"] != [NSNull null])
    {
        station = [info_dic objectForKey:@"station" ];
    }
    if ([info_dic objectForKey:@"equiptype"] && (NSNull *)[info_dic objectForKey:@"equiptype"] != [NSNull null])
    {
        equiptype = [info_dic objectForKey:@"equiptype" ];
    }
    if ([info_dic objectForKey:@"equipid"] && (NSNull *)[info_dic objectForKey:@"equipid"] != [NSNull null])
    {
        equipid = [info_dic objectForKey:@"equipid" ];
    }
    if ([info_dic objectForKey:@"saletype"] && (NSNull *)[info_dic objectForKey:@"saletype"] != [NSNull null])
    {
        saletype = [info_dic objectForKey:@"saletype" ];
    }
    if ([info_dic objectForKey:@"saletel"] && (NSNull *)[info_dic objectForKey:@"saletel"] != [NSNull null])
    {
        saletel = [info_dic objectForKey:@"saletel" ];
    }
    if ([info_dic objectForKey:@"saletime"] && (NSNull *)[info_dic objectForKey:@"saletime"] != [NSNull null])
    {
        saleDate = [info_dic objectForKey:@"saletime"];
        saletime = [self getTimeFormatWithString:saleDate];
    }
    if ([info_dic objectForKey:@"customername"] && (NSNull *)[info_dic objectForKey:@"customername"] != [NSNull null])
    {
        customername = [info_dic objectForKey:@"customername"];
    }
    if ([info_dic objectForKey:@"customercarno"] && (NSNull *)[info_dic objectForKey:@"customercarno"] != [NSNull null])
    {
        customercarno = [info_dic objectForKey:@"customercarno"];
    }
    if ([info_dic objectForKey:@"customertel"] && (NSNull *)[info_dic objectForKey:@"customertel"] != [NSNull null])
    {
        customertel = [info_dic objectForKey:@"customertel"];
    }
    if ([info_dic objectForKey:@"shopname"] && (NSNull *)[info_dic objectForKey:@"shopname"] != [NSNull null])
    {
        shopname = [info_dic objectForKey:@"shopname"];
    }
    if ([info_dic objectForKey:@"shoptel"] && (NSNull *)[info_dic objectForKey:@"shoptel"] != [NSNull null])
    {
        shoptel = [info_dic objectForKey:@"shoptel"];
    }
    if ([info_dic objectForKey:@"parts"] && (NSNull *)[info_dic objectForKey:@"parts"] != [NSNull null])
    {
        parts = [info_dic objectForKey:@"parts"];
    }
    
    if ([info_dic objectForKey:@"chargetag"] && (NSNull *)[info_dic objectForKey:@"chargetag"] != [NSNull null])
    {
        chargetag = [info_dic objectForKey:@"chargetag"];
    }

    if ([info_dic objectForKey:@"charge"] && (NSNull *)[info_dic objectForKey:@"charge"] != [NSNull null])
    {
        charge = [info_dic objectForKey:@"charge"];
    }
    if ([info_dic objectForKey:@"appearancetype"] && (NSNull *)[info_dic objectForKey:@"appearancetype"] != [NSNull null])
    {
        appearancetype = [info_dic objectForKey:@"appearancetype"];
    }
    if ([info_dic objectForKey:@"appearance"] && (NSNull *)[info_dic objectForKey:@"appearance"] != [NSNull null])
    {
        appearance = [info_dic objectForKey:@"appearance"];
    }
    if ([info_dic objectForKey:@"reasontype"] && (NSNull *)[info_dic objectForKey:@"reasontype"] != [NSNull null])
    {
        reasontype = [info_dic objectForKey:@"reasontype"];
    }
    if ([info_dic objectForKey:@"reason"] && (NSNull *)[info_dic objectForKey:@"reason"] != [NSNull null])
    {
        reason = [info_dic objectForKey:@"reason"];
    }
    if ([info_dic objectForKey:@"servicetype"] && (NSNull *)[info_dic objectForKey:@"servicetype"] != [NSNull null])
    {
        servicetype = [info_dic objectForKey:@"servicetype"];
    }
    if ([info_dic objectForKey:@"solutions"] && (NSNull *)[info_dic objectForKey:@"solutions"] != [NSNull null])
    {
        solutions = [info_dic objectForKey:@"solutions"];
    }
    if ([info_dic objectForKey:@"remark"] && (NSNull *)[info_dic objectForKey:@"remark"] != [NSNull null])
    {
        remark = [info_dic objectForKey:@"remark"];
    }
    if ([info_dic objectForKey:@"workerid"] && (NSNull *)[info_dic objectForKey:@"workerid"] != [NSNull null])
    {
         workerid = [info_dic objectForKey:@"workerid"];
    }
    if ([info_dic objectForKey:@"workername"] && (NSNull *)[info_dic objectForKey:@"workername"] != [NSNull null])
    {
        workname = [info_dic objectForKey:@"workername"];
    }
    if ([info_dic objectForKey:@"worktime"] && (NSNull *)[info_dic objectForKey:@"worktime"] != [NSNull null])
    {
        workDate = [info_dic objectForKey:@"worktime"];
        worktime = [self getTimeFormatWithString:workDate];
    }
    
    if ([info_dic objectForKey:@"imgurl"]  && (NSNull *)[info_dic objectForKey:@"imgurl"] != [NSNull null])
    {
        imgurl = [info_dic objectForKey:@"imgurl"];
        if ([imgurl length])
        {
            NSArray *arr = [imgurl componentsSeparatedByString:@"|"];
            imgurl = [NSString stringWithFormat:@"%@/uploads/orderimg/%@",BASE_URL, [arr objectAtIndex:0] ];
        }
    }

    huifang = [NSMutableString stringWithCapacity:0];
    switch ([[order_dic objectForKey:@"dress"] integerValue])
    {
        case 1:
            [huifang appendString:@"是否统一着装: 统一"];
            break;
        case 2:
            [huifang appendString:@"是否统一着装: 不统一"];
            break;
        default:
            break;
    }
    
    switch ([[order_dic objectForKey:@"attitude"] integerValue])
    {
        case 1:
            [huifang appendString:@"\n服务态度: 满意"];
            break;
        case 2:
            [huifang appendString:@"\n服务态度: 一般"];
            break;
        case 3:
            [huifang appendString:@"\n服务态度: 不满意"];
            break;

        default:
            break;
    }

    switch ([[order_dic objectForKey:@"speed"] integerValue])
    {
        case 1:
            [huifang appendString:@"\n处理速度: 满意"];
            break;
        case 2:
            [huifang appendString:@"\n处理速度: 一般"];
            break;
        case 3:
            [huifang appendString:@"\n处理速度: 不满意"];
            break;
            
        default:
            break;
    }
    
    switch ([[order_dic objectForKey:@"quality"] integerValue])
    {
        case 1:
            [huifang appendString:@"\n服务效果: 满意"];
            break;
        case 2:
            [huifang appendString:@"\n服务效果: 一般"];
            break;
        case 3:
            [huifang appendString:@"\n服务效果: 不满意"];
            break;
            
        default:
            break;
    }
    [self.tableView reloadData];
}

- (void)fentchProvinceId
{

    if ([RWHomeCache readFromFile:@"province"])
    {

        province_buffer = [RWHomeCache readFromFile:@"province"];
        [self actionWithType:0];
        return;
    }
    else
    {

        [self fentchProvince];
    }
}

- (void)fentchProvince
{
    if (is_loading)
	{
		return;
	}
    
	is_loading = YES;
	[RWShowView show:@"loading"];
	NSString *full_url = [NSString stringWithFormat:@"%@%@", BASE_URL, PROVINCE_URL];
	RRURLRequest *req = [[RRURLRequest alloc] initWithURLString:full_url];
	RRToken *token_tmp = [RRToken getInstance];
    [req setParam:[token_tmp getProperty:@"token"] forKey:@"token"];
	[req setHTTPMethod:@"POST"];
	RRLoader *loader = [[RRLoader alloc] initWithRequest:req];
	[loader addNotificationListener:RRLOADER_FAIL target:self action:@selector(onFetchFail:)];
	[loader addNotificationListener:RRLOADER_COMPLETE target:self action:@selector(onGetProvinceId:)];
	[loader loadwithTimer];
	[RWShowView show:@"loading"];
   
}

- (void)onGetProvinceId:(NSNotification *)notify
{
    is_loading = NO;
    [RWShowView closeAlert];
	RRLoader *loader = (RRLoader *)[notify object];
	NSDictionary *json = [loader getJSONData];
	[loader removeNotificationListener:RRLOADER_FAIL target:self];
	[loader removeNotificationListener:RRLOADER_COMPLETE target:self];
	
	if (![[json objectForKey:@"success"] boolValue])
	{
        [RRAlertView show:@"没有请求到数据!"];
        [RWShowView closeAlert];
		return;
    }
    
    if (![[json objectForKey:@"data"] count])
    {
        [RRAlertView show:@"没有请求到数据!"];
        return;
    }
    
    [province_buffer removeAllObjects];
    [province_buffer addObjectsFromArray:[json objectForKey:@"data"]];
    [RWHomeCache writeToFile:province_buffer withName:@"province"];
    [self actionWithType:0];
    return;
}

- (void)fentchCityId
{
    if ([provinceid length] == 0)
    {
        [RRAlertView show:@"请先选择省份!"];
        return;
    }
    if ([RWHomeCache readFromFile:@"city"])
    {
        city_buffer = [RWHomeCache readFromFile:@"city"];
        NSMutableArray *arr = [NSMutableArray arrayWithArray:[self filtCityArray:city_buffer]];
        [city_buffer removeAllObjects];
        [city_buffer addObjectsFromArray:arr];
        [self actionWithType:0];
        return;
    }
    else
    {
        [self fentchCity];
    }
}

- (NSMutableArray *)filtCityArray:(NSMutableArray *)arr
{
    NSMutableArray *buffer = [NSMutableArray arrayWithArray:arr];
    NSMutableArray *cityBuffer = [NSMutableArray arrayWithCapacity:0];
    
    for (int i = 0; i < [buffer count]; i++)
    {
        if ([[[buffer objectAtIndex:i] objectForKey:@"provinceid"] isEqualToString:provinceid])
        {
            [cityBuffer addObject:[buffer objectAtIndex:i]];
        }
    }
    
    return cityBuffer;
}

- (void)fentchCity
{
    if (is_loading)
	{
		return;
	}
	
	is_loading = YES;
	[RWShowView show:@"loading"];
	NSString *full_url = [NSString stringWithFormat:@"%@%@", BASE_URL, CITY_URL];
	RRURLRequest *req = [[RRURLRequest alloc] initWithURLString:full_url];
	RRToken *token_tmp = [RRToken getInstance];
    [req setParam:[token_tmp getProperty:@"token"] forKey:@"token"];
	[req setHTTPMethod:@"POST"];
	
	RRLoader *loader = [[RRLoader alloc] initWithRequest:req];
	[loader addNotificationListener:RRLOADER_FAIL target:self action:@selector(onFetchFail:)];
	[loader addNotificationListener:RRLOADER_COMPLETE target:self action:@selector(onGetCityId:)];
	[loader loadwithTimer];
	[RWShowView show:@"loading"];
    
}

- (void)onGetCityId:(NSNotification *)notify
{
    is_loading = NO;
    [RWShowView closeAlert];
	RRLoader *loader = (RRLoader *)[notify object];
	NSDictionary *json = [loader getJSONData];
	[loader removeNotificationListener:RRLOADER_FAIL target:self];
	[loader removeNotificationListener:RRLOADER_COMPLETE target:self];
	
	if (![[json objectForKey:@"success"] boolValue])
	{
        [RRAlertView show:@"没有请求到数据!"];
        [RWShowView closeAlert];
		return;
    }
    
    if (![[json objectForKey:@"data"] count])
    {
        [RRAlertView show:@"没有请求到数据!"];
        return;
    }
    
    [city_buffer removeAllObjects];
    [city_buffer addObjectsFromArray:[json objectForKey:@"data"]];
    [RWHomeCache writeToFile:city_buffer withName:@"city"];
    NSMutableArray *arr = [NSMutableArray arrayWithArray:[self filtCityArray:city_buffer]];
    [city_buffer removeAllObjects];
    [city_buffer addObjectsFromArray:arr];
    [self actionWithType:0];
    return;
}

- (void)fentchWorker
{
    if (is_loading)
	{
		return;
	}
	
	is_loading = YES;
	[RWShowView show:@"loading"];
	NSString *full_url = [NSString stringWithFormat:@"%@%@", BASE_URL, GETUSER_URL];
	RRURLRequest *req = [[RRURLRequest alloc] initWithURLString:full_url];
	RRToken *token_tmp = [RRToken getInstance];
    [req setParam:[token_tmp getProperty:@"token"] forKey:@"token"];
    [req setParam:cityid forKey:@"cityid"];

	[req setHTTPMethod:@"POST"];
	
	RRLoader *loader = [[RRLoader alloc] initWithRequest:req];
	[loader addNotificationListener:RRLOADER_FAIL target:self action:@selector(onFetchFail:)];
	[loader addNotificationListener:RRLOADER_COMPLETE target:self action:@selector(onFentchWorker:)];
	[loader loadwithTimer];
	[RWShowView show:@"loading"];
    
}

- (void)onFentchWorker:(NSNotification *)notify
{
    is_loading = NO;
    [RWShowView closeAlert];
	RRLoader *loader = (RRLoader *)[notify object];
	NSDictionary *json = [loader getJSONData];
	[loader removeNotificationListener:RRLOADER_FAIL target:self];
	[loader removeNotificationListener:RRLOADER_COMPLETE target:self];
	
	if (![[json objectForKey:@"success"] boolValue])
	{
        [RRAlertView show:@"没有请求到数据!"];
        [RWShowView closeAlert];
		return;
    }
    
    if (![[[json objectForKey:@"data"]objectForKey:@"list"] count])
    {
        [RRAlertView show:@"没有请求到数据!"];
        return;
    }
    
    [worker_buffer removeAllObjects];
    [worker_buffer addObjectsFromArray:[[json objectForKey:@"data"] objectForKey:@"list"]];
    [self actionWithType:0];
    return;
}

- (void)handleOrder
{
    [active_txt resignFirstResponder];
    
    if (state != ListSourceTypeDetail)
    {
        if (![provinceid length])
        {
            [RRAlertView show:@"还没有选择省份!"];
            return;
        }
        if (![cityid length])
        {
            [RRAlertView show:@"还没有选择城市!"];
            return;
        }
        if (![customername length])
        {
            [RRAlertView show:@"还没有填写客户名称!"];
            return;
        }
        if (![customertel length])
        {
            [RRAlertView show:@"还没有填写客户电话!"];
            return;
        }
        if (![appearance length])
        {
            [RRAlertView show:@"还没有填写不良现象!"];
            return;
        }
        
        [self submit];
    }
}

- (void)submit
{
    if (is_loading)
	{
		return;
	}
	
	is_loading = YES;
	[RWShowView show:@"loading"];
    NSString *full_url = nil;
    if (state == ListSourceTypeEdit)
    {
        full_url = [NSString stringWithFormat:@"%@%@", BASE_URL, UPDATA_URL];
    }
    else
    {
        full_url = [NSString stringWithFormat:@"%@%@", BASE_URL, CREATE_URL];
    }
    
	RRURLRequest *req = [[RRURLRequest alloc] initWithURLString:full_url];
	RRToken *token_tmp = [RRToken getInstance];
    [req setParam:[token_tmp getProperty:@"token"] forKey:@"token"];
    if (state == ListSourceTypeEdit)
    {
        [req setParam:self.orderId forKey:@"id"];
    }
    if (province)
    {
        [req setParam:province forKey:@"info[province]"];
    }
    if (provinceid)
    {
        [req setParam:provinceid forKey:@"info[provinceid]"];
    }
    if (cityid)
    {
        [req setParam:cityid forKey:@"info[cityid]"];
    }
    if (city)
    {
        [req setParam:city forKey:@"info[city]"];
    }
    if (brand)
    {
        [req setParam:brand forKey:@"info[brand]"];
    }
    if (station)
    {
        [req setParam:station forKey:@"info[station]"];
    }
    if (equiptype)
    {
        [req setParam:equiptype forKey:@"info[equiptype]"];
    }
    if (equipid)
    {
        [req setParam:equipid forKey:@"info[equipid]"];
    }
    if (saletype)
    {
        [req setParam:saletype forKey:@"info[saletype]"];
    }
    if (saletel)
    {
        [req setParam:saletel forKey:@"info[saletel]"];
    }
    if (saleDate)
    {
        [req setParam:saleDate forKey:@"info[saletime]"];
    }
    if (customername)
    {
        [req setParam:customername forKey:@"info[customername]"];
    }
    if (customercarno)
    {
        [req setParam:customercarno forKey:@"info[customercarno]"];
    }
    if (customertel)
    {
        [req setParam:customertel forKey:@"info[customertel]"];
    }
    if (shopname)
    {
        [req setParam:shopname forKey:@"info[shopname]"];
    }
    if (shoptel)
    {
        [req setParam:shoptel forKey:@"info[shoptel]"];
    }
    if (parts)
    {
        [req setParam:parts forKey:@"info[parts]"];
    }
    if ([chargetag integerValue]!=0)
    {
        [req setParam:chargetag forKey:@"info[chargetag]"];
    }
    if (charge)
    {
        [req setParam:charge forKey:@"info[charge]"];
    }
    if (appearancetype)
    {
        [req setParam:appearancetype forKey:@"info[appearancetype]"];
    }
    if (appearance)
    {
        [req setParam:appearance forKey:@"info[appearance]"];
    }
    if (reasontype)
    {
        [req setParam:reasontype forKey:@"info[reasontype]"];
    }
    if (reason)
    {
        [req setParam:reason forKey:@"info[reason]"];
    }
    if (servicetype)
    {
        [req setParam:servicetype forKey:@"info[servicetype]"];
    }
    if (solutions)
    {
        [req setParam:solutions forKey:@"info[solutions]"];
    }
    if (remark)
    {
        [req setParam:remark forKey:@"info[remark]"];
    }
    if (workerid)
    {
        [req setParam:workerid forKey:@"info[workerid]"];
    }
    if (workname)
    {
        [req setParam:workname forKey:@"info[workername]"];
    }
    if (workDate)
    {
        [req setParam:workDate forKey:@"info[worktime]"];
    }

    if (image)
    {
        NSData *data = UIImageJPEGRepresentation(image, 1.0f);
        [req setData:data forKey:@"img"];
    }

	[req setHTTPMethod:@"POST"];
	
	RRLoader *loader = [[RRLoader alloc] initWithRequest:req];
	[loader addNotificationListener:RRLOADER_FAIL target:self action:@selector(onFetchFail:)];
	[loader addNotificationListener:RRLOADER_COMPLETE target:self action:@selector(onSubmit:)];
	[loader loadwithTimer];
	[RWShowView show:@"loading"];
    
}

- (void)onSubmit:(NSNotification *)notify
{
    is_loading = NO;
    [RWShowView closeAlert];
	RRLoader *loader = (RRLoader *)[notify object];
	NSDictionary *json = [loader getJSONData];
	[loader removeNotificationListener:RRLOADER_FAIL target:self];
	[loader removeNotificationListener:RRLOADER_COMPLETE target:self];
	
	if (![[json objectForKey:@"success"] boolValue])
	{
        [RRAlertView show:[[json objectForKey:@"data"] objectAtIndex:0]];
        [RWShowView closeAlert];
		return;
    }

    [RRAlertView show:@"提交成功!"];
    return;
}

- (void) onFetchFail:(NSNotification *)notify
{
	is_loading = NO;
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (IBAction)btn_cancel_click:(id)sender
{
    [self performSelector:@selector(actionSheet:clickedButtonAtIndex:) withObject:0];
}


- (void)btn_certain_tmp_click:(id)sender
{
    switch ([sender tag])
    {
        case 0:
        {
            UIPickerView *picker_View = (UIPickerView *)[actionSheet viewWithTag:srcType];
            switch (srcType)
            {
                case 12:
                    province = [[province_buffer objectAtIndex:[picker_View selectedRowInComponent:0]] objectForKey:@"name"];
                    provinceid = [[province_buffer objectAtIndex:[picker_View selectedRowInComponent:0]] objectForKey:@"cityid"];
                    break;
                case 13:
                    city = [[city_buffer objectAtIndex:[picker_View selectedRowInComponent:0]] objectForKey:@"name"];
                    cityid = [[city_buffer objectAtIndex:[picker_View selectedRowInComponent:0]] objectForKey:@"cityid"];
                    break;
                case 20:
                    workname = [[worker_buffer objectAtIndex:[picker_View selectedRowInComponent:0]] objectForKey:@"name"];
                    workerid = [[worker_buffer objectAtIndex:[picker_View selectedRowInComponent:0]] objectForKey:@"id"];
                    break;
                case 40:
                    saletype = [saleType_buffer objectAtIndex:[picker_View selectedRowInComponent:0]];
                    break;
                case 60:
                    brand = [brand_buffer objectAtIndex:[picker_View selectedRowInComponent:0]];
                    break;
                case 61:
                    station = [station_buffer objectAtIndex:[picker_View selectedRowInComponent:0]];
                    break;
                case 80:
                    appearancetype = [appearancetype_buffer objectAtIndex:[picker_View selectedRowInComponent:0]];
                    break;
                case 81:
                    reasontype = [reasontype_buffer objectAtIndex:[picker_View selectedRowInComponent:0]];
                    break;
                case 82:
                    servicetype = [servicetype_buffer objectAtIndex:[picker_View selectedRowInComponent:0]];
                    break;
                default:
                    break;
            }
        }
            break;
        case 1:
        {
            UIDatePicker *datePicker = (UIDatePicker *)[actionSheet viewWithTag:srcType];
            switch (srcType)
            {
                case 22:
                    saleDate = [self getTimeStringWithDate:datePicker.date];
                    saletime  = [self getTimeFormatWithString:saleDate];
                    break;
                case 42:
                    workDate = [self getTimeStringWithDate:datePicker.date];
                    worktime  = [self getTimeFormatWithString:workDate];
                    break;
                default:
                    break;
            }
        }
        default:
            break;
    }
    [self.tableView reloadData];
    [self performSelector:@selector(actionSheet:clickedButtonAtIndex:) withObject:0];

}

- (NSString *)getTimeStringWithDate:(NSDate *)date
{
    NSDateFormatter *formater = [[ NSDateFormatter alloc] init];
    [formater setDateFormat:@"yyyy-MM-dd"];
    NSString * curTime = [formater stringFromDate:date];
    NSDate *theDate=[formater dateFromString:curTime];
    NSTimeZone* timeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
    [formater setTimeZone:timeZone];
    NSTimeInterval b =[theDate timeIntervalSince1970];
    NSString *timeString = [NSString stringWithFormat:@"%0.0f",b];
    return timeString;
}

- (NSString *)getTimeFormatWithString:(NSString *)str
{
    NSDateFormatter *date_formatter = [[NSDateFormatter alloc] init];
	[date_formatter setDateFormat:@"yyyy-MM-dd"];
	NSString *post_date = [date_formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:[str doubleValue]]];
    return post_date;
}

// action类型 
- (void) actionWithType:(NSUInteger)type
{
    if (state == ListSourceTypeDetail)
    {
        return;
    }

    NSString *title = nil;
    btn_certain_tmp.tag = type;
    if (type == 0)
    {
        title =  @"\n\n\n\n\n\n\n\n\n\n\n\n\n\n";
        actionSheet = [[UIActionSheet alloc] initWithTitle:title delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil, nil];
        actionSheet.tag = 103;
        switch (srcType)
        {
            case 12:
                btn_title.title = @"选择省份";
                break;
            case 13:
                btn_title.title = @"选择城市";
                break;
            case 20:
                btn_title.title = @"选择维修人员";
                break;
            case 40:
                btn_title.title = @"选择销售类型";
                break;
            case 60:
                btn_title.title = @"选择品牌";
                break;
            case 61:
                btn_title.title = @"选择平台";
                break;
            case 80:
                btn_title.title = @"选择不良现象类型";
                break;
            case 81:
                btn_title.title = @"原因类型";
                break;
            case 82:
                btn_title.title = @"服务类型";
                break;
            default:
                break;
        }
        
        actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
        [actionSheet showInView:self.tableView];
        UIPickerView *picker_View = [[UIPickerView alloc] init];
        picker_View.frame = CGRectMake(0,50.0f, 320.0f, 216.0f);
        picker_View.tag = srcType;
        picker_View.delegate = self;
        picker_View.dataSource = self;
        picker_View.showsSelectionIndicator = YES;
        [actionSheet addSubview:picker_View];
        [actionSheet addSubview:tool_bar_tmp];
    }
    else if (type == 1)
    {
        title = UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation) ? @"\n\n\n\n\n\n\n\n\n" : @"\n\n\n\n\n\n\n\n\n\n\n\n\n" ;
        actionSheet = [[UIActionSheet alloc] initWithTitle:title delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil, nil];
        actionSheet.tag = 103;
        switch (srcType)
        {
            case 22:
                btn_title.title = @"选择购买日期";
                break;
            case 42:
                btn_title.title = @"选择维修日期";
                break;
            default:
                break;
        }
        [actionSheet showInView:self.view.window];
        UIDatePicker *datePicker =[[UIDatePicker alloc] initWithFrame:CGRectMake(0.0f,44.0f,320.0f, 200.0f)];
        datePicker.locale = [[NSLocale alloc] initWithLocaleIdentifier:NSLocalizedString(@"LocaleIdentifier", @"")];
        datePicker.tag = srcType;
        datePicker.datePickerMode = 1;
        [actionSheet addSubview:datePicker];
        [actionSheet addSubview:tool_bar_tmp];
    }
    
    else if (type == 2)
    {
        actionSheet = [[UIActionSheet alloc] initWithTitle:@"选择图片" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"本地相册",@"相机拍照", nil];
        actionSheet.tag = 103;
        [actionSheet showInView:self.view.window];
    }

}

#pragma mark -
#pragma mark UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)ActionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [actionSheet dismissWithClickedButtonIndex:buttonIndex animated:YES];
    if (ActionSheet.tag == 103)
    {
        if (buttonIndex == 0)
        {
            [self showAction:buttonIndex];
        }
        else if (buttonIndex == 1)
        {
            [self showAction:buttonIndex];
        }
    }
}


#pragma mark -
#pragma mark UIPickerViewDelegate
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
	return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    switch (srcType)
    {
        case 12:
            return [province_buffer count];
            break;
            
//   按照城市的字母排序 province_buffer_byLetterOrder
//        case 12:
//            return [province_buffer_byLetterOrder count];
//            break;
            
        case 13:
            return [city_buffer count];
            break;
        case 20:
            return [worker_buffer count];
            break;
        case 40:
            return [saleType_buffer count];
            break;
        case 60:
            return [brand_buffer count];
            break;
        case 61:
            return [station_buffer count];
            break;
        case 80:
            return [appearancetype_buffer count];
            break;
        case 81:
            return [reasontype_buffer count];
            break;
        case 82:
            return [servicetype_buffer count];
            break;
        default:
            break;
    }
	return 0;
}

#pragma mark -
#pragma mark UIPickerViewDataSource

-(void) provinceSort
{
    
}
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    switch (srcType)
    {
        case 12:
            return [[province_buffer objectAtIndex:row] objectForKey:@"name"];
            break;

            //省份按照字母顺序排列
//        case 12:
//            return [province_buffer_byLetterOrder objectAtIndex:row];
//            break;
            
        case 13:
            return [[city_buffer objectAtIndex:row] objectForKey:@"name"];
            break;
        case 20:
            return [[worker_buffer objectAtIndex:row] objectForKey:@"name"];
            break;
        case 40:
            return [saleType_buffer objectAtIndex:row];
            break;
        case 60:
            return [brand_buffer objectAtIndex:row];
            break;
        case 61:
            return [station_buffer objectAtIndex:row];
            break;
        case 80:
            return [appearancetype_buffer objectAtIndex:row];
            break;
        case 81:
            return [reasontype_buffer objectAtIndex:row];
            break;
        case 82:
            return [servicetype_buffer objectAtIndex:row];
            break;
        default:
            break;
    }
	return @"";
}

#pragma mark -
#pragma mark UIImagePickerControllerDelegate

- (void)showAction:(NSUInteger)type
{
    UIImagePickerController *ctrl_img_picker = [[UIImagePickerController alloc] init];
    ctrl_img_picker.delegate = self;
    if (0 == type)
    {
        ctrl_img_picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        ctrl_img_picker.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    }
    else
    {
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] == NO)
        {
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:nil
                                                         message:@"无法使用相机。可能此机器没有配备照相设备。"
                                                        delegate:self
                                               cancelButtonTitle:@"确定"
                                               otherButtonTitles:nil];
            [av show];
            return;
        }
        ctrl_img_picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        ctrl_img_picker.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
    }
    
    [self presentModalViewController:ctrl_img_picker animated:YES];
    
}


- (void) imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    if ([[[UIDevice currentDevice]systemVersion]floatValue]>= 5.0)
    {
        [picker dismissModalViewControllerAnimated:YES];
    }
    else
    {
        [picker.parentViewController dismissModalViewControllerAnimated:YES];
    }
}

- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
	UIImage *img = (UIImage *)[info objectForKey:UIImagePickerControllerOriginalImage];
	if (UIImagePickerControllerSourceTypeCamera == picker.sourceType)
	{
		UIImageWriteToSavedPhotosAlbum(img, nil, nil , nil);
	}
	
	CGRect rect = CGRectMake(0, 0, img.size.width, img.size.height);
	CGFloat scale = 1.0f;
    if (rect.size.width > 640.0f || rect.size.height > 960.0f)
	{
		if (rect.size.width > rect.size.height)
		{
			scale = 640.0f / rect.size.width;
		}
		else
		{
			scale = 960.0f / rect.size.height;
		}
	}
    
	UIGraphicsBeginImageContext(rect.size);
	UIGraphicsBeginImageContextWithOptions(rect.size, YES, scale);
	[img drawInRect:rect];
	UIImage *new_img = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
    NSData *data = UIImageJPEGRepresentation(new_img, 1.0f);
	image = [[UIImage alloc] initWithData:data];
	
    [self.tableView reloadData];
    if ([[[UIDevice currentDevice]systemVersion]floatValue]>= 5.0)
    {
        [self dismissModalViewControllerAnimated:YES];
    }
    else
    {
        [self.parentViewController dismissModalViewControllerAnimated:YES];
    }
}

#pragma mark -
#pragma mark RWRemoteImageDelegate

- (void) remoteImageDidBorken:(RRRemoteImage *)remoteImage
{
	static UIImage *empty_image = nil;
	
	if (nil == empty_image)
	{
		empty_image = [UIImage imageNamed:@"home_beauty_default.png"];
	}
	
	[imageview setImage:empty_image];
}

- (void) remoteImageDidLoaded:(RRRemoteImage *)remoteImage newImage:(UIImage *)newImage
{
    image = newImage;
	[imageview setImage:newImage];
    [RWImageBuffer writeToFile:newImage withName:remoteImage.url];
	
}

//处理tableview的cell控件中的“处理”按钮的触发动作
//“已处理”，“已分配”两个tableview的cell中有 “处理”按钮
- (void) handleOrderWithTag:(NSUInteger)tag
{
    NSString *full_url;
    switch (tag)
    {
        case 0:
            
        {
            HandleList *handlist = [[HandleList alloc] initWithStyle:UITableViewStyleGrouped];
            handlist.orderId = self.orderId;
            [self.navigationController pushViewController:handlist animated:YES];
            return;
        }
            break;
        case 1:
        case 2:
            full_url = [NSString stringWithFormat:@"%@%@", BASE_URL,HANDLE_URL];
            break;
        default:
            break;
    }
    // 申请链接
    RRURLRequest *req = [[RRURLRequest alloc] initWithURLString:full_url];
    RRToken *token = [RRToken getInstance];
    [req setParam:[token getProperty:@"token"] forKey:@"token"];
    [req setParam:self.orderId forKey:@"id"];
    if ([page integerValue] == 1 || [page integerValue] == 2)
    {
        [req setParam:@"2" forKey:@"order[status]"];
    }
    [req setHTTPMethod:@"POST"];
    
    RRLoader *loader = [[RRLoader alloc] initWithRequest:req];
    [loader addNotificationListener:RRLOADER_FAIL target:self action:@selector(onFetchFail:)];
    [loader addNotificationListener:RRLOADER_COMPLETE target:self action:@selector(onHandleOrder:)];
    [loader loadwithTimer];
    [RWShowView show:@"loading"];
}

// 在“已分配”tableview的cell中点击“处理”按钮的触发动作

- (void) onHandleOrder:(NSNotification *)notify
{
    is_loading = NO;
    [RWShowView closeAlert];
	RRLoader *loader = (RRLoader *)[notify object];
	NSDictionary *json = [loader getJSONData];
	[loader removeNotificationListener:RRLOADER_FAIL target:self];
	[loader removeNotificationListener:RRLOADER_COMPLETE target:self];
    
	if (![[json objectForKey:@"success"] boolValue])
	{
        [RRAlertView show:[[json objectForKey:@"data"] objectAtIndex:0]];
		return;
	}
    
	[self loadData];                                                    //重新加载页面
    [RRAlertView show:@"该工单已转移至待处理!"];
    [self performSelector:@selector(popToViewController) withObject:nil afterDelay:1.0f];
}

- (void) popToViewController
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}


@end

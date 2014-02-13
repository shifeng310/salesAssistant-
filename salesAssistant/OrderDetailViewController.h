//
//  OrderDetailViewController.h
//  salesAssistant
//
//  Created by 方鸿灏 on 13-7-23.
//  Copyright (c) 2013年 feng. All rights reserved.
//

#import <UIKit/UIKit.h>
// 枚举列举三种编辑工单的状态 
typedef enum{
	ListSourceTypeAdd = 0,
	ListSourceTypeEdit,
	ListSourceTypeDetail,
} ListSourceType;

@interface OrderDetailViewController : UITableViewController <UITextViewDelegate,UIActionSheetDelegate,UIPickerViewDataSource,UIPickerViewDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate>
{
    ListSourceType                  state;
    
    NSString                        *orderId;
    UIToolbar                       *tool_bar_tmp;
    UIBarButtonItem                 *btn_certain_tmp;
    UIBarButtonItem                 *btn_cancel;
    UIBarButtonItem                 *btn_title;
    UIActionSheet                   *actionSheet;
    NSUInteger                      srcType;
    NSIndexPath                     *index_path;

    UIImage                 *image;

    UIButton                *btn_fold_left;
    UIButton                *btn_submit;
    UITextView              *active_txt;
    BOOL                    is_loading;
    NSString                *page;
    NSMutableArray          *province_buffer;
    NSMutableArray          *city_buffer;
    NSMutableArray          *worker_buffer;
    NSMutableDictionary     *order_dic;
    NSMutableDictionary     *info_dic;
    NSMutableArray          *history_buffer;

    NSArray                 *saleType_buffer;
    NSArray                 *brand_buffer;
    NSArray                 *station_buffer;
    NSArray                 *appearancetype_buffer;
    NSArray                 *reasontype_buffer;
    NSArray                 *servicetype_buffer;
    NSArray                 *province_buffer_byLetterOrder;
    NSArray                 *provinceSort_buffer;

    NSString                *customername;
    NSString                *customertel;
    NSString                *province;
    NSString                *provinceid;
    NSString                *city;
    NSString                *cityid;
    NSString                *workname;
    NSString                *workerid;
    NSString                *equiptype;
    NSString                *saletime;
    NSString                *saleDate;
    NSString                *appearance;
    NSString                *saletype;
    NSString                *saletel;
    NSString                *worktime;
    NSString                *workDate;
    NSString                *equipid;
    NSString                *shopname;
    NSString                *shoptel;
    NSString                *customercarno;
    NSString                *brand;
    NSString                *station;
    NSString                *parts;
    NSString                *chargetag;
    NSString                *charge;
    NSString                *appearancetype;
    NSString                *reasontype;
    NSString                *servicetype;
    NSString                *reason;
    NSString                *solutions;
    NSString                *remark;
    NSString                *imgurl;
    NSMutableString         *huifang;
    UIImageView             *imageview;

}

@property(nonatomic,assign) ListSourceType state;

@property(nonatomic,copy) NSString *orderId;

@property(nonatomic,copy) NSString *page;

@end

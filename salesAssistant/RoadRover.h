//
//  RRDebuger.h
//  lib_net
//
//  Created by lyq on 11-6-8.
//  Copyright 2011 RoadRover Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifdef DEBUG
#define LOGEX(level, format, ...) (level?NSLog(@"-- level:%d locate(%s:%d - %@) --\n%@", level, __FILE__, __LINE__, NSStringFromSelector(_cmd), [NSString stringWithFormat:format, __VA_ARGS__]):NSLog(format, __VA_ARGS__))
#else
#define LOGEX(level, format, ...)
#endif

/*----------------------- 后台数据接口定义 -----------------------*/


#define BASE_URL @"http://192.168.13.40:90"

//#define BASE_URL @"http://sh.mycar4s.com"

//#define BASE_URL @"http://192.168.13.55"

//#define  BASE_URL @"http://sh.driverover.com"


//登录地址
#define LOGIN_URL @"/api/base/login"

//登出地址
#define LOGOUT_URL @"/api/base/logout"

//修改个人信息
#define SETTING_URL @"/api/base/setting"

//获取工单信息
#define LIST_URL @"/api/order/list"

//工单信息详情
#define VIEWINFO_URL @"/api/order/viewinfo"
        
//工单历史详情
#define VIEWHISTORY_URL @"/api/order/viewhistory"

//处理工单
#define HANDLE_URL @"/api/order/handle"

//修改工单信息
#define UPDATA_URL @"/api/order/update"

//新增工单信息
#define CREATE_URL @"/api/order/create"

//轮流获取是否有新工单
#define NOTICE_URL @"/api/order/notice"

//根据城市id获取用户列表
#define GETUSER_URL @"/api/base/getuser"

//获取版本信息
#define GET_URL @"/api/version/get"

//发布新版本
#define RELEASE_URL @"/api/version/release"

//获取省份列表
#define PROVINCE_URL @"/api/base/province"

//获取城市列表
#define CITY_URL @"/api/base/city"

// 获取消息列表
#define MESSAGE_LIST @"/api/message/list"




/*----------------------- 常用常量定义 -----------------------*/

//当前版本
#define CURRENT_VERSION_CHAR	@"1.1.0"

//发送源类型：2表示iphone终端
#define SRC_TYPE_CHAR			@"2"
#define SRC_TYPE_INT			2

//韶关cityid
#define APPID           @"4"
#define CITYID          2505
#define LAT             29.250933
#define LNG             117.874472
#define CITY_CODE       @"95bcb757c8224ec96cc1e0acbbba1fa2"
//#define CITY_CODE     @"6a5c47b06b24c89fc249ca005ccc1060" //10.7

//
//  RRToken.m
//  lib_net
//
//  Created by lyq on 11-6-10.
//  Copyright 2011 RoadRover Inc. All rights reserved.
//

#import "RoadRover.h"
#import "RRToken.h"

// 将rrtoken 设置为单例模式

static RRToken *instance = nil;


@implementation RRToken

@synthesize uid;


#pragma mark -
#pragma mark class method

+ (RRToken *) getInstance
{
    [self check];
	return instance;
}

// 判断本地是否已经保存登陆信息，若保存返回yes，否则返回no;
+ (BOOL) check
{
    // 获取最后登陆的token信息
	NSString *last_login_uid = [[NSUserDefaults standardUserDefaults] objectForKey:@"last_login_uid"];
	
	if (!last_login_uid)
	{
		return NO;
	}
	
    // 将已有的token置空
	if (instance)
	{
		instance = nil;
	}
	
    // 获取token对象,其中
	RRToken *token = [[RRToken alloc] initWithUID:last_login_uid];
	
	if ([token loadFromFile])
	{
		return YES;
	}
	else
	{
		return NO;
	}
}

// 判断城市列表是否为最新
+(BOOL) checkProvinceVersion
{
    NSString * province_version = [[NSUserDefaults standardUserDefaults] objectForKey:@"provinceVersion"];
    
    if (!province_version) {
        return NO;
    }
    return YES;
}
+ (void) removeTokenForUID:(NSString *)UID
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSMutableDictionary *exist_tokens = [NSMutableDictionary dictionaryWithDictionary:[defaults objectForKey:@"tokens"]];
	
	if (nil == UID)
	{
		UID = @"";
	}
	
	[exist_tokens removeObjectForKey:UID];
    
	[defaults setObject:exist_tokens forKey:@"tokens"];

    NSFileManager *file_manager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *document_directory = [paths objectAtIndex:0];
	NSString *token_file_name = [NSString stringWithFormat:@"token_%@.plist", UID];
	NSString *token_file = [document_directory stringByAppendingPathComponent:token_file_name];
    [file_manager removeItemAtPath:token_file error:NULL];
}

#pragma mark -

- (id) initWithUID:(NSString *)UID
{
	if (nil == UID || [UID isEqualToString:@""])
	{
		return nil;
	}
	
	self = [super init];
	
	if (self)
	{
		instance = self;
		
		self.uid = UID;
		
		if (properties)
		{
			properties = nil;
            
		}
        // 初始化一个dictionary数据类型
		properties = [[NSMutableDictionary alloc] init];
		
		// 每次都将“last_login_uid” 赋给刚初始化的defaults，
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		[defaults setObject:UID forKey:@"last_login_uid"];
		
	}
	
	return self;
}


- (void) dealloc
{
	properties = nil;
	instance = nil;
}

#pragma mark -

#pragma mark Store/Restore
- (BOOL) loadFromFile
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *document_directory = [paths objectAtIndex:0];
	NSString *token_file_name = [NSString stringWithFormat:@"token_%@.plist", uid];
	NSString *token_file = [document_directory stringByAppendingPathComponent:token_file_name];
	NSDictionary *dic = [NSDictionary dictionaryWithContentsOfFile:token_file];
	
	if (nil != dic)
	{
		[properties addEntriesFromDictionary:dic];
		return YES;
	}
	else
	{
		return NO;
	}
}

- (void) saveToFile
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *document_directory = [paths objectAtIndex:0];
	NSString *token_file_name = [NSString stringWithFormat:@"token_%@.plist", uid];
	NSString *token_file = [document_directory stringByAppendingPathComponent:token_file_name];
	[properties writeToFile:token_file atomically:YES];
}


#pragma mark Property
- (id) getProperty:(NSString *)key
{
	return [properties objectForKey:key];
}

//-(NSString *) getKey:(id)property
//{
//    return [property ];
//}

- (void) setProperty:(id)value forKey:(NSString *)key
{
	[properties setObject:value forKey:key];
    
}

- (void) unsetProperty: (NSString *)key
{
	[properties removeObjectForKey:key];
}

- (void) cleanProperty
{
	[properties removeAllObjects];
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"%@", properties];
}


@end

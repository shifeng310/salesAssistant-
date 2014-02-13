//
//  RWHomeCache.m
//  RW
//
//  Created by 方鸿灏 on 12-5-9.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "RWHomeCache.h"

@implementation RWHomeCache

+ (NSString *) hashName: (NSString *)typeName;
{
	return [NSString stringWithFormat:@"%d", [typeName hash]];
}

+ (NSMutableArray *) readFromFile: (NSString *)typeName
{
	NSError *error;
	NSFileManager *file_manager = [NSFileManager defaultManager];
	NSString *fileName = @"homeCache";
	NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
	path = [path stringByAppendingPathComponent:fileName];
	if ([file_manager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error])
	{
		NSString *filename = [RWHomeCache hashName:typeName];
		NSString *data_file = [path stringByAppendingPathComponent:filename];
		NSMutableArray *arr = [[NSMutableArray alloc] initWithContentsOfFile:data_file];
		return arr;
	}
	return nil;
}

+ (NSInteger ) writeToFile: (NSMutableArray *)arr withName:(NSString *)typeName
{
    NSError *error;
    NSFileManager *file_manager = [NSFileManager defaultManager];
	NSString *fileName = @"homeCache";
	NSString *filename = [RWHomeCache hashName:typeName];
	NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
	path = [path stringByAppendingPathComponent:fileName];
    if (![file_manager fileExistsAtPath:path])
	{
        [file_manager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error];
	}
    
	NSString *data_file = [path stringByAppendingPathComponent:filename];
	[arr writeToFile:data_file atomically:YES];
	return 0;
}

+(void) deleteFile:(NSString *)typeName
{
    NSFileManager * file_manager = [NSFileManager defaultManager];
    NSString * fileName = @"homeCache";
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString * paths = [[path objectAtIndex:0] stringByAppendingPathComponent:fileName];
    NSString * filename = [RWHomeCache hashName:typeName];
    
    NSLog(@"filename : %@",filename);
    BOOL isHave = [file_manager fileExistsAtPath:paths];
    if (!isHave) {
        NSLog(@"no have");
    }
    else
    {
        NSLog(@"have");
        BOOL isDele = [file_manager removeItemAtPath:paths error:nil];
        if (isDele) {
            
            NSLog(@"dele success");
        }
        else
        {
            NSLog(@"dele fail");
        }
    }
}

@end

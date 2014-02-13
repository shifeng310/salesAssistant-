//
//  RWImageBuffer.m
//  RW
//
//  Created by 方鸿灏 on 12-2-27.
//  Copyright 2012 roadrover. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "RWImageBuffer.h"


@implementation RWImageBuffer

+ (NSString *) hashName: (NSString *)imgName
{
	return [NSString stringWithFormat:@"%d", [imgName hash]];
}

+ (UIImage *) readFromFile: (NSString *)imgName
{
	NSString *fileName = @"ImageCache";
	NSString *filename = [RWImageBuffer hashName:imgName];
	NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
	path = [path stringByAppendingPathComponent:fileName];
	NSString *data_file = [path stringByAppendingPathComponent:filename];
	UIImage *image = [[UIImage alloc] initWithContentsOfFile:data_file];
	return image;
}

+ (NSString *) getImgFile: (NSString *)imgName
{
	NSString *fileName = @"ImageCache";
	NSString *filename = [RWImageBuffer hashName:imgName];
	NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
	path = [path stringByAppendingPathComponent:fileName];
	NSString *data_file = [path stringByAppendingPathComponent:filename];
	UIImage *image = [[UIImage alloc] initWithContentsOfFile:data_file];
    if (image) return data_file;
	return nil;
}

+ (UIImage *) readImage: (NSString *)imgName
{
	NSString *fileName = @"ImageCache";
	NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
	path = [path stringByAppendingPathComponent:fileName];
	NSString *document_directory = path;
	NSString *data_file = [document_directory stringByAppendingPathComponent:imgName];
	UIImage *image = [[UIImage alloc] initWithContentsOfFile:data_file];
	return image;

}

+ (NSInteger) writeToFile: (UIImage *)image withName:(NSString *)imgName
{
	NSError *error;
	NSFileManager *file_manager = [NSFileManager defaultManager];
	NSString *fileName = @"ImageCache";
	NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
	path = [path stringByAppendingPathComponent:fileName];
	if ([file_manager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error])
	{
		NSString *filename = [RWImageBuffer hashName:imgName];
		NSString *document_directory = path;
		NSString *data_file = [document_directory stringByAppendingPathComponent:filename];
		CGRect rect = CGRectMake(0, 0, image.size.width, image.size.height);
		UIGraphicsBeginImageContext(rect.size);
		[image drawInRect:rect];
		UIImage *new_img = UIGraphicsGetImageFromCurrentImageContext();
		UIGraphicsEndImageContext();
		
		NSData *data = UIImageJPEGRepresentation(new_img, 0.5f);
		[data writeToFile:data_file atomically:YES];
	}
	
	return 0;
}

+ (void) saveToFile: (UIImage *)image WithName:(NSString *)name
{
	NSError *error;
	NSFileManager *file_manager = [NSFileManager defaultManager];
	NSString *fileName = @"uncleanpic";
	NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
	path = [path stringByAppendingPathComponent:fileName];
	if ([file_manager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error])
	{
		NSString *filename = [RWImageBuffer hashName:name];
		NSString *document_directory = path;
		NSString *data_file = [document_directory stringByAppendingPathComponent:filename];
		CGRect rect = CGRectMake(0, 0, image.size.width, image.size.height);
		UIGraphicsBeginImageContext(rect.size);
		[image drawInRect:rect];
		UIImage *new_img = UIGraphicsGetImageFromCurrentImageContext();
		UIGraphicsEndImageContext();
		NSData *data = UIImageJPEGRepresentation(new_img, 0.5f);
		[data writeToFile:data_file atomically:YES];
	}
}

+ (UIImage *) readStaticImage: (NSString *)imgName
{
	NSString *fileName = @"uncleanpic";
	NSString *filename = [RWImageBuffer hashName:imgName];
	NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
	path = [path stringByAppendingPathComponent:fileName];
	NSString *data_file = [path stringByAppendingPathComponent:filename];
	UIImage *image = [[UIImage alloc] initWithContentsOfFile:data_file];
	return image;
	
}


+ (NSInteger) writeToFile: (UIImage *)image withName:(NSString *)imgName forSize:(CGSize)aSize
{
	NSString *filename = [RWImageBuffer hashName:imgName];
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask,YES);
	NSString *document_directory = [paths objectAtIndex:0];
	NSString *data_file = [document_directory stringByAppendingPathComponent:filename];
	
	CGSize new_size = CGSizeMake(0, 0);
	
	if (image.size.width > image.size.height)
	{
		if (image.size.width > aSize.width)
		{
			new_size.width = aSize.width;
			new_size.height = aSize.width / image.size.width * image.size.height;
		}
	}
	else
	{
		if (image.size.height > aSize.height)
		{
			new_size.width = aSize.height / image.size.height * image.size.width;
			new_size.height = aSize.height;
		}
	}
	
	CGRect rect = CGRectMake(0, 0, new_size.width, new_size.height);
	UIGraphicsBeginImageContext(rect.size);
	[image drawInRect:rect];
	UIImage *new_img = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	NSData *data = UIImageJPEGRepresentation(new_img, 0.5f);
	[data writeToFile:data_file atomically:YES];
	
	return 0;
}


@end

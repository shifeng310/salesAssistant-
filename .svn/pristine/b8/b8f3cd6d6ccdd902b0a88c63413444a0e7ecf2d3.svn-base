//
//  NavSelectedDelegate.h
//  SideBarNavDemo
//
//  Created by JianYe on 12-12-11.
//  Copyright (c) 2012年 JianYe. All rights reserved.
//

#import <Foundation/Foundation.h>

// 设定一个枚举类型，为三个不同的view设置对应的参数；
typedef enum _SideBarShowDirection
{
    SideBarShowDirectionNone = 0,
    SideBarShowDirectionLeft = 1,
    SideBarShowDirectionRight = 2
}SideBarShowDirection;

@protocol SideBarSelectDelegate <NSObject>

- (void)leftSideBarSelectWithController:(UIViewController *)controller;
- (void)rightSideBarSelectWithController:(UIViewController *)controller;
- (void)showSideBarControllerWithDirection:(SideBarShowDirection)direction;

@end
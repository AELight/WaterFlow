//
//  ZYShopCell.h
//  UIScrollView瀑布流
//
//  Created by zhuyi on 15/10/8.
//  Copyright (c) 2015年 zhuyiIT. All rights reserved.
//

#import "ZYWaterflowViewCell.h"
@class ZYShop, ZYWaterflowView;


@interface ZYShopCell : ZYWaterflowViewCell

/** 模型*/
@property(nonatomic, strong) ZYShop *shop;

+ (instancetype)cellWithWaterflowView:(ZYWaterflowView *)waterflowView;

@end

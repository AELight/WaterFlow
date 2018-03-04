//
//  ZYShopCell.m
//  UIScrollView瀑布流
//
//  Created by zhuyi on 15/10/8.
//  Copyright (c) 2015年 zhuyiIT. All rights reserved.
//

#import "ZYShopCell.h"
#import "ZYShop.h"
#import "ZYWaterflowView.h"
#import "UIImageView+WebCache.h"

@interface ZYShopCell ()

@property(nonatomic, weak) UIImageView *imageView;
@property(nonatomic, weak) UILabel *priceLabel;

@end
@implementation ZYShopCell

+ (instancetype)cellWithWaterflowView:(ZYWaterflowView *)waterflowView
{
    static NSString *ID = @"shop";
    ZYShopCell *cell = [waterflowView dequeueReusableCellWithIdentifier:ID];
    if (!cell) {
        cell = [[ZYShopCell alloc]init];
        cell.identifier = ID;
    }
    return cell;
}

//使用代码创建(用storyboard或xib:initWithCoder + awakeFromNib)
-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UIImageView *imageView = [[UIImageView alloc]init];
        [self addSubview:imageView];
        self.imageView = imageView;
        
        UILabel *priceLabel = [[UILabel alloc]init];
        //背景透明(不是label透明)
        //priceLabel.alpha = 0.3//文字也将透明
        priceLabel.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];//黑
        priceLabel.textAlignment = NSTextAlignmentCenter;
        priceLabel.textColor = [UIColor whiteColor];
        [self addSubview:priceLabel];
        self.priceLabel = priceLabel;
    }
    return self;
}

- (void)setShop:(ZYShop *)shop{
    _shop = shop;
    
    // 1.图片
    [self.imageView sd_setImageWithURL:[NSURL URLWithString:shop.img] placeholderImage:[UIImage imageNamed:@"loading"]];
    
    // 2.价格
    self.priceLabel.text = shop.price;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.imageView.frame = self.bounds;
    CGFloat priceX = 0;
    CGFloat priceH = 25;
    CGFloat priceY = self.bounds.size.height - priceH;
    CGFloat priceW = self.bounds.size.width;
    self.priceLabel.frame = CGRectMake(priceX, priceY, priceW, priceH);
}
@end

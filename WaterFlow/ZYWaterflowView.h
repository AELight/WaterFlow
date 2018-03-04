//
//  ZYWaterflowView.h
//  UIScrollView瀑布流
//
//  Created by zhuyi on 15/10/7.
//  Copyright (c) 2015年 zhuyiIT. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ZYWaterflowView, ZYWaterflowViewCell;

typedef enum {
    ZYWaterflowViewMarginTypeTop,
    ZYWaterflowViewMarginTypeRight,
    ZYWaterflowViewMarginTypeBottom,
    ZYWaterflowViewMarginTypeLeft,
    ZYWaterflowViewMarginTypeRow,//行
    ZYWaterflowViewMarginTypeColumn
    
}ZYWaterflowViewMarginType;


//数据源方法
@protocol ZYWaterflowViewDataSource <NSObject>

@required//默认(可不写)

//一共有多少个数据(非负)
- (NSUInteger)numberOfCellsInWaterflowView:(ZYWaterflowView *)waterflowView;

//返回index位置对应的cell
- (ZYWaterflowViewCell *)waterflowView:(ZYWaterflowView *)waterflowView cellAtIndex:(NSUInteger )index;

@optional
//一共有多少列(非负)    //默认三列
- (NSUInteger)numberOfColumnsInWaterflowView:(ZYWaterflowView *)waterflowView;

@end



//代理方法
@protocol ZYWaterflowViewDelegate <UIScrollViewDelegate>

@optional
//index位置cell对应的高度
- (CGFloat )waterflowView:(ZYWaterflowView *)waterflowView heightAtIndex:(NSUInteger )index;

//间距
- (CGFloat )waterflowView:(ZYWaterflowView *)waterflowView marginForType:(ZYWaterflowViewMarginType)type;

//选中index位置的cell
- (void)waterflowView:(ZYWaterflowView *)waterflowView didSelectAtIndex:(NSUInteger)index;

@end



//瀑布流控件
@interface ZYWaterflowView : UIScrollView

//数据源
@property(nonatomic, weak) id<ZYWaterflowViewDataSource> datasource;

//代理
@property(nonatomic, weak) id<ZYWaterflowViewDelegate> delegate;

//刷新数据(只要调用这个方法,会重新向数据源和代理发送请求,请求数据)
- (void)reloadData;

//cell的宽度
- (CGFloat)cellWidth;

//根据重用标识去缓存池查找可以循环利用的cell
- (id)dequeueReusableCellWithIdentifier:(NSString *)identifier;

@end

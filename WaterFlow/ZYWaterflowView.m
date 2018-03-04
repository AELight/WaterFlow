//
//  ZYWaterflowView.m
//  UIScrollView瀑布流
//
//  Created by zhuyi on 15/10/7.
//  Copyright (c) 2015年 zhuyiIT. All rights reserved.
//

#import "ZYWaterflowView.h"
#import "ZYWaterflowViewCell.h"


#define ZYWaterflowViewDefaultCellH 80
#define ZYWaterflowViewDefaultNumberOfColumns 3
#define ZYWaterflowViewDefaultMargin 10


@interface ZYWaterflowView()

//所有cell的frame数据
@property(nonatomic, strong)NSMutableArray *cellFrames;
//正在展示的cell
@property(nonatomic, strong)NSMutableDictionary *displayingCells;

//缓存池(用set,存放离开屏幕的cell)
@property(nonatomic, strong)NSMutableSet *reusableCells;

@end

@implementation ZYWaterflowView

#pragma mark - 懒加载
- (NSMutableArray *)cellFrames
{
    if (!_cellFrames) {
        self.cellFrames = [NSMutableArray array];
    }
    return _cellFrames;
}

- (NSMutableDictionary *)displayingCells
{
    if (!_displayingCells) {
        self.displayingCells = [NSMutableDictionary dictionary];
    }
    return _displayingCells;
}

- (NSMutableSet *)reusableCells
{
    if (!_reusableCells) {
        self.reusableCells = [NSMutableSet set];
    }
    return _reusableCells;
}

#pragma mark - 将要移到父视图
- (void)willMoveToSuperview:(UIView *)newSuperview
{
    [self reloadData];
}

#pragma mark - 公共接口

//cell的宽度
- (CGFloat)cellWidth{
    
    //总列数
    NSUInteger numberOfColumns = [self numberOfColumns];
    CGFloat leftM = [self marginForType:ZYWaterflowViewMarginTypeLeft];
    CGFloat rightM = [self marginForType:ZYWaterflowViewMarginTypeRight];
    CGFloat columnM = [self marginForType:ZYWaterflowViewMarginTypeColumn];
    return (self.bounds.size.width - leftM - rightM - (numberOfColumns - 1) * columnM)/numberOfColumns;
}


/*
 *刷新数据
 *1.计算每一个cell的frame
 */
- (void)reloadData
{
    //清空之前的所有数据
    //移除正在显示的cell
    [self.displayingCells.allValues makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.displayingCells removeAllObjects];
    [self.cellFrames removeAllObjects];
    [self.reusableCells removeAllObjects];
    
    //cell的总数
    NSUInteger numberOfCells = [self.datasource numberOfCellsInWaterflowView:self];
    //总列数
    NSUInteger numberOfColumns = [self numberOfColumns];
    
    //间距
    CGFloat topM = [self marginForType:ZYWaterflowViewMarginTypeTop];
    CGFloat bottomM = [self marginForType:ZYWaterflowViewMarginTypeBottom];
    CGFloat leftM = [self marginForType:ZYWaterflowViewMarginTypeLeft];
    CGFloat columnM = [self marginForType:ZYWaterflowViewMarginTypeColumn];
    CGFloat rowM = [self marginForType:ZYWaterflowViewMarginTypeRow];
    
    //cell的宽度
    CGFloat cellW = [self cellWidth];
    
    //用一个C语言数组存放所有列的最大Y值
    CGFloat maxYOfColumns[numberOfColumns];
    for (int i = 0;i < numberOfColumns; i++) {
        maxYOfColumns[i] = 0.0;
    }
    
    //计算所有cell的frame
    for (int i = 0; i < numberOfCells; i++) {
        //cell处在第几列(最短的一列)
        NSUInteger cellColumn = 0;
        //cell所处那列的最大Y值(最短那一列的最大Y值)
        CGFloat maxYOfCellColumn = maxYOfColumns[cellColumn];
        //  求出最短的一列
        for (int j = 1; j < numberOfColumns; j++) {
            if (maxYOfColumns[j] < maxYOfCellColumn) {
                cellColumn = j;
                maxYOfCellColumn = maxYOfColumns[j];
            }
        }

        //询问代理i位置的高度
        CGFloat cellH = [self heightAtIndex:i];
        
        //cell的位置
        CGFloat cellX = leftM + cellColumn * (cellW + columnM);
        CGFloat cellY = 0;
        if (maxYOfCellColumn == 0.0) {//首行
            cellY = topM;
        }else{
            cellY = maxYOfCellColumn + rowM;
        }
        
        //添加frame到数组中
        CGRect cellFrame = CGRectMake(cellX, cellY, cellW, cellH);
        [self.cellFrames addObject:[NSValue valueWithCGRect:cellFrame]];
        
        //更新最短那一列的最大Y值
        maxYOfColumns[cellColumn] = CGRectGetMaxY(cellFrame);
    
    }
    
    //设置contentSize
    CGFloat contentH = maxYOfColumns[0];//默认第一个
    for (int j = 1; j < numberOfColumns; j++) {
        if (maxYOfColumns[j] > contentH) {
            contentH = maxYOfColumns[j];
        }
    }
    contentH += bottomM;
    self.contentSize = CGSizeMake(0, contentH);
}


//UIScrollView在滚动时也会调用这个方法
- (void)layoutSubviews
{
    [super layoutSubviews];
    
#warning ZYWaterflowView一共产生了多少个子控件
   // NSLog(@"ZYWaterflowView子控件个数:%lu",self.subviews.count);
    
    //向数据源索要对应位置的cell
    NSUInteger numberOfCells = self.cellFrames.count;
    for (int i = 0; i < numberOfCells; i++) {
        
        //取出i位置的frame
        CGRect cellFrame = [self.cellFrames[i] CGRectValue];
        //优先从字典中取出i位置的cell
        ZYWaterflowViewCell *cell = self.displayingCells[@(i)];

        //判断i位置对应的frame在不在屏幕上(能否看见)
        if ([self isInScreen:cellFrame]) {//在屏幕上
            if (cell == nil) {
                cell = [self.datasource waterflowView:self cellAtIndex:i];
                cell.frame = cellFrame;
                [self addSubview:cell];
                
                //存放到字典中
                self.displayingCells[@(i)] = cell;
            }
        }else{//不在屏幕上
            if (cell) {
                //从scrollview和字典中移除
                [cell removeFromSuperview];
                [self.displayingCells removeObjectForKey:@(i)];
                
                //存放进缓存池
                [self.reusableCells addObject:cell];
            }
        }
    }
    
}

- (id)dequeueReusableCellWithIdentifier:(NSString *)identifier
{
    __block ZYWaterflowViewCell *reusableCell = nil;
    [self.reusableCells enumerateObjectsUsingBlock:^(ZYWaterflowViewCell *cell, BOOL *stop) {
        
        if ([cell.identifier isEqualToString:identifier]) {
            reusableCell = cell;
            *stop = YES;
        }
    }];
    
    if (reusableCell) {//从缓存池中移除
        [self.reusableCells removeObject:reusableCell];
    }
    
    return reusableCell;
    
}

#pragma mark - 私有方法

//判断一个frame是否显示在屏幕上
- (BOOL)isInScreen:(CGRect)frame
{
    return (CGRectGetMaxY(frame) > self.contentOffset.y) && (CGRectGetMinY(frame) < self.contentOffset.y + self.bounds.size.height);
}

//间距
- (CGFloat)marginForType:(ZYWaterflowViewMarginType)type
{
    if ([self.delegate respondsToSelector:@selector(waterflowView:marginForType:)]) {
        return [self.delegate waterflowView:self marginForType:type];
    }else{
        return ZYWaterflowViewDefaultMargin;
    }
}

//列数
- (NSUInteger)numberOfColumns
{
    if ([self.datasource respondsToSelector:@selector(numberOfColumnsInWaterflowView:)]) {
        return [self.datasource numberOfColumnsInWaterflowView:self];
    }else{
        return ZYWaterflowViewDefaultNumberOfColumns;
    }
}

//高度
- (CGFloat)heightAtIndex:(NSUInteger)index
{
    if ([self.delegate respondsToSelector:@selector(waterflowView:heightAtIndex:)]) {
        return [self.delegate waterflowView:self heightAtIndex:index];
    }else{
        return ZYWaterflowViewDefaultCellH;
    }
}


#pragma mark - 事件处理
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (![self.delegate respondsToSelector:@selector(waterflowView:didSelectAtIndex:)]) return;
    
    //获得触摸点
    UITouch *touch = [touches anyObject];
//    CGPoint point = [touch locationInView:touch.view];
    CGPoint point = [touch locationInView:self];
    
    __block NSNumber *selectIndex = nil;
    [self.displayingCells enumerateKeysAndObjectsUsingBlock:^(id key, ZYWaterflowViewCell *cell, BOOL *stop) {
        if (CGRectContainsPoint(cell.frame, point)) {
            selectIndex = key;
            *stop = YES;
        }
    }];
    
    if (selectIndex) {
        [self.delegate waterflowView:self didSelectAtIndex:selectIndex.unsignedIntegerValue];
    }
}


@end

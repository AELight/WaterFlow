//
//  ZYShopViewController.m
//  UIScrollView瀑布流
//
//  Created by zhuyi on 15/10/8.
//  Copyright (c) 2015年 zhuyiIT. All rights reserved.
//

#import "ZYShopViewController.h"
#import "ZYShopCell.h"
#import "ZYWaterflowView.h"
#import "ZYShop.h"
#import "MJExtension.h"
#import "MJRefresh.h"

@interface ZYShopViewController ()<ZYWaterflowViewDataSource, ZYWaterflowViewDelegate>

@property(nonatomic, strong) NSMutableArray *shops;
@property(nonatomic, weak) ZYWaterflowView *waterflowView;


@end

@implementation ZYShopViewController

#pragma mark - 懒加载
- (NSMutableArray *)shops
{
    if (!_shops) {
        self.shops = [NSMutableArray array];
    }
    return _shops;
}


- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    //1.初始化数据
    NSArray *newShops = [ZYShop objectArrayWithFilename:@"2.plist"];
    [self.shops addObjectsFromArray:newShops];
    
    //瀑布流控件
    ZYWaterflowView *waterflowView = [[ZYWaterflowView alloc]init];
    
    //根据父控件的尺寸而自动伸缩
    waterflowView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    
    waterflowView.frame = self.view.bounds;
    waterflowView.datasource = self;
    waterflowView.delegate = self;
    [self.view addSubview:waterflowView];
    self.waterflowView = waterflowView;
    
    //2.集成刷新控件
    [self setupRefresh];
}

- (void)setupRefresh
{
    //block方式(注意循环引用)
    /*
    + (instancetype)headerWithRefreshingBlock:(MJRefreshComponentRefreshingBlock)refreshingBlock
    {
        MJRefreshHeader *cmp = [[self alloc] init];
        cmp.refreshingBlock = refreshingBlock;
        return cmp;
    }*/
    self.waterflowView.header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewShops)];
    
//    [self.waterflowView.header beginRefreshing];
    
    self.waterflowView.footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreShops)];
//    self.waterflowView.footer.hidden = YES;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self.waterflowView reloadData];
}

- (void)loadNewShops
{
#warning 模拟加载网络数据
   static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        //加载1.plist
        NSArray *newShops = [ZYShop objectArrayWithFilename:@"1.plist"];
//                [self.shops removeAllObjects];
//                [self.shops addObjectsFromArray:newShops];
        [self.shops insertObjects:newShops atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, newShops.count)]];
    }) ;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        // 刷新瀑布流控件
        [self.waterflowView reloadData];
        //结束刷新
        [self.waterflowView.header endRefreshing];
    });
}

- (void)loadMoreShops
{
#warning 模拟加载网络数据
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        //加载3.plist
        NSArray *moreShops = [ZYShop objectArrayWithFilename:@"3.plist"];
        [self.shops addObjectsFromArray:moreShops];

    }) ;

    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        // 刷新瀑布流控件
        [self.waterflowView reloadData];
        //结束刷新
        [self.waterflowView.footer endRefreshing];
    });
}


#pragma mark - 数据源方法
- (NSUInteger )numberOfCellsInWaterflowView:(ZYWaterflowView *)waterflowView
{
    return self.shops.count;
}

- (ZYWaterflowViewCell *)waterflowView:(ZYWaterflowView *)waterflowView cellAtIndex:(NSUInteger)index
{
    ZYShopCell *cell = [ZYShopCell cellWithWaterflowView:waterflowView];
    cell.shop = self.shops[index];
    
#warning  检测是否循环利用了
    NSLog(@"%lu %p", index, cell);
    
    return cell;
}

- (NSUInteger)numberOfColumnsInWaterflowView:(ZYWaterflowView *)waterflowView
{
//横:UIInterfaceOrientationIsLandscape(self.interfaceOrientation)
    if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) {
        //竖屏
        return 3;
    }else{//横屏
        return 5;
    }
}


#pragma mark - 代理方法
- (CGFloat )waterflowView:(ZYWaterflowView *)waterflowView heightAtIndex:(NSUInteger)index
{
    ZYShop *shop = self.shops[index];
    //根据cell 的宽度和图片的宽高比算出cell的高度
    return waterflowView.cellWidth * shop.h / shop.w;
}

@end

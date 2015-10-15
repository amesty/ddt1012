//
//  NGPopListView.h
//  ddt
//
//  Created by gener on 15/10/14.
//  Copyright (c) 2015年 Light. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NGBaseListView.h"

@class NGPopListView;

@protocol NGPopListDelegate <NSObject>

@required

//----top button
////获取Section的个数，即btn的个数
-(NSInteger)numberOfSectionInPopView:(NGPopListView*)poplistview;

//获取Section的title,即btn的标题
-(NSString *)titleOfSectionInPopView:(NGPopListView*)poplistview atIndex :(NSInteger)index;



-(NSArray*)dataSourceOfPoplistview;



//----tableiview------------------------------
//获取popListView 的row 数据源
-(NSInteger)popListView:(NGPopListView *)popListView numberOfRowsInSection:(NSInteger)section;

//
-(NSString*)titleOfCellInPopView:(NGPopListView*)popListView  atIndex :(NSInteger)index;

//popListView 选中事件
-(void)popListView:(NGPopListView *)popListView  didSelectRowAtIndex:(NSInteger )index;

@optional
//cell的高度
-(CGFloat)popListView:(NGPopListView *)popListView heightForRowAtIndexPath:(NSInteger)index;

@end



@interface NGPopListView : UIView<NGBaseListDelegate>


@property(nonatomic,assign)id<NGPopListDelegate>delegate;

-(instancetype)initWithFrame:(CGRect)frame withDelegate :(id)delegate withSuperView:(UIView*)superView;


@end

//
//  SystemCenterViewController.m
//  ddt
//
//  Created by allenhzhang on 10/23/15.
//  Copyright (c) 2015 Light. All rights reserved.
//

#import "SystemCenterViewController.h"
#import "AboutUsViewController.h"
#import "DeviceFeedBackViewController.h"
#import "JoinUsViewController.h"
#define KimageName @"imageName"
#define KlabelName @"labelName"
@interface SystemCenterViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    NSArray *datalist;
    UITableView *myTableView;
}
@end

@implementation SystemCenterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"系统中心";
    [self createLeftBarItemWithBackTitle];
    [self creatTableView];
    datalist = @[@{KimageName: @"uc_system.png",
                   KlabelName:@"关于我们"},
                 @{KimageName: @"uc_danzi.png",
                   KlabelName:@"版本更新"},
                 @{KimageName: @"uc_fabu.png",
                   KlabelName:@"意见反馈"},
                 @{KimageName: @"uc_fabu.png",
                   KlabelName:@"加入我们"},
                 ];

    // Do any additional setup after loading the view.
}
-(void)creatTableView{
    myTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, CurrentScreenWidth, CurrentScreenHeight-64) style:UITableViewStylePlain];
    myTableView.delegate = self;
    myTableView.dataSource = self;
    myTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:myTableView];
}
#pragma mark --tableview 代理
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return datalist.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellId = @"cellid";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    UIImage *image = [UIImage imageNamed:datalist[indexPath.row][KimageName]];
    image = [UIImage imageWithCGImage:image.CGImage scale:2 orientation:UIImageOrientationUp];
    
    cell.imageView.image = image;
    cell.textLabel.font = [UIFont systemFontOfSize:14];
    cell.textLabel.text = datalist[indexPath.row][KlabelName];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    UIImageView *dimageview = [[UIImageView alloc] init];
    dimageview.frame=CGRectMake(0, 43, CurrentScreenWidth, 1);
    dimageview.backgroundColor=RGBA(215, 215, 215, 1);
    [cell.contentView addSubview:dimageview];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row == 0) {
        AboutUsViewController *us = [[AboutUsViewController alloc]init];
        us.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:us animated:YES];
    }
    if (indexPath.row == 1) {
        
    }
    if (indexPath.row == 2) {
        DeviceFeedBackViewController *feedback = [[MySharetools shared]getViewControllerWithIdentifier:@"DeviceFeedBack" andstoryboardName:@"me"];
        feedback.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:feedback animated:YES];
    }
    if (indexPath.row == 3) {
        JoinUsViewController *joinUS = [[JoinUsViewController alloc]init];
        joinUS.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:joinUS animated:YES];
    }
    
}
-(void)goback:(UIButton *)btn{
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
//
//  NGCompanyListVC.m
//  ddt
//
//  Created by wyg on 15/11/10.
//  Copyright © 2015年 Light. All rights reserved.
//

#import "NGCompanyListVC.h"
#import "NGSearchBar.h"
#import "NGPopListView.h"
#import "AddCommanyInfoViewController.h"
#import "NGCompanyDetailVC.h"

#import "NGSecondListCell.h"
#import "DTCompanyListCell.h"

static NSString * showCompanyVcID   = @"showCompanyVcID";
static NSString * NGCompanyListCellReuseId = @"NGCompanyListCellReuseId";


@interface NGCompanyListVC ()<NGSearchBarDelegate,NGPopListDelegate,UITableViewDataSource,UITableViewDelegate>
{
    //pop view相关
    NGPopListView *popView;
    NSArray * _common_pop_btnTitleArr; //同行-选择按钮的默认标题
    NSArray * _common_pop_btnListArr;//列表数据
    
    //tableview相关
    UITableView     * _tableView;
    NSMutableArray  * _common_list_dataSource;//数据源
    NSString        * _common_list_cellReuseId;//当前复用cellID
    
    CGSize cellMaxFitSize;
    UIFont *cellFitfont;
    NSInteger _pageNum;//请求的页数
    NSInteger _selectRowIndex;
    
    BOOL _isfirstAppear;
    
    //搜搜
    NGSearchBar *_searchBar;
    NSString * _selectedArea;//选择的区域，默认为空
    NSString * _selectedType;//选择的业务类型，默认为空
}
@end

@implementation NGCompanyListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initData];
    [self initSubviews];
}

-(void)awakeFromNib
{
    UIBarButtonItem *_backitem =[ [UIBarButtonItem alloc]init];
    _backitem.title = @"";
    self.navigationItem.backBarButtonItem = _backitem;
    
    UIBarButtonItem *rightitem = [[UIBarButtonItem alloc]initWithTitle:@"添加公司" style:UIBarButtonItemStyleBordered target:self action:@selector(rightItemClick)];
    self.navigationItem.rightBarButtonItem = rightitem;
}
#pragma mark --添加公司
-(void)rightItemClick
{
    AddCommanyInfoViewController *commany = [[MySharetools shared]getViewControllerWithIdentifier:@"AddCommany" andstoryboardName:@"me"];
    commany.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:commany animated:YES];
}


-(void)initData
{
    self.vcType = 1;
    
    //pop
    //btn title
    NSArray *_areaArr = [NGXMLReader getCurrentLocationAreas];//区域
    NSArray *_typeArr = [NGXMLReader getBaseTypeData];//基本业务类型
    NSArray *_btnTitleArr2 = @[@"服务区域",@"业务类型"];
    _common_pop_btnTitleArr = _btnTitleArr2;
    _common_pop_btnListArr  = @[_areaArr,_typeArr];

    //tableview
    cellMaxFitSize = CGSizeMake(CurrentScreenWidth -30, 999);
    cellFitfont = [UIFont systemFontOfSize:15];
    _pageNum = 1;
    _selectRowIndex = 0;
    _isfirstAppear = YES;
    
    //....此处获取tableview的数据源
    //...test   tableview
    _common_list_dataSource = [[NSMutableArray alloc]init];
    _common_list_cellReuseId = NGCompanyListCellReuseId;
    
    _selectedArea = @"";
    _selectedType = @"";
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (_isfirstAppear) {
        _isfirstAppear = NO;
        [_tableView.header beginRefreshing];
    }
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [popView disappear];
}

#pragma mark- init subviews
-(void)initSubviews
{
    self.title = @"公司名片";
    
    popView = [[NGPopListView alloc]initWithFrame:CGRectMake(0, 0, CurrentScreenWidth, 40) withDelegate:self withSuperView:self.view];
    [self.view addSubview:popView];
    _searchBar = [[NGSearchBar alloc]initWithFrame:CGRectMake(2, popView.frame.origin.y + popView.frame.size.height + 1, CurrentScreenWidth -4 , 30)];
    _searchBar.delegate  =self;
    _searchBar.placeholder = @"请输入公司名称、地址或其他关键字";
    [self.view addSubview:_searchBar];
    
    NSInteger _heightValue = _vcType ==2 ? CurrentScreenHeight -64 -40-30 -2 : CurrentScreenHeight -64-44 -40-30 -2;
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, _searchBar.frame.origin.y + _searchBar.frame.size.height, CurrentScreenWidth,_heightValue ) style:UITableViewStylePlain];
    _tableView.delegate =self;
    _tableView.dataSource  =self;
    [self.view  addSubview:_tableView];
    [_tableView setContentInset:UIEdgeInsetsMake(0, 0, 5, 0)];
    _tableView.tableFooterView = [[UIView alloc]init];
    
    [_tableView registerNib:[UINib nibWithNibName:@"DTCompanyListCell" bundle:nil] forCellReuseIdentifier:NGCompanyListCellReuseId];
    
    //添加下拉刷新
    __weak __typeof(self) weakSelf = self;
    _tableView.header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        _pageNum = 1;
        [weakSelf loadMoreData];
    }];
    
    _tableView.footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        [weakSelf loadMoreData];
    }];
}


#pragma mark --加载数据
-(void)loadMoreData
{
    NSString *tel = [[MySharetools shared]getPhoneNumber];
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:tel,@"username", _selectedArea,@"quye",_selectedType,@"yewu",@"10",@"psize",@(_pageNum),@"pnum",_searchBar.text.length > 0?_searchBar.text:@"",@"word",nil];
    
    NSLog(@"...pagenum : %d",_pageNum);
    
    NSDictionary *_d = [MySharetools getParmsForPostWith:dic];
    RequestTaskHandle *task = [RequestTaskHandle taskWithUrl:NSLocalizedString(@"url_company_list", @"") parms:_d andSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        _pageNum ==1?({[_tableView.header endRefreshing];[_common_list_dataSource removeAllObjects];
        }):([_tableView.footer endRefreshing]);
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            if ([[responseObject objectForKey:@"result"]integerValue] ==0) {
                NSArray *dataarr = [responseObject objectForKey:@"data"];
                if (dataarr && dataarr.count < 10) {
                    //...没有数据了，不能在刷新加载了
                    _pageNum = NSNotFound;
                     [_tableView.footer endRefreshingWithNoMoreData];
                    
                    [_common_list_dataSource addObjectsFromArray:dataarr];
                    [_tableView reloadData];
                }
            }
            else
            {
//                [SVProgressHUD showInfoWithStatus:[responseObject objectForKey:@"message"]];
                [_tableView.footer endRefreshingWithNoMoreData];
            }
        }
    } faileBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
        [SVProgressHUD showInfoWithStatus:@"请求服务器失败"];
        _pageNum ==1?({[_tableView.header endRefreshing];}):([_tableView.footer endRefreshing]);
    }];
    
    [HttpRequestManager doPostOperationWithTask:task];
}


#pragma mark - NGPopListDelegate
-(NSInteger)numberOfSectionInPopView:(NGPopListView *)poplistview
{
    return _common_pop_btnTitleArr?_common_pop_btnTitleArr.count:0;
}

-(NSString *)titleOfSectionInPopView:(NGPopListView *)poplistview atIndex:(NSInteger)index
{
    return [_common_pop_btnTitleArr objectAtIndex:index];
}

//第一个列表显示的数据源,NSArray类型
-(NSArray*)dataSourceOfPoplistviewWithIndex:(NSInteger)index
{
    return [_common_pop_btnListArr objectAtIndex:index];
}

-(NSInteger)popListView:(NGPopListView *)popListView numberOfRowsWithIndex:(NSInteger)index
{
    return ((NSArray*)[_common_pop_btnListArr objectAtIndex:index]).count;
}


-(void)popListView:(NGPopListView *)popListView  didSelectRowAtIndex:(NSInteger )index
{
    //...请求网络
    
}


#pragma mark -NGSearchBarDelegate
-(void)searchBarWillBeginSearch:(NGSearchBar *)searchBar
{
    _pageNum  =1;
    NSLog(@"begin");
}

-(void)searchBarDidBeginSearch:(NGSearchBar *)searchBar withStr:(NSString *)str
{
    if (searchBar.text.length > 0) {
          [self loadMoreData];
    }
    else
    {
        [SVProgressHUD showInfoWithStatus:@"输入搜索关键字"];
    }
}


float _h;

#pragma mark --UItableView delegate

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _common_list_dataSource.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DTCompanyListCell * cell;
    NSDictionary *_dic0 = [_common_list_dataSource objectAtIndex:indexPath.row];
    
    cell = [tableView dequeueReusableCellWithIdentifier:_common_list_cellReuseId forIndexPath:indexPath];
    NSString * str = [_dic0 objectForKey:@"4"];
    CGSize _new =  [ToolsClass calculateSizeForText:str :cellMaxFitSize font:cellFitfont];
    
    CGRect rec = cell.name.frame;
    rec.size.height = _new.height;
    cell.name.frame = rec;
    _h = _new.height + 10;
    
    [(DTCompanyListCell *)cell setCellWith:_dic0];
    ((DTCompanyListCell *)cell).btnClickBlock = ^(NSInteger tag){
        NSLog(@"...cell btn click : %ld",tag);
    };

    return cell;
}

const float cellDefaultHeight = 60.0;

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{

//            NSDictionary *_dic0 = [_common_list_dataSource objectAtIndex:indexPath.row];
//            NSString * str = [_dic0 objectForKey:@"4"];
//            CGSize _size = CGSizeMake(CurrentScreenWidth -100, 999);
//            UIFont *font = [UIFont systemFontOfSize:15];
//            CGSize _new =  [ToolsClass calculateSizeForText:str :_size font:font];
//            
    return 20 + _h > cellDefaultHeight?20 + _h:cellDefaultHeight;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    _selectRowIndex = indexPath.row;

    [self performSegueWithIdentifier:showCompanyVcID sender:nil];
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_pageNum != NSNotFound && indexPath.row == _common_list_dataSource.count - 1) {
        _pageNum++;
        [_tableView.footer beginRefreshing];
    }
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if([segue.identifier isEqualToString:showCompanyVcID])
    {
        NGCompanyDetailVC *vc =[segue destinationViewController];
        vc.companyInfoDic = [_common_list_dataSource objectAtIndex:_selectRowIndex];
    }
}


@end

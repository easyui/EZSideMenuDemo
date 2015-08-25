//
//  DemoLeftMenuViewController.m
//  EZSideMenuDemo
//
//  Created by yangjun zhu on 15/8/25.
//  Copyright (c) 2015年 Cactus. All rights reserved.
//

#import "DemoLeftMenuViewController.h"
#import "EZSideMenu.h"

#define  CellHeight 54.f
#define  RootMenu   @{@"0":@[@"Params", @"schedule"], @"1":@[@"Video", @"video"], @"2":@[@"Team", @"team"], @"3":@[@"News", @"news"], @"4":@[@"Shop", @"shop"], @"5":@[@"Setting", @"setting"]}
#define  TeamMenu   @{@"0":@[@"ANA", @"ANA_iphone"], @"1":@[@"BOS", @"BOS_iphone"], @"2":@[@"BUF", @"BUF_iphone"], @"3":@[@"CAR", @"CAR_iphone"], @"4":@[@"CBJ", @"CBJ_iphone"], @"5":@[@"CGY", @"CGY_iphone"], @"6":@[@"CHI", @"CHI_iphone"], @"7":@[@"COL", @"COL_iphone"], @"8":@[@"<   Back", @""]}


@interface DemoLeftMenuViewController ()
@property (weak, nonatomic) IBOutlet UITableView *menuTableView;
@property (strong, nonatomic) NSDictionary *menuDic;
@property (weak, nonatomic) IBOutlet UIImageView *headerImageView;

@end

@implementation DemoLeftMenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.menuDic = RootMenu;

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

#pragma mark -
#pragma mark UITableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (self.menuDic.count > 6) {
        switch (indexPath.row) {
            case 8:
                self.menuDic = RootMenu;
                [self ConfigTableFrame];
                [self.menuTableView reloadData];
                [self.sideMenuViewController flashMenu];
                break;
            default:
                break;
        }
    }else{
        switch (indexPath.row) {
            case 0:
                [self.sideMenuViewController setContentViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"DemoParamsUINavigationControllerStoreboardID"]
                                                             animated:YES];
                [self.sideMenuViewController hideMenuViewController];
                break;
                
            case 1:
                [self.sideMenuViewController setContentViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"DemoVideosUINavigationControllerStoreboardID"]
                                                             animated:YES];
                [self.sideMenuViewController hideMenuViewController];
                break;
                
            case 2:
                self.menuDic = TeamMenu;
                [self ConfigTableFrame];
                [self.menuTableView reloadData];
                [self.sideMenuViewController flashMenu];
                break;
                
            default:
                
                break;
        }
        
    }
}

#pragma mark -
#pragma mark UITableView Datasource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return CellHeight;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
    return self.menuDic.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.backgroundColor = [UIColor clearColor];
        cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:21];
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.textLabel.highlightedTextColor = [UIColor lightGrayColor];
        cell.selectedBackgroundView = [[UIView alloc] init];
    }
    
    NSArray *arr = [self.menuDic objectForKey:[NSString stringWithFormat:@"%ld", (long)indexPath.row]];
    cell.textLabel.text = arr[0];
    cell.imageView.image = [UIImage imageNamed:arr[1]];
    
    return cell;
}

#pragma mark - private

- (void)ConfigTableFrame
{
    /*
    float length = (self.menuDic.count * CellHeight > self.view.frame.size.height) ? self.view.frame.size.height : self.menuDic.count * CellHeight;
    
    self.menuTableView.frame = CGRectMake(self.menuTableView.frame.origin.x, ceilf((self.view.frame.size.height - length) / 2), self.menuTableView.frame.size.width, length);
     */
}

#pragma mark - ScrollView Method
//StickyHeaderView
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    /*
    NSLog(@"self.menuTableView.contentOffset.y %f",self.menuTableView.contentOffset.y);
    NSLog(@"self.menuTableView.contentSize.height %f",self.menuTableView.contentSize.height);
    NSLog(@"self.menuTableView.frame.size.height %f",self.menuTableView.frame.size.height);
    NSLog(@"== %f",(self.menuTableView.contentOffset.y / (self.menuTableView.contentSize.height - self.menuTableView.frame.size.height)));
     */
    float delta = 0.0f;
    CGRect rect = CGRectMake(0, 0, self.view.frame.size.width, 160)
;
    
    // Only allow the header to stretch if pulled down
    if (self.menuTableView.contentOffset.y < 0.0f)
    {
        // Scroll down
        delta = fabs(MIN(0.0f, self.menuTableView.contentOffset.y));
    }
    
    rect.origin.y -= delta;
    rect.size.height += delta;
    
//    self.tableviewHeaderView.frame = rect;
      self.headerImageView.frame = rect;
    
}



@end

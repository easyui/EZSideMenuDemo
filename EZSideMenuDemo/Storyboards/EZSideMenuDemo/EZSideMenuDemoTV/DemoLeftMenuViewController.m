//
//  DemoLeftMenuViewController.m
//  EZSideMenuDemo
//
//  Created by yangjun zhu on 2016/9/27.
//  Copyright © 2016年 Cactus. All rights reserved.
//

#import "DemoLeftMenuViewController.h"
#import "DemoParamsViewController.h"
#import "DemoVideosViewController.h"
#import "EZSideMenu.h"

#define  RootMenu   @{@"0":@[@"Params", @"schedule"], @"1":@[@"Video", @"video"], @"2":@[@"Team", @"team"], @"3":@[@"News", @"news"], @"4":@[@"Shop", @"shop"], @"5":@[@"Setting", @"setting"]}
#define  TeamMenu   @{@"0":@[@"ANA", @"ANA_iphone"], @"1":@[@"BOS", @"BOS_iphone"], @"2":@[@"BUF", @"BUF_iphone"], @"3":@[@"CAR", @"CAR_iphone"], @"4":@[@"CBJ", @"CBJ_iphone"], @"5":@[@"CGY", @"CGY_iphone"], @"6":@[@"CHI", @"CHI_iphone"], @"7":@[@"COL", @"COL_iphone"], @"8":@[@"<   Back", @""]}


@interface DemoLeftMenuViewController ()
@property (weak, nonatomic) IBOutlet UITableView *menuTableView;
@property (strong, nonatomic) NSDictionary *menuDic;
@property (strong, nonatomic) NSArray *viewControllers;
@property (strong, nonatomic) NSIndexPath *focusIndexPath;


@end

@implementation DemoLeftMenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.menuDic = RootMenu;
    self.menuTableView.remembersLastFocusedIndexPath = YES;
    self.viewControllers = @[ [[UINavigationController alloc] initWithRootViewController:[[DemoParamsViewController alloc] initWithNibName:@"DemoParamsViewController" bundle:nil]], [[UINavigationController alloc] initWithRootViewController:[[DemoVideosViewController alloc] initWithNibName:@"DemoVideosViewController" bundle:nil]]];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark -
#pragma mark UITableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    
    if (self.menuDic.count > 6) {
        switch (indexPath.row) {
            case 8:
                self.menuDic = RootMenu;
                self.focusIndexPath = [NSIndexPath indexPathForRow:2 inSection:0];
                
                [self.menuTableView reloadData];
                [self setNeedsFocusUpdate];
                
                [self.sideMenuViewController flashMenu];
                break;
            default:
                break;
        }
    }else{
        switch (indexPath.row) {
            case 0:{
                
                [self.sideMenuViewController hideMenuViewController];
                break;
            }
                
            case 1:{
                
                [self.sideMenuViewController hideMenuViewController];
                break;
            }
                
            case 2:
                self.menuDic = TeamMenu;
                //                [self ConfigTableFrame];
                [self.menuTableView reloadData];
                [self setNeedsFocusUpdate];
                
                [self.sideMenuViewController flashMenu];
                break;
                
            default:
                
                break;
        }
        
    }
}

#pragma mark -
#pragma mark UITableView Datasource


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
        //        cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:21];
        //        cell.textLabel.textColor = [UIColor whiteColor];
        cell.textLabel.highlightedTextColor = [UIColor lightGrayColor];
        cell.selectedBackgroundView = [[UIView alloc] init];
    }
    
    NSArray *arr = [self.menuDic objectForKey:[NSString stringWithFormat:@"%ld", (long)indexPath.row]];
    cell.textLabel.text = arr[0];
    cell.imageView.image = [UIImage imageNamed:arr[1]];
    cell.textLabel.textColor = [UIColor whiteColor];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didUpdateFocusInContext:(UITableViewFocusUpdateContext *)context withAnimationCoordinator:(UIFocusAnimationCoordinator *)coordinator{
    NSIndexPath *prevIndexPath = [context previouslyFocusedIndexPath];
    if (prevIndexPath)
    {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:prevIndexPath];
        cell.textLabel.textColor = [UIColor whiteColor];
        
    }
    
    
    NSIndexPath *nextIndexPath = [context nextFocusedIndexPath];
    if (nextIndexPath)
    {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:nextIndexPath];
        cell.textLabel.textColor = [UIColor blackColor];
        if (nextIndexPath.row <= 1) {
            [self.sideMenuViewController setContentViewController:self.viewControllers[nextIndexPath.row]
                                                         animated:YES];
        }
        
    }
    
}
#pragma mark - private
- (UIView *)preferredFocusedView
{
    
    if (self.focusIndexPath) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            self.focusIndexPath = nil;
            
        });
        return [self.menuTableView cellForRowAtIndexPath:self.focusIndexPath];
        
    }else{
        return self.view.preferredFocusedView;
    }
    
}



@end


//
//  EZMenuViewController.m
//  EZSideMenuDemo
//
//  Created by EZ on 13-11-19.
//  Copyright (c) 2013年 cactus. All rights reserved.
//

#import "EZMenuViewController.h"
#import "EZViewController.h"
#import "EZSecondViewController.h"
#define  CellHeight 54.f
#define  RootMenu   @{@"0":@[@"Schedule", @"schedule"], @"1":@[@"News", @"news"], @"2":@[@"Team", @"team"], @"3":@[@"Video", @"video"], @"4":@[@"Shop", @"shop"], @"5":@[@"Setting", @"setting"]}
#define  TeamMenu   @{@"0":@[@"ANA", @"ANA_iphone"], @"1":@[@"BOS", @"BOS_iphone"], @"2":@[@"BUF", @"BUF_iphone"], @"3":@[@"CAR", @"CAR_iphone"], @"4":@[@"CBJ", @"CBJ_iphone"], @"5":@[@"CGY", @"CGY_iphone"], @"6":@[@"CHI", @"CHI_iphone"], @"7":@[@"COL", @"COL_iphone"], @"8":@[@"<   Back", @""]}
@interface EZMenuViewController ()

@end

@implementation EZMenuViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];

    if (self) {
        // Custom initialization
    }

    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.menuDic = RootMenu;
    [self ConfigTableFrame];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleBlackTranslucent; // UIStatusBarStyleLightContent;
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
                [self ConfigTableFrame];
                [self.menuTableview reloadData];
                [self.sideMenuViewController flashMenu];
                break;
            default:
                break;
        }
    }else{
        switch (indexPath.row) {
            case 0:
                self.sideMenuViewController.contentViewController = [[UINavigationController alloc] initWithRootViewController:[[EZViewController alloc] initWithNibName:@"EZViewController_iPhone" bundle:nil]];
                [self.sideMenuViewController hideMenuViewController];
                break;
                
            case 1:
                self.sideMenuViewController.contentViewController = [[UINavigationController alloc] initWithRootViewController:[[EZSecondViewController alloc] initWithNibName:@"EZSecondViewController" bundle:nil]];
                //            [self.sideMenuViewController setContentViewController:[[UINavigationController alloc] initWithRootViewController:[[EZSecondViewController alloc] initWithNibName:@"EZSecondViewController" bundle:nil]]
                //                                                         animated:YES];
                [self.sideMenuViewController hideMenuViewController];
                break;
                
            case 2:
                self.menuDic = TeamMenu;
                [self ConfigTableFrame];
                [self.menuTableview reloadData];
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

    NSArray *arr = [self.menuDic objectForKey:[NSString stringWithFormat:@"%d", indexPath.row]];
    cell.textLabel.text = arr[0];
    cell.imageView.image = [UIImage imageNamed:arr[1]];

    return cell;
}

#pragma mark - private

- (void)ConfigTableFrame
{
    float length = (self.menuDic.count * CellHeight > self.view.frame.size.height) ? self.view.frame.size.height : self.menuDic.count * CellHeight;

    self.menuTableview.frame = CGRectMake(self.menuTableview.frame.origin.x, ceilf((self.view.frame.size.height - length) / 2), self.menuTableview.frame.size.width, length);
}



@end
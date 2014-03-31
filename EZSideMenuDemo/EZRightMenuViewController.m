//
//  EZRightMenuViewController.m
//  EZSideMenuDemo
//
//  Created by NeuLion SH on 14-3-26.
//  Copyright (c) 2014年 cactus. All rights reserved.
//

#import "EZRightMenuViewController.h"
#define  CellHeight 54.f
@interface EZRightMenuViewController ()

@end

@implementation EZRightMenuViewController

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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



#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_6_1
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return  UIStatusBarStyleLightContent;
}

#endif

#pragma mark -
#pragma mark UITableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
//    if (self.menuDic.count > 6) {
//        switch (indexPath.row) {
//            case 8:
//                self.menuDic = RootMenu;
//                [self ConfigTableFrame];
//                [self.menuTableview reloadData];
//                [self.sideMenuViewController flashMenu];
//                break;
//            default:
//                break;
//        }
//    }else{
//        switch (indexPath.row) {
//            case 0:
//                self.sideMenuViewController.contentViewController = [[UINavigationController alloc] initWithRootViewController:[[EZViewController alloc] initWithNibName:@"EZViewController_iPhone" bundle:nil]];
//                [self.sideMenuViewController hideMenuViewController];
//                break;
//                
//            case 1:
//                self.sideMenuViewController.contentViewController = [[UINavigationController alloc] initWithRootViewController:[[EZSecondViewController alloc] initWithNibName:@"EZSecondViewController" bundle:nil]];
//                //            [self.sideMenuViewController setContentViewController:[[UINavigationController alloc] initWithRootViewController:[[EZSecondViewController alloc] initWithNibName:@"EZSecondViewController" bundle:nil]]
//                //                                                         animated:YES];
//                [self.sideMenuViewController hideMenuViewController];
//                break;
//                
//            case 2:
//                self.menuDic = TeamMenu;
//                [self ConfigTableFrame];
//                [self.menuTableview reloadData];
//                [self.sideMenuViewController flashMenu];
//                break;
//                
//            default:
//                
//                break;
//        }
//        
//    }
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
    return 3;
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
            cell.textLabel.textAlignment = NSTextAlignmentRight;
        cell.selectedBackgroundView = [[UIView alloc] init];
    }
    
//    NSArray *arr = [self.menuDic objectForKey:[NSString stringWithFormat:@"%d", indexPath.row]];
    cell.textLabel.text =@"testttt";
//    cell.imageView.image = [UIImage imageNamed:arr[1]];
    
    return cell;
}

@end

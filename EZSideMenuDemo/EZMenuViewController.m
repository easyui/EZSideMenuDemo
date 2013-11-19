//
//  EZMenuViewController.m
//  EZSideMenuDemo
//
//  Created by NeuLion SH on 13-11-19.
//  Copyright (c) 2013年 cactus. All rights reserved.
//

#import "EZMenuViewController.h"
#import "EZViewController.h"
#import "EZSecondViewController.h"
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
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark UITableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
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
        default:
            break;
    }
}

#pragma mark -
#pragma mark UITableView Datasource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 54;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
    return 6;
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
    
    NSArray *titles = @[@"Home", @"Schhedule", @"Profile", @"Settings",@"Settings", @"Log Out"];
    NSArray *images = @[@"IconHome", @"IconCalendar", @"IconProfile", @"IconSettings",@"IconSettings", @"IconEmpty"];
    cell.textLabel.text = titles[indexPath.row];
    cell.imageView.image = [UIImage imageNamed:images[indexPath.row]];
    
    return cell;
}


- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleDefault ;//UIStatusBarStyleLightContent;
}

@end

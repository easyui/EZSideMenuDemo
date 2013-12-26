//
//  NLMenuViewController.m
//  EZSideMenuDemo
//
//  Created by EZ on 13-11-24.
//  Copyright (c) 2013年 cactus. All rights reserved.
//

#import "NLMenuViewController.h"
#import "EZSideMenu.h"
#define  SquareArr  @[@"LIVE GAMES", @"MY TEAMS", @"RECOMMNDED", @"COPA AMERICA"]
#define  MenuDic    @{@"AFavorte":@[@"Add Favorites"], @"FUTBOL":@[@"Todos Las Ligas", @"CONCACAF", @"Europa", @"Sudamerica", @"Tourneos", @"Tourneo", @"Tourne", @"Tourn", @"Tour"]}
#define  TeamDic    @{@"":@[@"< Main Menu"], @"FUTBOL":@[@"Todos Las Ligas", @"CONCACAF", @"Europa", @"Sudamerica", @"Tourneos", @"Tourneo", @"Tourne", @"Tourn", @"Tour"]}
@interface NLMenuViewController ()
@property (strong, nonatomic) NSArray   *sectionArr;
@property (assign, nonatomic) CGFloat   menuWidth;
@property (assign, nonatomic) CGFloat   squareWidth;
@property (assign, nonatomic) CGFloat   squareHeight;
@end

@implementation NLMenuViewController

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
    self.squareArr = [[NSMutableArray alloc] initWithArray:SquareArr];
    self.menuDic = [[NSMutableDictionary alloc] initWithDictionary:MenuDic];
    self.sectionArr = [self.menuDic allKeys];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    if ([self isViewLoaded] && (self.view.window == nil)) {
       /////
        self.view = nil;
    }
    /////
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self drawMenu];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    //    [self drawMenu];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}


#pragma mark - public
- (void)drawMenu
{
    [self.view.window endEditing:YES];
    self.sectionArr = [self.menuDic allKeys];
    self.menuWidth = 270.f;//135; // 138;
    self.squareHeight = 100.f;
    self.squareWidth = 125.f;
    
    int     squareRows = (self.squareArr.count + 1) / 2;
    float   y = 0.f;

    if (self.titleView.hidden == NO) {
        y = self.titleView.frame.origin.y + self.titleView.frame.size.height;
    }

    self.squareView.frame = CGRectMake(self.squareView.frame.origin.x, y, self.menuWidth, self.self.squareHeight * squareRows);

    if (self.squareView.hidden == NO) {
        y = self.squareView.frame.origin.y + self.squareView.frame.size.height;
    }

    self.menuView.frame = CGRectMake(self.menuView.frame.origin.x, y, self.menuWidth , [[UIScreen mainScreen]bounds].size.height - y);
    [self.squareTableView reloadData];
    [self.menuTableView reloadData];
}

#pragma mark - private
- (UIButton *)createSquareButtonWithMethodName:(NSString *)methodName AtIndex:(NSInteger)index
{
    UIButton *squareButton = [UIButton buttonWithType:UIButtonTypeCustom];

    squareButton.tag = index;
    float squareX;
    if(index % 2){
         squareX = self.squareWidth;
    }else{
        squareX = self.menuWidth/2 - self.squareWidth;
    }
    squareButton.frame = CGRectMake(squareX, 0, self.squareWidth, self.squareHeight);
    [squareButton addTarget:self action:NSSelectorFromString(methodName) forControlEvents:UIControlEventTouchUpInside];
    [squareButton setTitle:self.squareArr[index] forState:UIControlStateNormal];
    squareButton.titleLabel.font = [UIFont systemFontOfSize:12.0];
    [squareButton setImage:[UIImage imageNamed:@"CAR_iphone"] forState:UIControlStateNormal];
    [squareButton setImage:[UIImage imageNamed:@"CBJ_iphone"] forState:UIControlStateHighlighted];
    return squareButton;
}

- (void)configSquareUI:(UITableViewCell *)cell AtIndex:(NSInteger)index
{
    [cell.contentView addSubview:[self createSquareButtonWithMethodName:@"squareButtonAction:" AtIndex:index]];
}

- (void)flashMenu{
    // Animate to deappear
    self.squareView.transform = CGAffineTransformScale(self.squareView.transform, 0.9, 0.9);
    self.menuView.transform = CGAffineTransformScale(self.menuView.transform, 0.9, 0.9);
    [UIView animateWithDuration:0.5 animations:^{
        self.squareView.transform = CGAffineTransformIdentity;
        self.menuView.transform = CGAffineTransformIdentity;
    }];
    [UIView animateWithDuration:0.6 animations:^{
        self.squareView.alpha = 0;
        self.menuView.alpha = 0;
    }];
    
    [UIView animateWithDuration:0.6 animations:^{
        self.squareView.alpha = 1;
        self.menuView.alpha = 1;
    }];
}
#pragma mark - action

- (void)squareButtonAction:(UIButton *)squareButton
{
    NSLog(@"__%d", squareButton.tag);
}

#pragma mark -
#pragma mark UITableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if ([((NSArray *)[self.menuDic objectForKey:self.sectionArr[indexPath.section]])[indexPath.row] isEqualToString:@"< Main Menu"]) {
        self.squareView.hidden =  NO;
        self.menuDic = [[NSMutableDictionary alloc] initWithDictionary:MenuDic];
        [self drawMenu];
        [self flashMenu];
    }else{
    self.squareView.hidden =  YES;
    self.menuDic = [[NSMutableDictionary alloc] initWithDictionary:TeamDic];
    [self drawMenu];
    [self flashMenu];
    }
}

#pragma mark -
#pragma mark UITableView Datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (tableView == self.squareTableView) {
        return 1;
    } else if (tableView == self.menuTableView) {
        return self.sectionArr.count;
    }

    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (tableView == self.squareTableView) {
        return 0.f;
    } else if (tableView == self.menuTableView) {
        
        return ((NSString *)self.sectionArr[section]).length > 0?22.f:0.f;;
    }

    return 0.f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (tableView == self.squareTableView) {
        return nil;
    } else if (tableView == self.menuTableView) {
        UILabel *sectionTitle = [[UILabel alloc] initWithFrame:CGRectZero];
        sectionTitle.font = [UIFont systemFontOfSize:15];
        sectionTitle.textColor = [UIColor blackColor];
        sectionTitle.backgroundColor = [UIColor colorWithWhite:1 alpha:0];
        sectionTitle.text = [NSString stringWithFormat:@" %@", self.sectionArr[section]];
        return sectionTitle;
    }

    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
    if (tableView == self.squareTableView) {
        return (self.squareArr.count + 1) / 2;
    } else if (tableView == self.menuTableView) {
        return [(NSArray *)[self.menuDic objectForKey:self.sectionArr[sectionIndex]] count];
    }

    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.squareTableView) {
        return self.squareHeight;
    } else if (tableView == self.menuTableView) {
        return 44.f;
    }

    return 0.f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *squareCellIdentifier = @"squareCellIdentifier";
    static NSString *menuCellIdentifier = @"menuCellIdentifier";

    if (tableView == self.squareTableView) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:squareCellIdentifier];

        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:squareCellIdentifier];
            cell.backgroundColor = [UIColor clearColor];
        }

        //        self ;
        [self configSquareUI:cell AtIndex:indexPath.row * 2];
        [self configSquareUI:cell AtIndex:indexPath.row * 2 + 1];

        return cell;
    } else if (tableView == self.menuTableView) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:menuCellIdentifier];

        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:menuCellIdentifier];
            cell.backgroundColor = [UIColor clearColor];
            cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:21];
            cell.textLabel.textColor = [UIColor blueColor];
            cell.textLabel.highlightedTextColor = [UIColor lightGrayColor];
            cell.selectedBackgroundView = [[UIView alloc] init];
        }

        cell.textLabel.text = ((NSArray *)[self.menuDic objectForKey:self.sectionArr[indexPath.section]])[indexPath.row];
        UIImageView *accessoryImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 15, 22)];
        [accessoryImage setImage:[UIImage imageNamed:@"arrow"]];
        cell.accessoryView = accessoryImage;

        return cell;
    }

    return nil;
}

@end
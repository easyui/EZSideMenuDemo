//
//  DemoParamsViewController.m
//  EZSideMenuDemo
//
//  Created by yangjun zhu on 2016/9/27.
//  Copyright © 2016年 Cactus. All rights reserved.
//

#import "DemoParamsViewController.h"
#import "EZSideMenu.h"

@interface DemoParamsViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation DemoParamsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tableView.remembersLastFocusedIndexPath = YES;

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

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 2;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"reuse";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier] ;
    }
    switch (indexPath.row) {
        case 0:
            cell.textLabel.text = @"show";
            break;
        case 1:
            cell.textLabel.text = @"hidden";
            break;
        default:
            break;
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    switch (indexPath.row) {
        case 0:
            [self.sideMenuViewController presentLeftMenuViewController];
            break;
        case 1:
            [self.sideMenuViewController hideMenuViewController];
            break;
        default:
            break;
    }

}

@end

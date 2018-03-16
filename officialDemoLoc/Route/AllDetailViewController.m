//
//  AllDetailViewController.m
//  CQtralDemo
//
//  Created by 科文 on 2017/4/24.
//  Copyright © 2017年 ZdSoft. All rights reserved.
//

#import "AllDetailViewController.h"
//#import "AMapTestViewController.h"
#import "MainViewController.h"

@interface AllDetailViewController ()

@end

@implementation AllDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)action:(id)sender {
    [self navAction];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
-(void)followClick{
    
}
-(void)navAction{
    
    
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
//ß    AMapTestViewController *mapTVC = (AMapTestViewController*)[storyboard instantiateViewControllerWithIdentifier:@"MapTestViewController"];
    UIViewController *mapTVC = (UIViewController*)[storyboard instantiateViewControllerWithIdentifier:@"MainViewController"];
    
//    mapTVC.destinationPoint=@"106.577052,29.557259";
//    mapTVC.dsTitle=@"解放碑";
//    UIViewController *ctrol = [[UIViewController alloc] init];
    UINavigationController *nv=[[UINavigationController alloc]initWithRootViewController:mapTVC];
    [self presentViewController:nv animated:YES completion:nil];
}


@end

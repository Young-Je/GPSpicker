//
//  MainViewController.m
//  AMapLocationDemo
//
//  Created by 刘博 on 16/3/7.
//  Copyright © 2016年 AutoNavi. All rights reserved.
//

#import "MainViewController.h"
#import "MyDocument.h"
#import "DataListTableViewController.h"
#import "SharedInstance.h"

#define MainViewControllerTitle @"HTGPSPicker"

@interface MainViewController ()<UITableViewDataSource, UITableViewDelegate>
//@property (weak, nonatomic) IBOutlet UIButton *test;

@property (nonatomic, strong) NSArray *sections;
@property (nonatomic, strong) NSArray *classNames;
@property (nonatomic, strong) UITableView *tableView;

@end

@implementation MainViewController

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_sections[section][1] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return _sections[section][0];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *mainCellIdentifier = @"mainCellIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:mainCellIdentifier];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:mainCellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    if (indexPath.row<=5&&indexPath.section == 0) {
            cell.detailTextLabel.text = self.classNames[indexPath.section][indexPath.row];
    }
    
    cell.textLabel.text = _sections[indexPath.section][1][indexPath.row];
    

    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0:
        {
            if (indexPath.row <=5) {
                [tableView deselectRowAtIndexPath:indexPath animated:YES];
                
                NSString *className = self.classNames[indexPath.section][indexPath.row];
                
                UIViewController *subViewController = [[NSClassFromString(className) alloc] init];
                NSString *xibBundlePath = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%@",className] ofType:@"xib"];
                if (xibBundlePath.length) {
                    subViewController = [[NSClassFromString(className) alloc] initWithNibName:className bundle:nil];
                }
                
                subViewController.title = _sections[indexPath.section][1][indexPath.row];
                
                [self.navigationController pushViewController:subViewController animated:YES];
            }//else if (indexPath.row ==6 )
//            {
//
//
//                //make a file name to write the data to using the documents directory:
//
//                UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"altert"
//                                                                message:@"clearing... ... "
//                                                               delegate:self
//                                                      cancelButtonTitle:@"Done"
//                                                      otherButtonTitles:@"Cancel",nil];
//
//                [alert show];
//            }else if (indexPath.row ==7)
//            {
//                DataListTableViewController *subviewctrl = [[DataListTableViewController alloc] initWithFileName:[[SharedInstance sharedInstance] fileName]];
//                [self.navigationController pushViewController:subviewctrl animated:YES];
//            }else if (indexPath.row == 8){
//                DataListTableViewController *subviewctrl = [[DataListTableViewController alloc] initWithFileName:[[SharedInstance sharedInstance] processedDataFileName]];
//                [self.navigationController pushViewController:subviewctrl animated:YES];
//            }
        }
            break;
        case 1:
        {
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"altert"
                                                            message:@"clearing... ... "
                                                           delegate:self
                                                  cancelButtonTitle:@"Done"
                                                  otherButtonTitles:@"Cancel",nil];
            
            [alert show];
        }
            break;
        case 2:
        {
            if (indexPath.row ==0)
            {
                DataListTableViewController *subviewctrl = [[DataListTableViewController alloc] initWithFileName:[[SharedInstance sharedInstance] fileName]];
                [self.navigationController pushViewController:subviewctrl animated:YES];
            }else if (indexPath.row == 1){
                DataListTableViewController *subviewctrl = [[DataListTableViewController alloc] initWithFileName:[[SharedInstance sharedInstance] processedDataFileName]];
                [self.navigationController pushViewController:subviewctrl animated:YES];
            }
        }
            break;
            
        default:
            break;
    }
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    // the user clicked OK
    switch (buttonIndex) {
        case 0:
        {
            NSError *error = nil;
            NSArray *paths = NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentsDirectory = [paths objectAtIndex:0];
            NSString *fileName = [NSString stringWithFormat:@"%@/filename.txt",
                                  documentsDirectory];
            [ [NSFileManager defaultManager] removeItemAtPath:fileName error:&error];
            [ [NSFileManager defaultManager] removeItemAtPath:[[SharedInstance sharedInstance] processedDataFileName] error:&error];
            break;
        }
            
        case 1:
            
            break;
        default:
            break;
    }
}


#pragma mark - Initialization

- (void)initTitles
{
    NSString *sec1Title = @"基本功能";
    NSArray *sec1CellTitles = @[@"连续定位"];
    
    NSString *sec2Title = @"Clear";
    NSArray *sec2CellTitles = @[ @"clear"
                                ];
     NSString *sec3Title = @"View";
    NSArray *sec3CellTitles = @[
                                @"RawData",
                                @"ProcessedData"
                                ];
    
    NSArray *section1 = @[sec1Title, sec1CellTitles];
    NSArray *section2 = @[sec2Title, sec2CellTitles];
    NSArray *section3 = @[sec3Title, sec3CellTitles];
    
    
    
    self.sections = [NSArray arrayWithObjects:section1,section2, section3,nil];
}

- (void)initClassNames
{
    NSArray *sec1ClassNames = @[@"SerialLocationViewController"];
    
    self.classNames = [NSArray arrayWithObjects:sec1ClassNames, nil];
}

- (void)initTableView
{
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.tableView.delegate   = self;
    self.tableView.dataSource = self;
    
    [self.view addSubview:self.tableView];
}

#pragma mark - Life Cycle

- (id)init
{
    if (self = [super init])
    {
        self.title = MainViewControllerTitle;
        
        [self initTitles];
        
        [self initClassNames];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initTableView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden       = NO;
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.toolbarHidden             = YES;
}

@end

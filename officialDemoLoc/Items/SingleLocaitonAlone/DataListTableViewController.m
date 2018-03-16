//
//  DataListTableViewController.m
//  officialDemoLoc
//
//  Created by Hutong on 04/09/2017.
//  Copyright © 2017 AutoNavi. All rights reserved.
//

#import "DataListTableViewController.h"

@interface DataListTableViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) NSArray *dataList;
@end

@implementation DataListTableViewController

-(id)initWithFileName:(NSString *)fileName{
    if (self==[super init]) {
        self.fileName = fileName;
        return self;
    }else
        return nil;
}

-(void)initTableview{
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
}

-(NSArray *)dataList{
    if (_dataList==nil) {
        /* get a background queue (To do your things that might take time) */
        dispatch_queue_t backgroundQueue =
        dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        /* get the main queue (To update the UI)*/
        dispatch_queue_t mainQueue = dispatch_get_main_queue();
        
        /* use dispatch_async to run something (twitter, etc)
         asynchronously in the give queue (in the background) */
        dispatch_async(backgroundQueue,^{
            NSError *error;
            NSString *fileContents = [NSString stringWithContentsOfFile:self.fileName encoding:NSUTF8StringEncoding error:&error];
            _dataList = [fileContents componentsSeparatedByString:@"\n"];
            /* use again dispatch_async to update the UI (the table view)
             in another queue (the main queue) */
            dispatch_async(mainQueue,^{
                [self.tableView reloadData];
            });
        });
    }
    return _dataList;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataList.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *mainCellIdentifier = @"mainCellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:mainCellIdentifier];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:mainCellIdentifier];
//        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    NSInteger row = [indexPath row];
//    NSString *display = [self.dataList objectAtIndex: row];
    [cell.textLabel setFont:[UIFont systemFontOfSize:10]];
    cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
    cell.textLabel.numberOfLines = 0;
    cell.textLabel.text = [self.dataList objectAtIndex: row];
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

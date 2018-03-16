//
//  SingleLocaitonAloneViewController.m
//  officialDemoLoc
//
//  Created by 朱浩 on 16/2/24.
//  Copyright © 2016年 AutoNavi. All rights reserved.
//

#import "SingleLocaitonAloneViewController.h"
#import "MyDocument.h"
#import "SharedInstance.h"

#define DefaultLocationTimeout 10
#define DefaultReGeocodeTimeout 5

@interface SingleLocaitonAloneViewController () <AMapLocationManagerDelegate>

@property (nonatomic, copy) AMapLocatingCompletionBlock completionBlock;

@property (nonatomic, strong) UILabel *displayLabel;
@property (nonatomic, strong)NSString *fileName;

@end

@implementation SingleLocaitonAloneViewController

#pragma mark - Action Handle

//-(void)setFileName:(NSString *)fileName{
//    if (_fileName==nil) {
//        NSArray *paths = NSSearchPathForDirectoriesInDomains
//        (NSDocumentDirectory, NSUserDomainMask, YES);
//        NSString *documentsDirectory = [paths objectAtIndex:0];
//
//        //make a file name to write the data to using the documents directory:
//        _fileName = [NSString stringWithFormat:@"%@/filename.txt",
//                              documentsDirectory];
//
//    }
//}

-(NSString *)fileName{
    if (_fileName==nil) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        
        //make a file name to write the data to using the documents directory:
        _fileName = [NSString stringWithFormat:@"%@/filename.txt",
                     documentsDirectory];
        return _fileName;
    }
    return _fileName;
}

- (void)configLocationManager
{
    self.locationManager = [[AMapLocationManager alloc] init];
    
    [self.locationManager setDelegate:self];
    

    
    //设置期望定位精度
    [self.locationManager setDesiredAccuracy:kCLLocationAccuracyHundredMeters];
    
    //设置不允许系统暂停定位
    [self.locationManager setPausesLocationUpdatesAutomatically:NO];
    
    //设置允许在后台定位
    [self.locationManager setAllowsBackgroundLocationUpdates:YES];
    
    //设置定位超时时间
    [self.locationManager setLocationTimeout:DefaultLocationTimeout];
    
    //设置逆地理超时时间
    [self.locationManager setReGeocodeTimeout:DefaultReGeocodeTimeout];
}

- (void)cleanUpAction
{
    //停止定位
    [self.locationManager stopUpdatingLocation];
    
    [self.locationManager setDelegate:nil];
    
    [self.displayLabel setText:nil];
}

- (void)reGeocodeAction
{
    //进行单次带逆地理定位请求
    [self.locationManager requestLocationWithReGeocode:YES completionBlock:self.completionBlock];
}

- (void)locAction
{
    //进行单次定位请求
    [self.locationManager requestLocationWithReGeocode:YES completionBlock:self.completionBlock];
}

#pragma mark - Initialization

- (void)initCompleteBlock
{
    __weak SingleLocaitonAloneViewController *weakSelf = self;
    self.completionBlock = ^(CLLocation *location, AMapLocationReGeocode *regeocode, NSError *error)
    {
        if (error != nil && error.code == AMapLocationErrorLocateFailed)
        {
            //定位错误：此时location和regeocode没有返回值，不进行annotation的添加
            NSLog(@"定位错误:{%ld - %@};", (long)error.code, error.localizedDescription);
            return;
        }
        else if (error != nil
                 && (error.code == AMapLocationErrorReGeocodeFailed
                     || error.code == AMapLocationErrorTimeOut
                     || error.code == AMapLocationErrorCannotFindHost
                     || error.code == AMapLocationErrorBadURL
                     || error.code == AMapLocationErrorNotConnectedToInternet
                     || error.code == AMapLocationErrorCannotConnectToHost))
        {
            //逆地理错误：在带逆地理的单次定位中，逆地理过程可能发生错误，此时location有返回值，regeocode无返回值，进行annotation的添加
            NSLog(@"逆地理错误:{%ld - %@};", (long)error.code, error.localizedDescription);
        }
        else if (error != nil && error.code == AMapLocationErrorRiskOfFakeLocation)
        {
            //存在虚拟定位的风险：此时location和regeocode没有返回值，不进行annotation的添加
            NSLog(@"存在虚拟定位的风险:{%ld - %@};", (long)error.code, error.localizedDescription);
            return;
        }
        else
        {
            //没有错误：location有返回值，regeocode是否有返回值取决于是否进行逆地理操作，进行annotation的添加
        }
        
        //修改label显示内容
//        if (false)
//        {
//                        [weakSelf.displayLabel setText:[NSString stringWithFormat:@"%@ \n", regeocode.formattedAddress]];
////            [weakSelf.displayLabel setText:[NSString stringWithFormat:@"%@ \n %@-%@-%.2fm", regeocode.formattedAddress,regeocode.citycode, regeocode.adcode, location.horizontalAccuracy]];
//        }
//        else
        {
            [weakSelf.displayLabel setText:[NSString stringWithFormat:@"lat:%f;lon:%f \n accuracy:%.2fm \n %@", location.coordinate.latitude, location.coordinate.longitude, location.horizontalAccuracy, regeocode.formattedAddress]];
            

            
//            NSString *content = @"This is Demo xxxxx";
//            [content writeToFile:weakSelf.fileName
//                      atomically:NO
//                        encoding:NSStringEncodingConversionAllowLossy
//                           error:nil];
            //sychronize file to icloud
//            [weakSelf iCloudSyncing:weakSelf.fileName];
            
        }
        
        if(location.coordinate.latitude != 0.0){
            
            NSString *locationFilePath = [[SharedInstance sharedInstance] fileName]; //weakSelf.fileName;//access the path of file
            
            
//            NSString *address = regeocode.formattedAddress;
//            NSString *lastChar = [address substringFromIndex:[address length] - 11];
            if (weakSelf) {
                FILE *fp = fopen([locationFilePath UTF8String], "a");
                fprintf(fp,"%f %f %s \n", location.coordinate.latitude, location.coordinate.longitude,[regeocode.formattedAddress cStringUsingEncoding:NSUTF8StringEncoding] );
                
                fclose(fp);
                UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"altert"
                                                                message:@"saved!"
                                                               delegate:nil
                                                      cancelButtonTitle:@"Done"
                                                      otherButtonTitles:nil];
                
                [alert show];
            }

        }
        
    };
}

-(void) iCloudSyncing:(NSString*) filename
{
    //Doc dir
//    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
//    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:filename];
    NSURL *u = [[NSURL alloc] initFileURLWithPath:filename];
    NSData *data = [[NSData alloc] initWithContentsOfURL:u];
    
    
    //Get iCloud container URL
    NSURL *ubiq = [[NSFileManager defaultManager]URLForUbiquityContainerIdentifier:nil];// in place of nil you can add your container name
    //Create Document dir in iCloud container and upload/sync SampleData.zip
    NSURL *ubiquitousPackage = [[ubiq URLByAppendingPathComponent:@"Documents"]URLByAppendingPathComponent:@"filename.txt"];
//    NSURL *destination = [[NSFileManager defaultManager] URLForUbiquityContainerIdentifier:nil];
    MyDocument *Mydoc = [[MyDocument alloc] initWithFileURL:ubiquitousPackage];
    Mydoc.dataContent = data;
    
//    NSURL *destinationURL = [self.ubiquitousURL URLByAppendingPathComponent:@"Documents/image.jpg"];
//    NSError *error;
//    [[NSFileManager defaultManager] setUbiquitous:YES
//                                        itemAtURL:u
//                                   destinationURL:ubiquitousPackage
//                                            error:&error];
    
    [Mydoc saveToURL:[Mydoc fileURL] forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success)
     {
         if (success)
         {
             NSLog(@"SampleData.zip: Synced with icloud");
         }
         else
             NSLog(@"SampleData.zip: Syncing FAILED with icloud");

     }];
}



// 3 Download data from the iCloud Container

- (IBAction)GetData:(id)sender {
    
    //--------------------------Get data back from iCloud -----------------------------//
    id token = [[NSFileManager defaultManager] ubiquityIdentityToken];
    if (token == nil)
    {
        NSLog(@"ICloud Is not LogIn");
    }
    else
    {
        NSLog(@"ICloud Is LogIn");
        
        NSError *error = nil;
        NSURL *ubiq = [[NSFileManager defaultManager]URLForUbiquityContainerIdentifier:nil];// in place of nil you can add your container name
        NSURL *ubiquitousPackage = [[ubiq URLByAppendingPathComponent:@"Documents"]URLByAppendingPathComponent:@"SampleData.zip"];
        BOOL isFileDounloaded = [[NSFileManager defaultManager]startDownloadingUbiquitousItemAtURL:ubiquitousPackage error:&error];
        if (isFileDounloaded) {
            NSLog(@"%d",isFileDounloaded);
            NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
            //changing the file name as SampleData.zip is already present in doc directory which we have used for upload
            NSString* fileName = [NSString stringWithFormat:@"RecSampleData.zip"];
            NSString* fileAtPath = [documentsDirectory stringByAppendingPathComponent:fileName];
            NSData *dataFile = [NSData dataWithContentsOfURL:ubiquitousPackage];
            BOOL fileStatus = [dataFile writeToFile:fileAtPath atomically:NO];
            if (fileStatus) {
                NSLog(@"success");
            }
        }
        else{
            NSLog(@"%d",isFileDounloaded);
        }
    }
}

//4 voila its done :)

//+(void)write{
//
//    //Decode using
//    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:[HistoryFile files]];
//
//    //Save Data To NSUserDefault
//    NSUbiquitousKeyValueStore *iCloud =  [NSUbiquitousKeyValueStore defaultStore];
//
//    //let ios know we want to save the data
//    [iCloud setObject:data forKey:@"app_data"];
//
//
//    //iOS will save the data when it is ready.
//    [iCloud synchronize];
//
//}
//
//
//+(NSMutableArray*)read{
//    //Read Settings Value From NSUserDefault
//    //get the NSUserDefaults object
//
//    NSUbiquitousKeyValueStore *iCloud =  [NSUbiquitousKeyValueStore defaultStore];
//    //read value back from the settings
//    NSData *data = [iCloud objectForKey:@"app_data"];
//    NSMutableArray *data_array = (NSMutableArray*)[NSKeyedUnarchiver unarchiveObjectWithData:data];
//    NSLog(@"data_array %@",data_array);
//    return data_array;
//}



- (void)initToolBar
{
    UIBarButtonItem *flexble = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                             target:nil
                                                                             action:nil];
    
    UIBarButtonItem *reGeocodeItem = [[UIBarButtonItem alloc] initWithTitle:@"带逆地理定位"
                                                                      style:UIBarButtonItemStylePlain
                                                                     target:self
                                                                     action:@selector(reGeocodeAction)];
    
    UIBarButtonItem *locItem = [[UIBarButtonItem alloc] initWithTitle:@"不带逆地理定位"
                                                                style:UIBarButtonItemStylePlain
                                                               target:self
                                                               action:@selector(locAction)];
    
    self.toolbarItems = [NSArray arrayWithObjects:flexble, reGeocodeItem, flexble, locItem, flexble, nil];
}

- (void)initNavigationBar
{
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Clean"
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(cleanUpAction)];
}

- (void)initDisplayLabel
{
    self.displayLabel = [[UILabel alloc] init];
    self.displayLabel.frame = [UIScreen mainScreen].bounds;
    self.displayLabel.backgroundColor  = [UIColor clearColor];
    self.displayLabel.textColor        = [UIColor blackColor];
    self.displayLabel.textAlignment = NSTextAlignmentCenter;
    self.displayLabel.numberOfLines = 0;
    
    [self.view addSubview:_displayLabel];
}

#pragma mark - Life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[UIColor grayColor]];
    
    [self initToolBar];
    
    [self initNavigationBar];
    
    [self initCompleteBlock];
    
    [self configLocationManager];
    
    [self initDisplayLabel];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.toolbar.translucent   = YES;
    self.navigationController.toolbarHidden         = NO;
}

- (void)dealloc
{
    [self cleanUpAction];
    
    self.completionBlock = nil;
}

@end

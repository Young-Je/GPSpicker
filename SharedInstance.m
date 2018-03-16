//
//  SharedInstance.m
//  officialDemoLoc
//
//  Created by Hutong on 06/09/2017.
//  Copyright © 2017 AutoNavi. All rights reserved.
//

#import "SharedInstance.h"

@implementation SharedInstance

+(id)sharedInstance
{
    static SharedInstance *singleton = NULL;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        singleton = [[self alloc] init];
    });
    return singleton;
}

-(NSInteger)currentStopNum{
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _currentStopNum = 1;
    });
    return _currentStopNum;
}

-(NSNumber *)numberBusNum{
    if (_numberBusNum==nil) {
        _numberBusNum = [NSNumber numberWithInt:1];
    }
    return _numberBusNum;
}

//- (int)numberOfDays
//{
//    if (_numberOfDays == nil) {
//        // relatively memory intense calculation that works out numberOfDays:
//        _numberOfDays = @(X);
//    }
//    return [_numberOfDays intValue];
//}
-(NSString *)stepFlag{
    if (_stepFlag == nil) {
        _stepFlag =@"+";
    }
    return _stepFlag;
}

- (BOOL)sampleMode{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sampleMode = NO;
    });
    return _sampleMode;
}

- (NSMutableArray *)tripleSet{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _tripleSet = [[NSMutableArray alloc] init];
    });
    return _tripleSet;
}

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

- (NSString *)processedDataFileName{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSArray *paths = NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        
        //make a file name to write the data to using the documents directory:
        _processedDataFileName = [NSString stringWithFormat:@"%@/processedData.txt",
                     documentsDirectory];
    });
    return _processedDataFileName;
}

@end

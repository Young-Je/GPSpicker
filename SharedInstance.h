//
//  SharedInstance.h
//  officialDemoLoc
//
//  Created by Hutong on 06/09/2017.
//  Copyright © 2017 AutoNavi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SharedInstance : NSObject
@property (nonatomic, strong) NSString *fileName;
@property (nonatomic) BOOL sampleMode;
@property  (nonatomic, strong) NSMutableArray *tripleSet;
@property (nonatomic, strong)NSString *processedDataFileName;
@property (nonatomic) NSInteger currentStopNum;
@property (nonatomic, strong) NSString *stepFlag;
@property (nonatomic, strong) NSNumber *numberBusNum;
+(id)sharedInstance;

@end

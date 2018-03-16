//
//  GPSMetaData.m
//  officialDemoLoc
//
//  Created by Hutong on 11/09/2017.
//  Copyright © 2017 AutoNavi. All rights reserved.
//

#import "GPSMetaData.h"

@implementation GPSMetaData

-(id)init{
    if (self = [super init]) {
        _longtitude = 0;
        _latitude = 0;
        return self;
    }else
    return nil;
}

@end

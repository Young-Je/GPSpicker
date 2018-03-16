//
//  MyPoint.m
//  officialDemoLoc
//
//  Created by Hutong on 20/09/2017.
//  Copyright © 2017 AutoNavi. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "MyPoint.h"

@implementation MyPoint

-(id)initWithCoordinate:(CLLocationCoordinate2D)c andTitle:(NSString *)t{
    self = [super init];
    if(self){
        _coordinate = c;
        _title = t;
    }
    return self;
}
@end

//
//  MAAnnotationView+Extension.m
//  officialDemoLoc
//
//  Created by Hutong on 26/09/2017.
//  Copyright © 2017 AutoNavi. All rights reserved.
//

@import UIKit;
@import Foundation;
#import "MAAnnotationView+Extension.h"
#import <UIKit/UIKit.h>

@implementation MAAnnotationView (Extension)
-(void)rotateWithHeading:(CLHeading *)heading{
    
    CLLocationDirection headings = M_PI * heading.magneticHeading / 180.0;
    CABasicAnimation* rotateAnimation = [[CABasicAnimation alloc] init];
    [rotateAnimation setKeyPath:@"transform"];
    CATransform3D formValue = self.layer.transform;
    [rotateAnimation setFromValue:[NSValue valueWithCATransform3D:formValue]];
    CATransform3D toValue = CATransform3DMakeRotation((headings), 0, 0, 1);
    [rotateAnimation setToValue:[NSValue valueWithCATransform3D:toValue]];
    rotateAnimation.duration = 0.35;
    self.layer.transform = toValue;
    [self.layer addAnimation:rotateAnimation forKey:nil];
    //func rotateWithHeading(heading: CLHeading) {
    //
    //    //将设备的方向角度换算成弧度
    //    let headings = M_PI * heading.magneticHeading / 180.0
    //    //创建不断旋转CALayer的transform属性的动画
    //    let rotateAnimation = CABasicAnimation(keyPath: "transform")
    //    //动画起始值
    //    let formValue = self.layer.transform
    //    rotateAnimation.fromValue = NSValue(caTransform3D: formValue)
    //    //绕Z轴旋转heading弧度的变换矩阵
    //    let toValue = CATransform3DMakeRotation(CGFloat(headings), 0, 0, 1)
    //    //设置动画结束值
    //    rotateAnimation.toValue = NSValue(caTransform3D: toValue)
    //    rotateAnimation.duration = 0.35
    //    rotateAnimation.isRemovedOnCompletion = true
    //    //设置动画结束后layer的变换矩阵
    //    self.layer.transform = toValue
    //
    //    //添加动画
    //    self.layer.add(rotateAnimation, forKey: nil)
    //
    //}
    
    //-(void)rotateWithHeading:(CLHeading*) heading
    //{
    //    CLLocationDirection *heading = M_PI * heading.magneticHeading / 180.0;
    //    CAPropertyAnimation* rotateAnimation =
    //
    //}

}
@end

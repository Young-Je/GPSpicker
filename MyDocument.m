//
//  MyDocument.m
//  officialDemoLoc
//
//  Created by Hutong on 04/09/2017.
//  Copyright © 2017 AutoNavi. All rights reserved.
//

#import "MyDocument.h"

@implementation MyDocument
// Called whenever the application reads data from the file system
- (BOOL)loadFromContents:(id)contents ofType:(NSString *)typeName error:(NSError **)outError
{
    self.dataContent = [[NSData alloc] initWithBytes:[contents bytes] length:[contents length]];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"noteModified" object:self];
    return YES;
}

// Called whenever the application (auto)saves the content of a note
- (id)contentsForType:(NSString *)typeName error:(NSError **)outError
{
    return self.dataContent;
}
@end

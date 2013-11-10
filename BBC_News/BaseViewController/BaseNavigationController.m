//
//  BaseNavigationController.m
//  BBC_News
//
//  Created by Vitalii Todorovych on 18.09.13.
//  Copyright (c) 2013 Vitalii Todorovych. All rights reserved.
//

#import "BaseNavigationController.h"

@interface BaseNavigationController ()

@end

@implementation BaseNavigationController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"vagus_logo"]];
    self.navigationItem.titleView.contentMode = UIViewContentModeScaleAspectFit;
    self.navigationController.navigationBar.translucent = NO;
}

@end

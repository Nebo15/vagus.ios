//
//  ZoomPopoverView.m
//  BBC_News
//
//  Created by Vitalii Todorovych on 17.09.13.
//  Copyright (c) 2013 Vitalii Todorovych. All rights reserved.
//

#import "ZoomPopoverView.h"

@implementation ZoomPopoverView

- (void)viewDidLoad{
    [super viewDidLoad];
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"zoom"]) {
        [self.sliderView setValue:[[NSUserDefaults standardUserDefaults] floatForKey:@"zoom"]];
    }
}

- (IBAction)valueChanged:(id)sender {
    NSNumber *value = [NSNumber numberWithFloat:((UISlider*)sender).value];
    [[NSUserDefaults standardUserDefaults] setValue:value forKey:@"zoom"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self performSelector:@selector(postNotification) withObject:nil afterDelay:.5];
}

- (void)postNotification{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"WebZoomDidChange" object:nil];
}

@end

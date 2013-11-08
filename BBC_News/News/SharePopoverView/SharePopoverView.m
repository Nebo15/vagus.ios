//
//  SharePopoverView.m
//  BBC_News
//
//  Created by Vitalii Todorovych on 18.09.13.
//  Copyright (c) 2013 Vitalii Todorovych. All rights reserved.
//

#import "SharePopoverView.h"

@interface SharePopoverView ()

@end

@implementation SharePopoverView


- (void)viewDidLoad
{
    [super viewDidLoad];
}

#pragma mark - Actions

- (IBAction)onEmail:(id)sender
{
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(showMailForm)]) {
        [self.delegate performSelector:@selector(showMailForm) withObject:nil withObject:nil];
    }
    NSLog(@"Share email");
}

- (IBAction)onTwitter:(id)sender
{
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(twitterPost)]) {
        [self.delegate performSelector:@selector(twitterPost) withObject:nil];
    }
    NSLog(@"Share twiiter");
}

- (IBAction)onFacebook:(id)sender
{
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(facebookPost)]) {
        [self.delegate performSelector:@selector(facebookPost) withObject:nil];
    }
    NSLog(@"Share facebook");
}

- (IBAction)onCopyWebLink:(id)sender
{
    NSLog(@"Share copy web link");
}

@end

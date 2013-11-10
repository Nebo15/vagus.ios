//
//  FooterView.m
//  BBC_News
//
//  Created by Vitalii Todorovych on 17.09.13.
//  Copyright (c) 2013 Vitalii Todorovych. All rights reserved.
//

#import "FooterView.h"
#import "NewsListViewController.h"

@implementation FooterView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}
- (IBAction)sendStory:(id)sender {
    [self.delegate showMailForm];
}
- (IBAction)sendPhoto:(id)sender {
    [self.delegate showPhotoPiker:sender];
}

- (IBAction)openDaleDietrichDotCom:(UIButton*)sender
{
    
    switch (sender.tag) {
        case 0:
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://vagus.tv/iletisim/"]];
            break;
        case 1:
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.bbc.co.uk/terms/"]];
            break;
        case 2:
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.bbc.co.uk/privacy"]];
            break;
            
        default:
            break;
    }
}

@end

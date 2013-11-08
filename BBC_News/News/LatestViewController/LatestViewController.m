//
//  LatestViewController.m
//  BBC_News
//
//  Created by Vitalii Todorovych on 20.09.13.
//  Copyright (c) 2013 Vitalii Todorovych. All rights reserved.
//

#import "LatestViewController.h"
#import "NSNumber+Interaction.h"
#import "TTTAttributedLabel.h"
#import "NewsListViewController.h"

@interface LatestViewController ()

@end

@implementation LatestViewController


- (void)loadData{
    if (self.dataModel) {
      //  [self.dataModel.dataStore getLatestNewsList];
    }
}

- (IBAction)latestNewsDidLoad:(id)sender {
    if (self.delegateTable) {
        [self.delegateTable showNewsDetailWithIdentifier:currentIdentifier];
    }

}

- (void)modelDidStartLoad:(id)model {
}

- (void)modelDidFinishLoad:(id)data {
    [super modelDidFinishLoad:data];
    if ([[data objectForKey:@"entries"] count] > 0) {
        items = [data objectForKey:@"entries"];
        curIndex = 0;
        [self showNews];
    }
}

- (void) showNews{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    NSString *headline;
    NSString *prompt;
    
    for (int i = curIndex; curIndex < [items count]; i++) {
        NSDictionary *itemDict = items[i];
        headline = [itemDict objectForKey:@"headline"];
        prompt = [itemDict objectForKey:@"prompt"];
        currentIdentifier = [itemDict objectForKey:@"id"];
        if (![self.delegateTable hasNewsDetailWithIdentifier:currentIdentifier]) {
            continue;
        }
        if ([headline length] > 0) {
            headline = [NSString stringWithFormat:@"%@: %@",prompt,headline];
            NSRange colorRange = [headline rangeOfString:[NSString stringWithFormat:@"%@:",prompt]];
            [self.latestNewsLabel setText:headline afterInheritingLabelAttributesAndConfiguringWithBlock:^ NSMutableAttributedString *(NSMutableAttributedString *mutableAttributedString) {
                
                [mutableAttributedString addAttribute:(NSString *) kCTForegroundColorAttributeName
                                                value:DEFAULT_COLOR
                                                range:colorRange];
                
                UIFont *boldSystemFont = [UIFont boldSystemFontOfSize:13];
                CTFontRef boldFont = CTFontCreateWithName((__bridge CFStringRef)boldSystemFont.fontName, boldSystemFont.pointSize, NULL);
                if (boldFont) {
                    [mutableAttributedString addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)boldFont range:colorRange];
                    CFRelease(boldFont);
                }
                return mutableAttributedString;
            }];
            [self.delegateTable showLatestView];
            [self.arrowIcon setHidden:NO];
            [self performSelector:@selector(showNews) withObject:nil afterDelay:10];
            curIndex++;
            return;
        }
    }
//    [self.delegateTable hideLatestView];
    [self.arrowIcon setHidden:YES];
    [self loadData];
}

@end

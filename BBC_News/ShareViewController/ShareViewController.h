//
//  ShareViewController.h
//  BBC_News
//
//  Created by Vitalii Todorovych on 21.05.13.
//  Copyright (c) 2013 Vitalii Todorovych. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MWFeedItem;
@interface ShareViewController : UIViewController {
}

@property (unsafe_unretained) UIViewController *delegateViewController;
@property (strong, nonatomic) IBOutlet UILabel *titleLbl;
@property (strong, nonatomic) IBOutlet UILabel *bodyLbl;
@property (weak, nonatomic) IBOutlet UIButton *buyButton;

- (void)postTwitterWithTextMessage:(NSString*)textMessage;
- (void)postFacebookWithTextMessage:(NSString*)textMessage;

- (void)postTwitterItem:(MWFeedItem*)feedItem;
- (void)postFacebookItem:(MWFeedItem*)feedItem;

@end

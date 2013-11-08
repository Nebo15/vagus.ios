//
//  SharePopoverView.h
//  BBC_News
//
//  Created by Vitalii Todorovych on 18.09.13.
//  Copyright (c) 2013 Vitalii Todorovych. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SharePopoverView : UIViewController

- (IBAction)onEmail:(id)sender;
- (IBAction)onTwitter:(id)sender;
- (IBAction)onFacebook:(id)sender;
- (IBAction)onCopyWebLink:(id)sender;

@property (unsafe_unretained) id delegate;

@end

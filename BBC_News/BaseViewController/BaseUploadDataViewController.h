//
//  BaseUploadDataViewController.h
//  Bredemeijer
//
//  Created by Vitaly Todorovych on 07.11.12.
//  Copyright (c) 2012 QQQ. All rights reserved.
//

#import "BaseNavigationController.h"

@interface BaseUploadDataViewController : BaseNavigationController{
    UIControl *loadingBackgroundView;
    UILabel *loadingTitleLabel;
}

@property (strong) UIActivityIndicatorView *activitiView;

- (void)closeBackground;
- (void)interruptLoadingProcess;
- (void)hideLoading;
- (void)showBackgroundInView:(UIView*)superview animation:(BOOL)animation;
- (void)showLoadingTitleLabelWithText:(NSString*)_text;
- (UIViewAutoresizing)getGlobalViewAutoresizing;

@end

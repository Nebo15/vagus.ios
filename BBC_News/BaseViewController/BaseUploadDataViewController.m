//
//  BaseUploadDataViewController.m
//  Bredemeijer
//
//  Created by Vitaly Todorovych on 07.11.12.
//  Copyright (c) 2012 QQQ. All rights reserved.
//

#import "BaseUploadDataViewController.h"

@interface BaseUploadDataViewController ()

- (void)showActivityIndicator;
- (void)updatePositionForActivityIndicator;

@end

@implementation BaseUploadDataViewController

- (void)dealloc
{
    [loadingBackgroundView removeFromSuperview];
    loadingBackgroundView = nil;
    [loadingTitleLabel removeFromSuperview];
    loadingTitleLabel = nil;
    [self.activitiView removeFromSuperview];
    self.activitiView = nil;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        loadingBackgroundView = [[UIControl alloc] init];
    }
    return self;
}

- (void)viewDidUnload{
    [loadingBackgroundView removeFromSuperview];
    loadingBackgroundView = nil;
    [loadingTitleLabel removeFromSuperview];
    loadingTitleLabel = nil;
    [self.activitiView removeFromSuperview];
    self.activitiView = nil;
    [super viewDidUnload];
}

- (void)interruptLoadingProcess{
    [self closeBackground];
}

- (void)closeBackground{
    [loadingBackgroundView setHidden:YES];
}

-(CGRect)getScreenBoundsForCurrentOrientation {
//#warning
    UIScreen *screen = [UIScreen mainScreen];
    CGRect fullScreenRect = screen.bounds;
    return fullScreenRect;
//     return [self getScreenBoundsForOrientation:[UIApplication sharedApplication].statusBarOrientation]; 
}

-(CGRect)getScreenBoundsForOrientation:(UIInterfaceOrientation)orientation {
    
    UIScreen *screen = [UIScreen mainScreen];
    CGRect fullScreenRect = screen.bounds; //implicitly in Portrait orientation.
    
    if(orientation == UIInterfaceOrientationLandscapeRight || orientation ==  UIInterfaceOrientationLandscapeLeft){
        CGRect temp = CGRectZero;
        temp.size.width = fullScreenRect.size.height;
        temp.size.height = fullScreenRect.size.width;
        fullScreenRect = temp;
    }
    
    return fullScreenRect;
}

- (void)showBackgroundInView:(UIView*)superview animation:(BOOL)animation{
    if (!loadingBackgroundView) {
        loadingBackgroundView = [[UIControl alloc] init];
    }
//    [loadingBackgroundView addTarget:self action:@selector(interruptLoadingProcess) forControlEvents:UIControlEventTouchUpInside];
    CGRect screenRect = [self getScreenBoundsForCurrentOrientation];
    [loadingBackgroundView setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:.0]];
    dispatch_async(dispatch_get_main_queue(), ^{
        [superview addSubview:loadingBackgroundView];
    });
    [loadingBackgroundView setFrame:CGRectMake(0.0, 0.0, screenRect.size.width,screenRect.size.height)];
    [loadingBackgroundView setHidden:YES];
//    if (animation) {
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [self showActivityIndicator];
//        });
//    }
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    
    [loadingBackgroundView setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:.5]];
    [loadingBackgroundView setHidden:NO];
    loadingBackgroundView.autoresizingMask = [self getGlobalViewAutoresizing];
    
    [UIView commitAnimations];
}

- (void)showActivityIndicator{
    if (!self.activitiView) {
        self.activitiView = [[UIActivityIndicatorView alloc] init];
    }
    [self updatePositionForActivityIndicator];
    [self.activitiView setHidden:NO];
    [self.activitiView startAnimating];
    [loadingBackgroundView addSubview:self.activitiView];
    self.activitiView.autoresizingMask = [self getGlobalViewAutoresizing];
}

- (void)updatePositionForActivityIndicator{
    if (self.activitiView) {
        CGRect screenRect = [self getScreenBoundsForCurrentOrientation];
        CGFloat screenWidth = screenRect.size.width;
        CGFloat screenHeight = screenRect.size.height;
        if (loadingTitleLabel) {
            [self.activitiView setFrame:CGRectMake(screenWidth/2 - 18, screenHeight/2 - 37 - ((loadingTitleLabel)?loadingTitleLabel.frame.size.height:0.0f), 37, 37)];
        }else{
            [self.activitiView setFrame:CGRectMake(screenWidth/2 - 18, screenHeight/2 - 37 - 0.0f, 37, 37)];
        }
        self.activitiView.autoresizingMask = [self getGlobalViewAutoresizing];
    }
    
}

- (void)showLoadingTitleLabelWithText:(NSString*)_text{
    if (!loadingTitleLabel) {
        loadingTitleLabel = [[UILabel alloc] init];
    }
    [loadingBackgroundView insertSubview:loadingTitleLabel aboveSubview:loadingBackgroundView];
    [loadingTitleLabel setFrame:CGRectMake(10.0, loadingBackgroundView.frame.size.height/2-20, loadingBackgroundView.frame.size.width-20,20)];
    [loadingTitleLabel setBackgroundColor:[UIColor clearColor]];
    [loadingTitleLabel setTextColor:[UIColor whiteColor]];
    [loadingTitleLabel setTextAlignment:NSTextAlignmentCenter];
    [loadingTitleLabel setHidden:YES];
    if (_text) {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.3];
        
        [loadingTitleLabel setText:_text];
        [loadingTitleLabel setHidden:NO];
        [self updatePositionForActivityIndicator];
        
        [UIView commitAnimations];
    }
    loadingTitleLabel.autoresizingMask = [self getGlobalViewAutoresizing];
}

- (UIViewAutoresizing)getGlobalViewAutoresizing{
    return (UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
}

- (void)showLoading{
    [self showBackgroundInView:self.view animation:YES];
}

- (void)hideLoading{
    [self closeBackground];
}

@end

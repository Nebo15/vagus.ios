//
//  ShareViewController.m
//  BBC_News
//
//  Created by Vitalii Todorovych on 21.05.13.
//  Copyright (c) 2013 Vitalii Todorovych. All rights reserved.
//

#import "ShareViewController.h"

#import <Social/Social.h>
#import <Social/SLComposeViewController.h>
#import "MWFeedItem.h"

@interface ShareViewController ()

@end

@implementation ShareViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (IBAction)showFeedbackMailView{
}

- (void)postTwitterWithTextMessage:(NSString*)textMessage
{
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
    {
        SLComposeViewController *tweetSheet = [SLComposeViewController
                                               composeViewControllerForServiceType:SLServiceTypeTwitter];
        [tweetSheet setInitialText:textMessage];
        [self presentViewController:tweetSheet animated:YES completion:nil];
    }
    else
    {
        //Error alert  
    }  
}

- (void)postTwitterItem:(MWFeedItem*)feedItem
{
    //  Create an instance of the Tweet Sheet
    SLComposeViewController *tweetSheet = [SLComposeViewController
                                           composeViewControllerForServiceType:
                                           SLServiceTypeTwitter];
    
    // Sets the completion handler.  Note that we don't know which thread the
    // block will be called on, so we need to ensure that any UI updates occur
    // on the main queue
    tweetSheet.completionHandler = ^(SLComposeViewControllerResult result) {
        switch(result) {
                //  This means the user cancelled without sending the Tweet
            case SLComposeViewControllerResultCancelled:
                break;
                //  This means the user hit 'Send'
            case SLComposeViewControllerResultDone:
                break;
        }
        
        //  dismiss the Tweet Sheet
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegateViewController dismissViewControllerAnimated:NO completion:^{
                NSLog(@"Tweet Sheet has been dismissed.");
            }];
        });
    };
    
    //  Set the initial body of the Tweet
    [tweetSheet setInitialText:feedItem.title];
    
    //  Adds an image to the Tweet.  For demo purposes, assume we have an
    //  image named 'larry.png' that we wish to attach
    if (![tweetSheet addImage:[UIImage imageNamed:@"BBC News icon"]]) {
        NSLog(@"Unable to add the image!");
    }
    
    //  Add an URL to the Tweet.  You can add multiple URLs.
    if (![tweetSheet addURL:[NSURL URLWithString:feedItem.link]]){
        NSLog(@"Unable to add the URL!");
    }
    
    //  Presents the Tweet Sheet to the user
//    [self presentViewController:tweetSheet animated:NO completion:^{
//        NSLog(@"Tweet sheet has been presented.");
//    }];
    
    [self.delegateViewController presentViewController:tweetSheet animated:YES completion:nil];
}

- (void)postFacebookWithTextMessage:(NSString*)textMessage{
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook])
    {
        SLComposeViewController *tweetSheet = [SLComposeViewController
                                               composeViewControllerForServiceType:SLServiceTypeFacebook];
        [tweetSheet setInitialText:textMessage];
        [((UIViewController*)self.delegateViewController) presentViewController:tweetSheet animated:YES completion:nil];
    }
    else
    {
        //Error alert
    }
}

- (void)postFacebookItem:(MWFeedItem*)feedItem
{
    //  Create an instance of the Tweet Sheet
    SLComposeViewController *tweetSheet = [SLComposeViewController
                                           composeViewControllerForServiceType:
                                           SLServiceTypeFacebook];
    
    // Sets the completion handler.  Note that we don't know which thread the
    // block will be called on, so we need to ensure that any UI updates occur
    // on the main queue
    tweetSheet.completionHandler = ^(SLComposeViewControllerResult result) {
        switch(result) {
                //  This means the user cancelled without sending the Tweet
            case SLComposeViewControllerResultCancelled:
                break;
                //  This means the user hit 'Send'
            case SLComposeViewControllerResultDone:
                break;
        }
        
        //  dismiss the Tweet Sheet
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegateViewController dismissViewControllerAnimated:NO completion:^{
                NSLog(@"Tweet Sheet has been dismissed.");
            }];
        });
    };
    
    //  Set the initial body of the Tweet
    [tweetSheet setInitialText:feedItem.title];
    
    //  Adds an image to the Tweet.  For demo purposes, assume we have an
    //  image named 'larry.png' that we wish to attach
    if (![tweetSheet addImage:[UIImage imageNamed:@"BBC News icon"]]) {
        NSLog(@"Unable to add the image!");
    }
    
    //  Add an URL to the Tweet.  You can add multiple URLs.
    if (![tweetSheet addURL:[NSURL URLWithString:feedItem.link]]){
        NSLog(@"Unable to add the URL!");
    }
    
    //  Presents the Tweet Sheet to the user
//    [self presentViewController:tweetSheet animated:NO completion:^{
//        NSLog(@"Tweet sheet has been presented.");
//    }];
    
    [self.delegateViewController presentViewController:tweetSheet animated:YES completion:nil];
}

- (void)viewDidUnload {
    [self setTitleLbl:nil];
    [self setBodyLbl:nil];
    [self setBuyButton:nil];
    [super viewDidUnload];
}
@end

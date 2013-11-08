//
//  AppDelegate.h
//  BBC_News
//
//  Created by Vitalii Todorovych on 15.09.13.
//  Copyright (c) 2013 Vitalii Todorovych. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AudioPlayerView.h"
#import <MediaPlayer/MediaPlayer.h>

@class NewsListViewController;

@interface AppDelegate : UIResponder <
UIApplicationDelegate,
AudioPlayerViewDelegate>
{
	AudioPlayer* audioPlayer;
    BOOL playing;
}

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) NewsListViewController *viewController;
@property (nonatomic, strong) IBOutlet UINavigationController   *rootNavigationController;

+ (AppDelegate *) sharedDelegate;
+ (BOOL)isRoaming;
+ (BOOL)isNetwork;
- (BOOL)isRadioPlaying;
- (void)playRadio;
- (void)stopRadio;

@end
//
//  AppDelegate.m
//  BBC_News
//
//  Created by Vitalii Todorovych on 15.09.13.
//  Copyright (c) 2013 Vitalii Todorovych. All rights reserved.
//

#import "AppDelegate.h"
#import "Reachability.h"
#import "NewsListViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import "TestFlight.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

    self.viewController = [[NewsListViewController alloc] initWithNibName:@"NewsListViewController" bundle:nil];
    self.rootNavigationController = [[UINavigationController alloc] initWithRootViewController:self.viewController];
    [self.rootNavigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"top-bar-color"] forBarMetrics:UIBarMetricsDefault];
    [TestFlight takeOff:@"a6341102-faf4-4dfc-8fc2-289e20d7e0fb"];
    
    self.window.rootViewController = self.rootNavigationController;
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ApplicationDidEnterBackground" object:nil];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
//    [self stopVideo];
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}

+ (AppDelegate*) sharedDelegate
{
	return (AppDelegate*)[[UIApplication sharedApplication] delegate];
}

#pragma mark Network functions

+ (BOOL) isNetwork{
    // return NO;
    Reachability *hostReach = [Reachability reachabilityForInternetConnection];
	NetworkStatus netStatus = [hostReach currentReachabilityStatus];
	
	if (netStatus == NotReachable) {
		return NO;
	}
    return YES;
}


+ (BOOL)isRoaming
{
    Reachability *hostReach = [Reachability reachabilityForInternetConnection];
	NetworkStatus netStatus = [hostReach currentReachabilityStatus];
	if (netStatus == ReachableViaWiFi) {
        return NO;
	}
    static NSString *carrierPListSymLinkPath = @"/var/mobile/Library/Preferences/com.apple.carrier.plist";
    static NSString *operatorPListSymLinkPath = @"/var/mobile/Library/Preferences/com.apple.operator.plist";
    
    NSFileManager *fm = [NSFileManager defaultManager];
    NSError *error;
    NSString *carrierPListPath = [fm destinationOfSymbolicLinkAtPath:carrierPListSymLinkPath error:&error];
    NSString *operatorPListPath = [fm destinationOfSymbolicLinkAtPath:operatorPListSymLinkPath error:&error];
    return (![operatorPListPath isEqualToString:carrierPListPath]);
}

@end

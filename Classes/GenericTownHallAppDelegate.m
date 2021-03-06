//
//  GenericTownHallAppDelegate.m
//  GenericTownHall  (TownHall iPad)
//
//  Created by David Ang and Steven Talcott Smith, AELOGICA LLC
//  Copyright 2010 Microsoft
//
//  This software is released under the Microsoft Public License
//  Please see the LICENSE file for details
//


#import "GenericTownHallAppDelegate.h"

#import "SplashViewController.h"
#import "RootViewController.h"
#import "DetailViewController.h"
#import "MBProgressHUD.h"
#import "globals.h"
#import "SplashViewController.h"
#import "Facebook.h"

@implementation GenericTownHallAppDelegate

@synthesize window, splitViewController, rootViewController, detailViewController, progressHUD, serverBaseUrl, serverDataUrl, serverApiKey, splashViewController;
@synthesize currentOrientation, appWidth, appHeight, isLogin, currentView, currentBarButtonTitle, currentSlug;
@synthesize fbApiKey, fbSecretKey, fbUser, facebook;

#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    
    // Override point for customization after app launch.
	NSLog(@"Application started.");
	
	// Set to default landscape width/height
	appWidth = 703.f;
	appHeight = 748.f;	
	isLogin = NO;
	
	[[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
	UIInterfaceOrientation orientation = [[UIDevice currentDevice] orientation];
	switch (orientation) {
        case UIInterfaceOrientationPortrait:		
        case UIInterfaceOrientationPortraitUpsideDown:
			appWidth = 768.f;
			appHeight = 1004.f;
			break;
		case UIInterfaceOrientationLandscapeLeft:
		case UIInterfaceOrientationLandscapeRight:
			appWidth = 703.f;
			appHeight = 748.f;
			break;
		default:
			NSLog(@"Orientation not detected");
			break;
    }
	
	NSBundle *bundle = [NSBundle mainBundle];
	NSString *plistPath = [bundle pathForResource:@"configs" ofType:@"plist"];
	NSDictionary *plistData = [[NSDictionary dictionaryWithContentsOfFile:plistPath] retain];
	
	serverBaseUrl = [plistData objectForKey:@"ServerBaseUrl"];
	serverDataUrl = [plistData objectForKey:@"ServerDataUrl"];
	serverApiKey = [plistData objectForKey:@"ServerApiKey"];	
	fbApiKey = [plistData objectForKey:@"FbApiKey"];	
	fbSecretKey = [plistData objectForKey:@"FbSecretKey"];		
	NSLog(@"Server Base URL set to: %@ Data URL set to: %@", serverBaseUrl, serverDataUrl);
	
	facebook = [[Facebook alloc] initWithAppId: [plistData objectForKey:@"FbAppId"]];
    
    // Add the split view controller's view to the window and display.
	splashViewController = [[SplashViewController alloc] init];
	splashViewController.view.center = window.center;
	//splitViewController.view.alpha = 0.0;
    [window addSubview:splitViewController.view];
	//[window addSubview:splashViewController.view];
    [window makeKeyAndVisible];
	
	progressHUD = [[MBProgressHUD alloc] initWithWindow: window];
	progressHUD.delegate = self;
	[window addSubview:progressHUD];
	progressHUD.center = CGPointMake(384,512);		
 
	//[NSTimer scheduledTimerWithTimeInterval:2.5f target: self selector:@selector(fadeScreen) userInfo: nil repeats: NO];
	
	//[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillTerminate:) name:UIApplicationWillTerminateNotification object:nil];	

    return YES;
}

-(void) fadeScreen {
	[UIView beginAnimations: nil context: nil];
	[UIView setAnimationDuration: 0.75];
	[UIView setAnimationDelegate: self];
	[UIView setAnimationDidStopSelector:@selector(finishedFading)];
	splashViewController.view.alpha = 0.0;
	[UIView commitAnimations];
}

-(void) finishedFading {
	[UIView beginAnimations: nil context: nil];
	[UIView setAnimationDuration: 0.5];
	//self.view.alpha = 1.0;
	splitViewController.view.alpha = 1.0;
	[UIView commitAnimations];
	//[splashImageView removeFromSuperview];	
}


-(void) hudWasHidden {
	// do nothing
}

- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
	NSLog(@"applicationWillResignActive");
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive.
     */
}


- (void)applicationWillTerminate:(UIApplication *)application {
    /*
     Called when the application is about to terminate.
     */
	NSLog(@"applicationWillTerminate");
}


#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}


- (void)dealloc {
	[progressHUD removeFromSuperview];
	[progressHUD release];
	[splashViewController release];	
    [splitViewController release];
    [window release];
    [super dealloc];
}

CGFloat DegreesToRadians(CGFloat degrees)
{
	return degrees * M_PI / 180;
};


@end


//
//  AppDelegate.m
//  Billfold
//
//  Created by Abhishek on 28/11/15.
//  Copyright © 2015 synerzip. All rights reserved.
//

#import "Stripe.h"
#import "Constant.h"
#import "AppDelegate.h"

NSString * const StripePublishableKey = @"pk_test_I2iJjDijZFk42B48uXzM8Gr7";

@interface AppDelegate ()<BFHTTPClientDelegate>

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [Stripe setDefaultPublishableKey:StripePublishableKey];
    [self updateBillfoldVerificationCode];
    return YES;
}

-(void) updateBillfoldVerificationCode
{
    
    BFHTTPClient *client = [BFHTTPClient sharedBFHTTPClient];
    client.delegate = self;
    
    [SVProgressHUD show];
    NSString *userID = [[NSUserDefaults standardUserDefaults] valueForKey:@"UserID"];
    
    if (userID != nil)
    {
        [client updatedBVCForUserID:userID completion:^(BOOL success, id response, NSError *error) {
            if (error)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [SVProgressHUD dismiss];
                    @autoreleasepool
                    {
                        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Error" message:error.localizedDescription delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
                        [alert show];
                    }
                });
            }
            else
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [SVProgressHUD dismiss];
                    [[NSUserDefaults standardUserDefaults] setValue:[response stringValue] forKey:@"BVC"];
                });
                
            }
        }];
    }
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - BFHTTPClientDelegate Method

-(void)bfHTTPClient:(BFHTTPClient *)client didFailWithError:(NSError *)error
{
    
}

@end

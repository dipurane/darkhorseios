//
//  FirstViewController.m
//  Billfold
//
//  Created by Abhishek on 28/11/15.
//  Copyright © 2015 synerzip. All rights reserved.
//

#import "Constant.h"
#import "FirstViewController.h"

@interface FirstViewController ()

@end

@implementation FirstViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    NSString *userID = [[NSUserDefaults standardUserDefaults] valueForKey:@"UserID"];
    if (userID == nil)
    {
        // Open registration view for user.
        [self registerUser];
    }
}

-(void) registerUser
{
    UIStoryboard *mystoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    RegistrationFirstStepViewController *firstStepViewController = [mystoryboard instantiateViewControllerWithIdentifier:@"RegistrationFirstStepViewController"];
    
    [self presentViewController:firstStepViewController animated:NO completion:nil];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end

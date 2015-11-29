//
//  UserDetailsViewController.m
//  Billfold
//
//  Created by Abhishek on 28/11/15.
//  Copyright © 2015 synerzip. All rights reserved.
//

#import "Constant.h"
#import "UserDetailsViewController.h"

@interface UserDetailsViewController ()<BFHTTPClientDelegate>

@property (weak, nonatomic) IBOutlet UITextField *tfFirstName;
@property (weak, nonatomic) IBOutlet UITextField *tfLastName;
@property (weak, nonatomic) IBOutlet UITextField *tfEmailAddress;

- (IBAction)registerButttonPressed:(UIButton *)sender;

@end

@implementation UserDetailsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

-(BOOL) isValidEmail:(NSString *)checkString
{
    BOOL stricterFilter = NO; // Discussion http://blog.logichigh.com/2010/09/02/validating-an-e-mail-address/
    NSString *stricterFilterString = @"^[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}$";
    NSString *laxString = @"^.+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*$";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:checkString];
}

-(void) showAlertWithErrorMessage:(NSString *)errorMessage
{
    @autoreleasepool
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:errorMessage delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        [alert show];
    }
}

- (IBAction)registerButttonPressed:(UIButton *)sender
{
    if (self.tfFirstName.text.length >0 && self.tfLastName.text.length > 0 && [self isValidEmail:self.tfEmailAddress.text])
    {
        [SVProgressHUD show];
        
        // All data entered correctly.
        BFHTTPClient *client = [BFHTTPClient sharedBFHTTPClient];
        client.delegate = self;
        //Use a weak variable for self within the blocks
        __weak typeof(self) weakSelf = self;

        [client registerUserWithMobileNumber:self.mobileNumber firstName:self.tfFirstName.text lastName:self.tfLastName.text emailAddress:self.tfEmailAddress.text completion:^(BOOL success, id response, NSError *error)
        {
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
                // Success.
                [[NSUserDefaults standardUserDefaults] setValue:response[@"id"] forKey:@"UserID"];
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"UserRegistrationCompleted"];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [SVProgressHUD dismiss];
                    [[[weakSelf presentingViewController] presentingViewController] dismissViewControllerAnimated:NO completion:nil];
                });
            }
        }];
        
    }
    else if([self isValidEmail:self.tfEmailAddress.text] == NO)
    {
        [self showAlertWithErrorMessage:@"Please enter valid email address."];
    }
    else if (self.tfFirstName.text.length == 0)
    {
        [self showAlertWithErrorMessage:@"Please enter first name."];
    }
    else
    {
        // Last name enter in-correctly.
        [self showAlertWithErrorMessage:@"Please enter last name."];
    }
}

#pragma mark- BFHTTPClientDelegate Method

-(void)bfHTTPClient:(BFHTTPClient *)client didFailWithError:(NSError *)error
{
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end

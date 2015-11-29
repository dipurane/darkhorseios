//
//  CodeVerificationViewController.m
//  Billfold
//
//  Created by Abhishek on 28/11/15.
//  Copyright © 2015 synerzip. All rights reserved.
//

#import "Constant.h"
#import "CodeVerificationViewController.h"

NSInteger codelimit = 3;

@interface CodeVerificationViewController ()<UITextFieldDelegate, BFHTTPClientDelegate>
{
    BOOL isRequestCompleted;
}
@property (weak, nonatomic) IBOutlet UILabel *lblMobileNumber;
@property (weak, nonatomic) IBOutlet UITextField *tfVerificationCode;

- (IBAction)nextButtonPressed:(UIButton *)sender;
-(IBAction)resendButtonPressed:(id)sender;

@end

@implementation CodeVerificationViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tfVerificationCode.delegate = self;
    self.lblMobileNumber.text = self.mobileNumber;
    
    isRequestCompleted = NO;
}


#pragma mark- UITextFieldDelegate Method

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    self.tfVerificationCode.text = @"";
    return YES;
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    return !([textField.text length]>codelimit && [string length] > range.length);
}

- (IBAction)nextButtonPressed:(UIButton *)sender
{
    if (self.tfVerificationCode.text.length == codelimit+1)
    {
        [SVProgressHUD show];
        BFHTTPClient *client = [BFHTTPClient sharedBFHTTPClient];
        client.delegate = self;
        [self.view endEditing:YES];
        //Use a weak variable for self within the blocks
        __weak typeof(self) weakSelf = self;

        [client authenticateUserMobileNumber:self.mobileNumber withVerificationCode:self.tfVerificationCode.text completion:^(BOOL success, id response, NSError *error)
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

                dispatch_async(dispatch_get_main_queue(), ^{
                    [SVProgressHUD dismiss];
                    // Success.
                    [weakSelf performSegueWithIdentifier:@"UserDetails" sender:self];
                });
            }
            
        }];
    }
    else
    {
        // Wrong code entered.
        @autoreleasepool
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Please enter 4-digit verification code." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
            [alert show];
        }
    }
}

-(IBAction)resendButtonPressed:(id)sender
{
    [SVProgressHUD show];
    BFHTTPClient *client = [BFHTTPClient sharedBFHTTPClient];
    client.delegate = self;

    [client authenticateUserMobileNumber:self.mobileNumber completion:^(BOOL success, id response, NSError *error) {
        
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
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [SVProgressHUD dismiss];
                @autoreleasepool
                {
                    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Success" message:@"Verification code has been sent." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
                    [alert show];
                }
            });

        }
    }];
}

#pragma mark- BFHTTPClientDelegate Method

-(void)bfHTTPClient:(BFHTTPClient *)client didFailWithError:(NSError *)error
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


#pragma mark - Navigation

-(BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    return (isRequestCompleted)? YES: NO;
}


// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    UserDetailsViewController *userDetailViewController = segue.destinationViewController;
    userDetailViewController.mobileNumber = self.mobileNumber;
}
@end

//
//  RaisedInvoiceViewController.m
//  Billfold
//
//  Created by Abhishek on 28/11/15.
//  Copyright © 2015 synerzip. All rights reserved.
//

#import "Constant.h"
#import "RaisedInvoiceViewController.h"

NSInteger phoneNumberLimit = 9;
NSInteger bvcCodeLimit = 2;

@interface RaisedInvoiceViewController ()<UITextFieldDelegate, BFHTTPClientDelegate, UIAlertViewDelegate>
{
   __block NSTimer *pingTimer;
    __block NSString *invoiceID;
}
@property (weak, nonatomic) IBOutlet UIScrollView *formScrollView;
@property (weak, nonatomic) IBOutlet UITextField *tfPhoneNumber;
@property (weak, nonatomic) IBOutlet UITextField *tfBVC;
@property (weak, nonatomic) IBOutlet UITextField *tfAmount;
@property (weak, nonatomic) IBOutlet UITextView *tvDescription;

- (IBAction)raisedInvoiceButtonPressed:(UIButton *)sender;
- (IBAction)cancelButtonPressed:(UIButton *)sender;
@end

@implementation RaisedInvoiceViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tvDescription.layer.borderWidth = 1.0f;
    self.tvDescription.layer.borderColor = [[UIColor blackColor] CGColor];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [self.formScrollView setContentSize:CGSizeMake(320, 720)];
}

#pragma mark- UITextField Delegate Methods.

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    BOOL shouldChangeInCharacter = NO;
    
    if (textField == self.tfPhoneNumber)
    {
        shouldChangeInCharacter = !([textField.text length]>phoneNumberLimit && [string length] > range.length);
    }
    else if (textField == self.tfBVC)
    {
        shouldChangeInCharacter = !([textField.text length]>bvcCodeLimit && [string length] > range.length);
    }
    else
    {
        shouldChangeInCharacter = YES;
    }
    return shouldChangeInCharacter;
}

#pragma mark - Action Handlers

- (IBAction)raisedInvoiceButtonPressed:(UIButton *)sender
{
    if (self.tfPhoneNumber.text.length == phoneNumberLimit+1 && self.tfBVC.text.length == bvcCodeLimit+1 && self.tfAmount.text.length >0 && self.tvDescription.text.length > 0)
    {
        // Raise invoice now.
        [self.view endEditing:YES];
        [SVProgressHUD show];
        
        
        BFHTTPClient *client = [BFHTTPClient sharedBFHTTPClient];
        client.delegate = self;
        NSString *userID = [[NSUserDefaults standardUserDefaults] valueForKey:@"UserID"];
        
        //Use a weak variable for self within the blocks
        __weak typeof(self) weakSelf = self;

        [client raiseInvoiceWithPayerPhoneNumber:self.tfPhoneNumber.text payerBVCCode:self.tfBVC.text amount:self.tfAmount.text description:self.tvDescription.text fromUserID:userID completion:^(BOOL success, id response, NSError *error)
        {
            if (error)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [SVProgressHUD dismiss];
                    @autoreleasepool
                    {
                        
                        if ([error.localizedDescription rangeOfString:@"409"].location != NSNotFound)
                        {
                            // Contain 409.
                            [weakSelf showAlertWithErrorMessage:@"Payer already have open transactions."];
                        }
                        else if ([error.localizedDescription rangeOfString:@"406"].location != NSNotFound)
                        {
                            [weakSelf showAlertWithErrorMessage:@"Internal server error. Please try again later."];
                        }
                        else if ([error.localizedDescription rangeOfString:@"412"].location != NSNotFound)
                        {
                            [weakSelf showAlertWithErrorMessage:@"Please enter valid BVC."];
                        }
                        else
                        {
                            [weakSelf showAlertWithErrorMessage:error.localizedDescription];
                        }
                    }
                });
            }
            else
            {
                // Success.
                dispatch_async(dispatch_get_main_queue(), ^{
                    [SVProgressHUD dismiss];
                    // Success.
//                    [[weakSelf presentingViewController] dismissViewControllerAnimated:NO completion:nil];
                    [SVProgressHUD showWithStatus:@"Waiting for payer approval."];
                    invoiceID = [response[@"id"] stringValue];
                    pingTimer = [NSTimer scheduledTimerWithTimeInterval: 5.0 target: self
                                                             selector: @selector(checkForInvoiceStatus) userInfo: nil repeats: YES];
                });
            }
        }];
    }
    else if (self.tfPhoneNumber.text.length != phoneNumberLimit+1)
    {
        [self showAlertWithErrorMessage:@"Please enter valid phone number."];
    }
    else if (self.tfBVC.text.length != bvcCodeLimit+1)
    {
        [self showAlertWithErrorMessage:@"Please enter valid BVC."];
    }
    else if (self.tfAmount.text.length == 0)
    {
        [self showAlertWithErrorMessage:@"Please enter atleast some amount."];
    }
    else
    {
        [self showAlertWithErrorMessage:@"Please add some description."];
    }
}

-(void) showAlertWithErrorMessage:(NSString *)errorMessage
{
    @autoreleasepool
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:errorMessage delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        [alert show];
    }
}

-(void) checkForInvoiceStatus
{
    BFHTTPClient *client = [BFHTTPClient sharedBFHTTPClient];
    client.delegate = self;
    NSString *userID = [[NSUserDefaults standardUserDefaults] valueForKey:@"UserID"];
    //Use a weak variable for self within the blocks
    __weak typeof(self) weakSelf = self;

    [client checkStatusOfInvoice:invoiceID andUserID:userID completion:^(BOOL success, id response, NSError *error)
    {
        if (error)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [SVProgressHUD dismiss];
                @autoreleasepool {
                    [weakSelf showAlertWithErrorMessage:@"Transaction failed."];
                    [pingTimer invalidate];
                }
            });
        }
        else
        {
            if (![response[@"status"] isEqualToString:@"OPEN"])
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [pingTimer invalidate];
                    [SVProgressHUD dismiss];
                    @autoreleasepool
                    {
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Transaction Completed Successfully." delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
                        [alert show];
                    }
                });
            }
        }
    }];
}

- (IBAction)cancelButtonPressed:(UIButton *)sender
{
    [[self presentingViewController] dismissViewControllerAnimated:NO completion:nil];
}

#pragma mark- UIAlertViewDelegate Method

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [[self presentingViewController] dismissViewControllerAnimated:NO completion:nil];
}

#pragma mark - BFHTTPClientDelegate Method

-(void)bfHTTPClient:(BFHTTPClient *)client didFailWithError:(NSError *)error
{
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

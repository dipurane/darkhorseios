//
//  RegistrationFirstStepViewController.m
//  Billfold
//
//  Created by Abhishek on 28/11/15.
//  Copyright © 2015 synerzip. All rights reserved.
//

#import "Constant.h"
#import "RegistrationFirstStepViewController.h"

NSInteger limit = 9;

@interface RegistrationFirstStepViewController ()<UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource, BFHTTPClientDelegate>
{
    NSArray *countryArray;
    NSArray *countryCodeArray;
    BOOL isRequestCompleted;
}

@property (weak, nonatomic) IBOutlet UITextField *tfMobileNumber;
@property (weak, nonatomic) IBOutlet UITextField *tfCountryCode;
@property (weak, nonatomic) IBOutlet UITextField *tfSelectYourCountry;
@property (weak, nonatomic) IBOutlet UIPickerView *countryPickerView;
@property (weak, nonatomic) IBOutlet UIToolbar *pickerToolBar;

- (IBAction)nextButtonPressed:(id)sender;
- (IBAction)selectCountryButtonPressed:(id)sender;
- (IBAction)pickerDoneButtonPressed:(id)sender;
@end

@implementation RegistrationFirstStepViewController

#pragma mark View Life Cycle.

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tfMobileNumber.delegate = self;
    
    countryArray = [NSArray arrayWithObjects:@"India", @"Kenya", @"Germany", @"SriLanka", @"Nepal", nil];
    countryCodeArray = [NSArray arrayWithObjects:@"+91", @"+254", @"+49", @"+94", @"+977", nil];
    
    self.tfCountryCode.userInteractionEnabled = NO;
    
    self.pickerToolBar.hidden = YES;
    self.countryPickerView.hidden = YES;
    self.countryPickerView.delegate = self;
    self.countryPickerView.dataSource = self;
    isRequestCompleted = NO;
    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dismissViewControllerAfterSuccessFullRegistration) name:@"DismissView" object:nil];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"UserRegistrationCompleted"] == YES)
    {
        [self dismissViewControllerAfterSuccessFullRegistration];
    }
}

#pragma mark Action Handlers.

- (IBAction)nextButtonPressed:(id)sender
{
    BFHTTPClient *client = [BFHTTPClient sharedBFHTTPClient];
    client.delegate = self;

    if (self.tfMobileNumber.text.length < 9)
    {
        @autoreleasepool
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Please enter valid mobile number." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
            [alert show];
        }
    }
    else
    {
        [self.view endEditing:YES];
        
        [SVProgressHUD show];
        //Use a weak variable for self within the blocks
        __weak typeof(self) weakSelf = self;

        [client authenticateUserMobileNumber:self.tfMobileNumber.text completion:^(BOOL success, id response, NSError *error) {
            
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
                    // Success.
                    [weakSelf performSegueWithIdentifier:@"VerifyCode" sender:self];
                });
            }
        }];
    }
}

#pragma mark UITextField Delegate Method

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    BOOL isCountrySelected = YES;
    if (self.tfCountryCode.text.length == 0)
    {
        isCountrySelected = NO;
        @autoreleasepool
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Please select country first." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
            [alert show];
        }
    }
    return isCountrySelected;
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    return !([textField.text length]>limit && [string length] > range.length);
}

#pragma mark - ActionHandlers

- (IBAction)selectCountryButtonPressed:(id)sender
{
    self.countryPickerView.hidden = NO;
    self.pickerToolBar.hidden = NO;
}

- (IBAction)pickerDoneButtonPressed:(id)sender
{
    self.countryPickerView.hidden = YES;
    self.pickerToolBar.hidden = YES;
    NSInteger row = [self.countryPickerView selectedRowInComponent:0];
    
    self.tfSelectYourCountry.text = countryArray[row];
    self.tfCountryCode.text = countryCodeArray[row];
}

#pragma mark- UIPickerViewDataSource Method

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return countryArray.count;
}

- (nullable NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return countryArray[row];
}

#pragma mark - UIPickerViewDelegate Method

// Catpure the picker view selection
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    self.tfCountryCode.text = countryCodeArray[row];
    self.tfSelectYourCountry.text = countryArray[row];
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
    CodeVerificationViewController *codeViewController = segue.destinationViewController;
    codeViewController.mobileNumber = self.tfMobileNumber.text;
}

#pragma mark- BFHTTPClientDelegate Method

-(void)bfHTTPClient:(BFHTTPClient *)client didFailWithError:(NSError *)error
{
    
}

-(void) dismissViewControllerAfterSuccessFullRegistration
{
    dispatch_async(dispatch_get_main_queue(), ^{
        UITabBarController *tbc = [self.storyboard instantiateViewControllerWithIdentifier:@"TabBar"];
        tbc.selectedIndex=0;
        [self presentViewController:tbc animated:YES completion:nil];
    });
}

@end

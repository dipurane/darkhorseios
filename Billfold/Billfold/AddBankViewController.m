//
//  AddBankViewController.m
//  Billfold
//
//  Created by Abhishek on 29/11/15.
//  Copyright © 2015 synerzip. All rights reserved.
//

#import "Constant.h"
#import "AddBankViewController.h"

@interface AddBankViewController ()<BFHTTPClientDelegate, UIAlertViewDelegate>
{
    NSDate *selectedDate;
}
@property (weak, nonatomic) IBOutlet UITextField *tfBankName;
@property (weak, nonatomic) IBOutlet UITextField *tfAccountNumber;
@property (weak, nonatomic) IBOutlet UITextField *tfRoutingNumber;
@property (weak, nonatomic) IBOutlet UITextField *tfBirthDate;
@property (weak, nonatomic) IBOutlet UITextField *tfLine1;
@property (weak, nonatomic) IBOutlet UITextField *tfPostalCode;
@property (weak, nonatomic) IBOutlet UITextField *tfCity;
@property (weak, nonatomic) IBOutlet UITextField *tfState;
@property (weak, nonatomic) IBOutlet UITextField *tfCountry;
@property (weak, nonatomic) IBOutlet UIScrollView *formScrollView;
@property (weak, nonatomic) IBOutlet UIToolbar *pickerToolbar;
@property (weak, nonatomic) IBOutlet UIDatePicker *birthDatePicker;

- (IBAction)saveButtonPressed:(UIButton *)sender;
- (IBAction)cancelButtonPressed:(UIButton *)sender;
- (IBAction)pickerDoneButtonPressed:(UIBarButtonItem *)sender;
-(void) doneButtonPressed;
@end

@implementation AddBankViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.pickerToolbar.hidden = YES;
    self.birthDatePicker.hidden = YES;
    
    self.tfBirthDate.inputView = self.birthDatePicker;
    self.tfBirthDate.inputAccessoryView = self.pickerToolbar;
    
    [self initializeTextFieldInputView];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [self.formScrollView setContentSize:CGSizeMake(320, 950)];
}

- (void) initializeTextFieldInputView
{
    UIDatePicker *datePicker = [[UIDatePicker alloc] initWithFrame:CGRectZero];
    datePicker.datePickerMode = UIDatePickerModeDate;
    datePicker.minuteInterval = 5;
    datePicker.backgroundColor = [UIColor whiteColor];
    [datePicker addTarget:self action:@selector(dateUpdated:) forControlEvents:UIControlEventValueChanged];
    self.tfBirthDate.inputView = datePicker;
    
    UIToolbar *toolbar = [[UIToolbar alloc] init];
    toolbar.barStyle = UIBarStyleBlack;
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneButtonPressed)];
    UIBarButtonItem *flexibleSeparator = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    toolbar.items = @[flexibleSeparator, doneButton];
    self.tfBirthDate.inputAccessoryView = toolbar;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hidePicker)];
    [self.view addGestureRecognizer:tap];
}

-(void)hidePicker
{
    [self.tfBirthDate resignFirstResponder];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd-MMM-yyyy"];
    if (selectedDate == nil)
    {
        self.tfBirthDate.text = [formatter stringFromDate:[NSDate date]];
    }
    else
    {
        self.tfBirthDate.text = [formatter stringFromDate:selectedDate];
    }
}

- (void) dateUpdated:(UIDatePicker *)datePicker
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd-MMM-yyyy"];
    self.tfBirthDate.text = [formatter stringFromDate:datePicker.date];
    selectedDate = datePicker.date;
}

-(void) doneButtonPressed
{
    NSLog(@"Done");
}

#pragma mark- Action Event Handlers.

- (IBAction)saveButtonPressed:(UIButton *)sender
{
    if (self.tfBankName.text.length >0 && self.tfAccountNumber.text.length >0 && self.tfRoutingNumber.text.length >0 && self.tfBirthDate.text.length >0 && self.tfLine1.text.length >0 && self.tfPostalCode.text.length >0 && self.tfCity.text.length >0 && self.tfState.text.length >0 && self.tfCountry.text.length >0)
    {
        // Save bank details.
        //Use a weak variable for self within the blocks
        __weak typeof(self) weakSelf = self;

        BFHTTPClient *client = [BFHTTPClient sharedBFHTTPClient];
        client.delegate = self;
        
        NSString *userID = [[NSUserDefaults standardUserDefaults] valueForKey:@"UserID"];
        
        [SVProgressHUD show];
        
        [client saveBankDetailsWithBankName:self.tfBankName.text accountNumber:self.tfAccountNumber.text routingNumber:self.tfRoutingNumber.text birthDate:self.tfBirthDate.text line1:self.tfLine1.text postalCode:self.tfPostalCode.text city:self.tfCity.text state:self.tfState.text andCountry:self.tfCountry.text forUserID:userID completion:^(BOOL success, id response, NSError *error)
        {
            if (error)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [SVProgressHUD dismiss];
                    [weakSelf showAlertWithErrorMessage:error.localizedDescription];
                });
            }
            else
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    @autoreleasepool
                    {
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Bank details save successfully." delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
                        [alert show];
                        
                    }
                });
            }
        }];
    }
}

#pragma mark - UIAlertView Delegate Method

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [[self presentingViewController] dismissViewControllerAnimated:NO completion:nil];
}


-(void) showAlertWithErrorMessage:(NSString *)errorMessage
{
    @autoreleasepool
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:errorMessage delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        [alert show];
    }
}

- (IBAction)cancelButtonPressed:(UIButton *)sender
{
    [[self presentingViewController] dismissViewControllerAnimated:NO completion:nil];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    [self.view endEditing:YES];
}

- (IBAction)pickerDoneButtonPressed:(UIBarButtonItem *)sender
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

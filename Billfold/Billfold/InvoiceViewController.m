//
//  InvoiceViewController.m
//  Billfold
//
//  Created by Abhishek on 29/11/15.
//  Copyright © 2015 synerzip. All rights reserved.
//

#import "Constant.h"
#import "InvoiceViewController.h"

@interface InvoiceViewController ()<BFHTTPClientDelegate, UIAlertViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate>
{
    __block NSString *invoiceID;
    __block NSMutableArray *cardListArray;
    __block BOOL isNoPendingInVoice;
    __block UIToolbar *toolBar;
}
@property (weak, nonatomic) IBOutlet UITextField *tfPhoneNumber;
@property (weak, nonatomic) IBOutlet UITextField *tfBVC;
@property (weak, nonatomic) IBOutlet UITextField *tfAmount;
@property (weak, nonatomic) IBOutlet UITextView *tvDescription;
@property (weak, nonatomic) IBOutlet UIScrollView *formScrollView;
@property (nonatomic, retain) UIPickerView *cardPickerView;

- (IBAction)acceptButtonPressed:(UIButton *)sender;
- (IBAction)rejectButtonPressed:(id)sender;
@end

@implementation InvoiceViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tvDescription.layer.borderWidth = 1.0f;
    self.tvDescription.layer.borderColor = [[UIColor blackColor] CGColor];
    
    cardListArray = [[NSMutableArray alloc] init];
    isNoPendingInVoice = NO;
    
    self.cardPickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 380, 320, 200)];
    self.cardPickerView.showsSelectionIndicator = YES;
    self.cardPickerView.hidden = YES;
    self.cardPickerView.backgroundColor = [UIColor grayColor];
    self.cardPickerView.delegate = self;
    [self.view addSubview:self.cardPickerView];
    
    toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 336, 320.0, 44.0)];
    toolBar.barStyle = UIBarStyleBlackTranslucent;
    
    // done button
    UIBarButtonItem *done = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                             style:UIBarButtonItemStyleDone
                                                            target:self action:@selector(hidePicker)];
    
    UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                           target:nil
                                                                           action:nil];
    
    toolBar.items = [NSArray arrayWithObjects:space, done, nil];
    toolBar.hidden = YES;
    [self.view addSubview:toolBar];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [self.formScrollView setContentSize:CGSizeMake(320, 720)];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [SVProgressHUD show];
    //Use a weak variable for self within the blocks
    __weak typeof(self) weakSelf = self;

    BFHTTPClient *clinet = [BFHTTPClient sharedBFHTTPClient];
    clinet.delegate = self;
    
    NSString *userID = [[NSUserDefaults standardUserDefaults] valueForKey:@"UserID"];
    
    [clinet latestInvoiceForUser:userID completion:^(BOOL success, id response, NSError *error) {
        if (error)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [SVProgressHUD dismiss];
                
                if ([error.localizedDescription rangeOfString:@"404"].location != NSNotFound)
                {
                    // Contain 404.
                    @autoreleasepool
                    {
                        isNoPendingInVoice = YES;
                        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"" message:@"No pending invoice." delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
                        [alert show];
                    }
                }
                else
                {
                    @autoreleasepool
                    {
                        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Error" message:error.localizedDescription delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
                        [alert show];
                    }
                }

            });
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [SVProgressHUD dismiss];
                
                weakSelf.tfAmount.text = [response[@"amount"] stringValue];
                invoiceID = [response[@"id"] stringValue];
                weakSelf.tfPhoneNumber.text = response[@"receiverPhoneNumber"];
                weakSelf.tvDescription.text = response[@"description"];
            });
        }
    }];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.navigationController.navigationBarHidden = YES;
    self.tabBarController.tabBar.hidden = YES;
}

#pragma mark- UIPickerViewDataSource Methods.

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView; {
    return 1;
}
//Rows in each Column

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component; {
    return cardListArray.count;
}

#pragma mark- UIPickerViewDelegate Method

-(NSString*) pickerView:(UIPickerView*)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSDictionary *cardDetailDictionary = [cardListArray objectAtIndex:row];
    return [NSString stringWithFormat:@"************%@", cardDetailDictionary[@"lastFourDigits"]];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component;
{
    //Write the required logic here that should happen after you select a row in Picker View.
}

#pragma mark- UITapGesture event handler

-(void)hidePicker
{
    self.cardPickerView.hidden = YES;
    toolBar.hidden =YES;
    NSInteger row = [self.cardPickerView selectedRowInComponent:0];
    NSDictionary *selectedCard = cardListArray[row];
    
    [self proceedPaymentWithAction:@"ACCEPTED" andCardID:selectedCard[@"cardId"]];
}

#pragma mark - Action event handlers

- (IBAction)acceptButtonPressed:(UIButton *)sender
{
    if (isNoPendingInVoice == NO)
    {
        //Use a weak variable for self within the blocks
        __weak typeof(self) weakSelf = self;

        [SVProgressHUD show];
        BFHTTPClient *client = [BFHTTPClient sharedBFHTTPClient];
        client.delegate = self;
        
        NSString *userID = [[NSUserDefaults standardUserDefaults] valueForKey:@"UserID"];
        [client cardListForUser:userID completion:^(BOOL success, id response, NSError *error) {
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
                });
                NSLog(@"Response: %@", response);
                NSArray *responseArray = (NSArray *)response;
                if (responseArray.count == 0)
                {
                    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please add atleast one card to proceed." delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
                    [alert show];
                }
                else
                {
                    cardListArray = [NSMutableArray arrayWithArray:responseArray];
                    [weakSelf.cardPickerView reloadAllComponents];
                    weakSelf.cardPickerView.hidden = NO;
                    toolBar.hidden = NO;
                }
            }
        }];
    }
}

- (IBAction)rejectButtonPressed:(id)sender
{
    
    [SVProgressHUD show];
    
    if (isNoPendingInVoice == NO)
    {
        [self proceedPaymentWithAction:@"REJECTED" andCardID:@""];
    }
}

-(void) proceedPaymentWithAction:(NSString *)action andCardID:(NSString *)cardID
{
    [SVProgressHUD show];
    BFHTTPClient *client = [BFHTTPClient sharedBFHTTPClient];
    client.delegate = self;
    __block NSString *actionTaken = action;
    
    NSString *userID = [[NSUserDefaults standardUserDefaults] valueForKey:@"UserID"];
    [client performPaymentAction:action forInVoiceID:invoiceID withCardID:cardID forUser:userID completion:^(BOOL success, id response, NSError *error)
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
             NSLog(@"Response: %@", response);
             dispatch_async(dispatch_get_main_queue(), ^{
                 
                 [SVProgressHUD dismiss];
                 @autoreleasepool
                 {
                     NSString *message = @"";
                     if ([actionTaken isEqualToString:@"REJECTED"] == YES)
                     {
                         message = @"Invoice Request Declined.";
                     }
                     else
                     {
                         message = @"Invoice Accepted Successfully.";
                     }
                     UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"" message:message delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
                     [alert show];
                 }
             });
         }
     }];
}

#pragma mark- UIAlertViewDelegate Method

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [[self presentingViewController] dismissViewControllerAnimated:NO completion:nil];
}

#pragma mark- BFHTTPClientDelegate Methods

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

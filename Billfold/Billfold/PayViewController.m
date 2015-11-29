//
//  PayViewController.m
//  Billfold
//
//  Created by Abhishek on 28/11/15.
//  Copyright © 2015 synerzip. All rights reserved.
//

#import "Constant.h"
#import "PayViewController.h"

@interface PayViewController ()<BFHTTPClientDelegate, CardIOPaymentViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *lblBVC;

- (IBAction)fetchInvoiceButtonPressed:(UIButton *)sender;
- (IBAction)addCartButtonPressed:(UIButton *)sender;
- (IBAction)historyButtonPressed:(id)sender;
@end

@implementation PayViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [CardIOUtilities preload];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.navigationItem setHidesBackButton:YES];
    [self.navigationItem setTitle:@"Pay"];
    self.tabBarController.tabBar.hidden = NO;

    
    NSString *bvc = [[NSUserDefaults standardUserDefaults] valueForKey:@"BVC"];
    
    if (bvc == nil)
    {
        BFHTTPClient *client = [BFHTTPClient sharedBFHTTPClient];
        client.delegate = self;
        //Use a weak variable for self within the blocks
        __weak typeof(self) weakSelf = self;
        
        [SVProgressHUD show];
        NSString *userID = [[NSUserDefaults standardUserDefaults] valueForKey:@"UserID"];
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
                    
                    weakSelf.lblBVC.text = [response stringValue];
                });
                
            }
        }];
    }
    else
    {
        self.lblBVC.text = bvc;
    }
}

#pragma mark- BFHTTPClientDelegateMethod

-(void)bfHTTPClient:(BFHTTPClient *)client didFailWithError:(NSError *)error
{
    
}

#pragma mark- ActionHandlers

- (IBAction)fetchInvoiceButtonPressed:(UIButton *)sender
{
}

- (IBAction)addCartButtonPressed:(UIButton *)sender
{
    CardIOPaymentViewController *scanViewController = [[CardIOPaymentViewController alloc] initWithPaymentDelegate:self];
    [self presentViewController:scanViewController animated:YES completion:nil];
}

- (IBAction)historyButtonPressed:(id)sender
{
}

#pragma mark - CardIODelegate Methods

- (void)userDidCancelPaymentViewController:(CardIOPaymentViewController *)scanViewController {
    NSLog(@"User canceled payment info");
    // Handle user cancellation here...
    [scanViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)userDidProvideCreditCardInfo:(CardIOCreditCardInfo *)info inPaymentViewController:(CardIOPaymentViewController *)scanViewController {
    // The full card number is available as info.cardNumber, but don't log that!
    NSLog(@"Received card info. Number: %@, expiry: %02lu/%lu, cvv: %@.", info.redactedCardNumber, (unsigned long)info.expiryMonth, (unsigned long)info.expiryYear, info.cvv);
    // Use the card info...
    [scanViewController dismissViewControllerAnimated:YES completion:nil];
    
    // Register card with stripe.
    
    STPCardParams *card = [[STPCardParams alloc] init];
    card.number = @"4242424242424242";
    card.expMonth = (unsigned long)info.expiryMonth;
    card.expYear = (unsigned long)info.expiryYear;
    card.cvc = info.cvv;
    //Use a weak variable for self within the blocks
//    __weak typeof(self) weakSelf = self;

    __block NSString *cardNumber = [info.cardNumber substringFromIndex:[info.cardNumber length] - 4];

    [[STPAPIClient sharedClient] createTokenWithCard:card completion:^(STPToken * _Nullable token, NSError * _Nullable error) {
       
        if (!error)
        {
            BFHTTPClient *client = [BFHTTPClient sharedBFHTTPClient];
            client.delegate = self;
            
            [SVProgressHUD show];
            
            NSString *tokenString = [NSString stringWithFormat:@"%@", token];
            
            NSArray *tokenArray = [tokenString componentsSeparatedByString:@" "];
            
            tokenString = tokenArray.firstObject;
            
            NSString *userID = [[NSUserDefaults standardUserDefaults] valueForKey:@"UserID"];
            
            [client saveCreditCardForUser:userID withCardLastFourDigit:cardNumber andTokenID:tokenString completion:^(BOOL success, id response, NSError *error)
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
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        [SVProgressHUD dismiss];
                        @autoreleasepool
                        {
                            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Card save successfully." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
                            [alert show];
                        }
                    });
                }
            }];
        }
        else
        {
            NSLog(@"error: %@", error.localizedDescription);
        }
    }];
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

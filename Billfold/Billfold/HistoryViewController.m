//
//  HistoryViewController.m
//  Billfold
//
//  Created by Abhishek on 29/11/15.
//  Copyright © 2015 synerzip. All rights reserved.
//

#import "Constant.h"
#import "HistoryViewController.h"

@interface HistoryViewController ()<UITableViewDataSource, BFHTTPClientDelegate, UIAlertViewDelegate>

@property (nonatomic, strong) NSMutableArray *dataArray;
@property (weak, nonatomic) IBOutlet UITableView *listTableView;
@end

@implementation HistoryViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.listTableView.dataSource = self;
    self.dataArray = [[NSMutableArray alloc] init];
    
    self.navigationController.navigationBar.backgroundColor = [UIColor colorWithRed:98.0/255.0 green:98.0/255.0 blue:98.0/255.0 alpha:1.0];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [SVProgressHUD show];
    //Use a weak variable for self within the blocks
    __weak typeof(self) weakSelf = self;

    BFHTTPClient *client = [BFHTTPClient sharedBFHTTPClient];
    client.delegate = self;
    
    if (self.isReceiver == YES)
    {
        NSString *userID = [[NSUserDefaults standardUserDefaults] valueForKey:@"UserID"];
        
        [client receiverHistoryForUser:userID completion:^(BOOL success, id response, NSError *error)
         {
             if (error)
             {
                 if ([error.localizedDescription rangeOfString:@"404"].location != NSNotFound)
                 {
                     @autoreleasepool
                     {
                         dispatch_async(dispatch_get_main_queue(), ^{
                             [SVProgressHUD dismiss];
                             UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"No transaction(s) availabel." delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
                             [alert show];
                         });
                     }
                 }
             }
             else
             {
                 dispatch_async(dispatch_get_main_queue(), ^{
                     [SVProgressHUD dismiss];
                     NSArray *responseArray = (NSArray *)response;
                     if (responseArray.count >0)
                     {
                         [weakSelf.dataArray removeAllObjects];
                         weakSelf.dataArray = [NSMutableArray arrayWithArray:response];
                         [weakSelf.listTableView reloadData];
                     }
                     else
                     {
                         UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"No transaction(s) availabel." delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
                         [alert show];
                     }
                 });
             }
         }];
    }
    else
    {
        // Pay
        
        NSString *userID = [[NSUserDefaults standardUserDefaults] valueForKey:@"UserID"];
        
        [client payHistoryForUser:userID completion:^(BOOL success, id response, NSError *error)
         {
             if (error)
             {
                 if ([error.localizedDescription rangeOfString:@"404"].location != NSNotFound)
                 {
                     @autoreleasepool
                     {
                         dispatch_async(dispatch_get_main_queue(), ^{
                             [SVProgressHUD dismiss];
                             UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"No transaction(s) availabel." delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
                             [alert show];
                         });
                     }
                 }
             }
             else
             {
                 dispatch_async(dispatch_get_main_queue(), ^{
                     [SVProgressHUD dismiss];
                     NSArray *responseArray = (NSArray *)response;
                     if (responseArray.count >0)
                     {
                         [weakSelf.dataArray removeAllObjects];
                         weakSelf.dataArray = [NSMutableArray arrayWithArray:response];
                         [weakSelf.listTableView reloadData];
                     }
                     else
                     {
                         UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"No transaction(s) availabel." delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
                         [alert show];
                     }
                 });
             }
         }];
    }
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.tabBarController.tabBar.hidden = YES;
}

#pragma mark UIAlertViewDelegate Method.

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [[self presentingViewController] dismissViewControllerAnimated:NO completion:nil];
}

#pragma mark - UITableViewController Data Source Methods.

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"HistoryTableViewCell";
    
    HistoryTableViewCell *cell = (HistoryTableViewCell *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"HistoryTableViewCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    NSDictionary *dataDictionary = self.dataArray[indexPath.row];
    
    NSString *phoneNumber;
    
    if (dataDictionary[@"payerPhoneNumber"] != nil && dataDictionary[@"payerPhoneNumber"] != NULL)
    {
        phoneNumber = dataDictionary[@"payerPhoneNumber"];
    }
    else
    {
        phoneNumber = dataDictionary[@"receiverPhoneNumber"];
    }
    cell.lblPhoneNumber.text = [NSString stringWithFormat:@"To: %@", phoneNumber];
    cell.lblAmount.text = [NSString stringWithFormat:@"Amount: %d",[dataDictionary[@"amount"] intValue]];
    cell.lblDate.text = [NSString stringWithFormat:@"Date: %@", dataDictionary[@"createdDateStr"]];
    cell.lblStatus.text = [NSString stringWithFormat:@"Status: %@",dataDictionary[@"status"]];
    return cell;
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

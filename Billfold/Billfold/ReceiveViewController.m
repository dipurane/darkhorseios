//
//  ReceiveViewController.m
//  Billfold
//
//  Created by Abhishek on 28/11/15.
//  Copyright © 2015 synerzip. All rights reserved.
//

#import "Constant.h"
#import "ReceiveViewController.h"

@interface ReceiveViewController ()

@end

@implementation ReceiveViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tabBarItem.image = [UIImage imageNamed:@"receive30.png"];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.navigationItem setHidesBackButton:YES];
    [self.navigationItem setTitle:@"Receive"];
    self.tabBarController.tabBar.hidden = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"ReceiverHistory"] == YES)
    {
        HistoryViewController *historyViewCOntroller = segue.destinationViewController;
        historyViewCOntroller.isReceiver = YES;
    }
    
}

@end

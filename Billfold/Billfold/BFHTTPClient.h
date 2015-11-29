//
//  BFHTTPClient.h
//  Billfold
//
//  Created by Abhishek on 28/11/15.
//  Copyright © 2015 synerzip. All rights reserved.
//

#import "AFHTTPSessionManager.h"

@protocol BFHTTPClientDelegate;

@interface BFHTTPClient : AFHTTPSessionManager

@property (weak, nonatomic) id<BFHTTPClientDelegate>delegate;

+ (BFHTTPClient *)sharedBFHTTPClient;
- (instancetype)initWithBaseURL:(NSURL *)url;

-(void) authenticateUserMobileNumber:(NSString *)mobileNumber completion:(void(^)(BOOL success, id response, NSError *error))completion;
-(void) authenticateUserMobileNumber:(NSString *)mobileNumber withVerificationCode:(NSString *)verificationCode completion:(void(^)(BOOL success, id response, NSError *error))completion;
-(void) registerUserWithMobileNumber:(NSString *)mobileNumber firstName:(NSString *)firstName lastName:(NSString *)lastName emailAddress:(NSString *)emailAddress completion:(void(^)(BOOL success, id response, NSError *error))completion;
-(void) updatedBVCForUserID:(NSString *)userID completion:(void(^)(BOOL success, id response, NSError *error))completion;
-(void) raiseInvoiceWithPayerPhoneNumber:(NSString *)mobileNumber payerBVCCode:(NSString *)bvcCode amount:(NSString *)amount description:(NSString *)description fromUserID:(NSString *)userID completion:(void(^)(BOOL success, id response, NSError *error))completion;

-(void) saveBankDetailsWithBankName:(NSString *)bankName accountNumber:(NSString *)accountNumber routingNumber:(NSString *)routingNumber birthDate:(NSString *)birthdate line1:(NSString *)line1 postalCode:(NSString *)postalCode city:(NSString *)city state:(NSString *)state andCountry:(NSString *)country forUserID:(NSString *)userID completion:(void(^)(BOOL success, id response, NSError *error))completion;

-(void) saveCreditCardForUser:(NSString *)userID withCardLastFourDigit:(NSString *)lastFourDigit andTokenID:(NSString *)token completion:(void(^)(BOOL success, id response, NSError *error))completion;
-(void) latestInvoiceForUser:(NSString *)userID completion:(void(^)(BOOL success, id response, NSError *error))completion;

-(void) performPaymentAction:(NSString *)paymentAction forInVoiceID:(NSString *)invoiceID withCardID:(NSString *)cardID forUser:(NSString *)userID completion:(void(^)(BOOL success, id response, NSError *error))completion;
-(void) cardListForUser:(NSString *)userID completion:(void(^)(BOOL success, id response, NSError *error))completion;

-(void) payHistoryForUser:(NSString *)userID completion:(void(^)(BOOL success, id response, NSError *error))completion;
-(void) receiverHistoryForUser:(NSString *)userID completion:(void(^)(BOOL success, id response, NSError *error))completion;

-(void) checkStatusOfInvoice:(NSString *)invoiceID andUserID:(NSString *)userID completion:(void(^)(BOOL success, id response, NSError *error))completion;

@end

@protocol BFHTTPClientDelegate <NSObject>
@optional
-(void)bfHTTPClient:(BFHTTPClient *)client didFailWithError:(NSError *)error;
@end


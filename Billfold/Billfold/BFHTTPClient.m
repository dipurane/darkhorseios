//
//  BFHTTPClient.m
//  Billfold
//
//  Created by Abhishek on 28/11/15.
//  Copyright © 2015 synerzip. All rights reserved.
//

#import "BFHTTPClient.h"

@implementation BFHTTPClient

static NSString * const BFHTTPClientURLString = @"http://54.85.74.160:8000";

+ (BFHTTPClient *)sharedBFHTTPClient
{
    static BFHTTPClient *_sharedCSHTTPClient = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedCSHTTPClient = [[self alloc] initWithBaseURL:[NSURL URLWithString:BFHTTPClientURLString]];
    });
    
    return _sharedCSHTTPClient;
}

- (instancetype)initWithBaseURL:(NSURL *)url
{
    self = [super initWithBaseURL:url];
    
    if (self) {
        AFJSONResponseSerializer *responseSerializer = [AFJSONResponseSerializer serializerWithReadingOptions:NSJSONReadingAllowFragments];
        responseSerializer.removesKeysWithNullValues = YES;
        self.responseSerializer = responseSerializer;
        self.requestSerializer = [AFJSONRequestSerializer serializer];
    }
    return self;
}

-(id ) jsonFromDictionary:(NSDictionary *)dataDictionary
{
    NSError *error;
    NSString *jsonString = [[NSString alloc]
                            initWithData:[NSJSONSerialization dataWithJSONObject:dataDictionary options:kNilOptions error:&error]
                            encoding:NSUTF8StringEncoding];
    NSData *data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    id json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    
    return json;
}

-(void) authenticateUserMobileNumber:(NSString *)mobileNumber completion:(void(^)(BOOL success, id response, NSError *error))completion
{
    @autoreleasepool
    {
        NSString *path = @"/apis/usermanagement/authentication";
        
        NSArray *keyArray = [NSArray arrayWithObjects:@"mobileNumber", @"verificationCode", nil];
        NSArray *valueArray = [NSArray arrayWithObjects:mobileNumber, @"", nil];
        NSDictionary *dataDictionary = [NSDictionary dictionaryWithObjects:valueArray forKeys:keyArray];
        
        id json = [self jsonFromDictionary:dataDictionary];
        
        [self POST:path parameters:json success:^(NSURLSessionDataTask *task, id responseObject) {
            
            if (completion) //if completion is NULL, calling it will crash the app so we always check that it is present.
            {
                completion(YES, responseObject, nil);
            }
            
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            if (completion) //if completion is NULL, calling it will crash the app so we always check that it is present.
            {
                completion(YES, nil, error);
            }
        }];
    }
}

-(void) authenticateUserMobileNumber:(NSString *)mobileNumber withVerificationCode:(NSString *)verificationCode completion:(void(^)(BOOL success, id response, NSError *error))completion
{
    @autoreleasepool
    {
        NSString *path = @"/apis/usermanagement/verification";
        
        NSArray *keyArray = [NSArray arrayWithObjects:@"mobileNumber", @"verificationCode", nil];
        NSArray *valueArray = [NSArray arrayWithObjects:mobileNumber, verificationCode, nil];
        NSDictionary *dataDictionary = [NSDictionary dictionaryWithObjects:valueArray forKeys:keyArray];
        
        id json = [self jsonFromDictionary:dataDictionary];
        
        [self POST:path parameters:json success:^(NSURLSessionDataTask *task, id responseObject) {
            
            if (completion) //if completion is NULL, calling it will crash the app so we always check that it is present.
            {
                completion(YES, responseObject, nil);
            }
            
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            if (completion) //if completion is NULL, calling it will crash the app so we always check that it is present.
            {
                completion(YES, nil, error);
            }
        }];
    }
}

-(void) registerUserWithMobileNumber:(NSString *)mobileNumber firstName:(NSString *)firstName lastName:(NSString *)lastName emailAddress:(NSString *)emailAddress completion:(void(^)(BOOL success, id response, NSError *error))completion
{
    @autoreleasepool
    {
        NSString *path = @"/apis/usermanagement/userprofile";
        
        NSArray *keyArray = [NSArray arrayWithObjects:@"lastName", @"is_verified", @"email", @"firstName",@"phoneNumber", nil];
        NSArray *valueArray = [NSArray arrayWithObjects:lastName, [NSNumber numberWithBool:true], emailAddress, firstName, mobileNumber, nil];
        NSDictionary *dataDictionary = [NSDictionary dictionaryWithObjects:valueArray forKeys:keyArray];
        
        id json = [self jsonFromDictionary:dataDictionary];
        
        [self POST:path parameters:json success:^(NSURLSessionDataTask *task, id responseObject) {
            
            if (completion) //if completion is NULL, calling it will crash the app so we always check that it is present.
            {
                completion(YES, responseObject, nil);
            }
            
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            if (completion) //if completion is NULL, calling it will crash the app so we always check that it is present.
            {
                completion(YES, nil, error);
            }
        }];
    }
}

-(void) updatedBVCForUserID:(NSString *)userID completion:(void(^)(BOOL success, id response, NSError *error))completion
{
    @autoreleasepool
    {
        NSString *path = [NSString stringWithFormat:@"/apis/payer/%@/pvc", userID];
        
        [self POST:path parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
            
            if (completion) //if completion is NULL, calling it will crash the app so we always check that it is present.
            {
                completion(YES, responseObject, nil);
            }
            
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            if (completion) //if completion is NULL, calling it will crash the app so we always check that it is present.
            {
                completion(YES, nil, error);
            }
        }];
    }
}

-(void) raiseInvoiceWithPayerPhoneNumber:(NSString *)mobileNumber payerBVCCode:(NSString *)bvcCode amount:(NSString *)amount description:(NSString *)description fromUserID:(NSString *)userID completion:(void(^)(BOOL success, id response, NSError *error))completion
{
    @autoreleasepool
    {
        NSString *path = [NSString stringWithFormat:@"/apis/receiver/%@/transaction", userID];
        
        NSArray *keyArray = [NSArray arrayWithObjects:@"amount", @"payerPhoneNumber", @"payerBVCCode", @"description",@"userId", nil];
        NSArray *valueArray = [NSArray arrayWithObjects:amount, mobileNumber, bvcCode, description, userID, nil];
        NSDictionary *dataDictionary = [NSDictionary dictionaryWithObjects:valueArray forKeys:keyArray];
        
        id json = [self jsonFromDictionary:dataDictionary];
        
        [self POST:path parameters:json success:^(NSURLSessionDataTask *task, id responseObject) {
            
            if (completion) //if completion is NULL, calling it will crash the app so we always check that it is present.
            {
                completion(YES, responseObject, nil);
            }
            
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            if (completion) //if completion is NULL, calling it will crash the app so we always check that it is present.
            {
                completion(YES, nil, error);
            }
        }];
    }
}

//NSString* jsonDateFromDate(NSDate * date)
-(NSString *) jsonDateFromDate:(NSDate *)date
{
    NSString * jsonString = @"";
    
    @autoreleasepool
    {
        if (date != nil)
        {
            NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
            NSCalendarUnit unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth |  NSCalendarUnitDay;
            
            NSDateComponents *dateComponents = [gregorian components:unitFlags fromDate:date];
            NSInteger day = [dateComponents day];
            NSInteger month = [dateComponents month];
            NSInteger year = [dateComponents year];
            NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
            [dictionary setObject:[NSString stringWithFormat:@"%ld", (long)day] forKey:@"Date"];
            [dictionary setObject:[NSString stringWithFormat:@"%ld", (long)month] forKey:@"Month"];
            [dictionary setObject:[NSString stringWithFormat:@"%ld", (long)year] forKey:@"Year"];
            NSError *error;
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:&error];
            if (!jsonData)
            {
                NSLog(@"Got an error: %@", error);
            }
            else
            {
                jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            }
        }
    }
    return jsonString;
}


-(id) dateDictionaryFromDateString:(NSString *)dateString
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd-MM-yyyy"];
    NSDate *dateFromString = [[NSDate alloc] init];
    dateFromString = [dateFormatter dateFromString:dateString];
    
//    return [self jsonDateFromDate:dateFromString];
    
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSCalendarUnit unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth |  NSCalendarUnitDay;
    
    NSDateComponents *dateComponents = [gregorian components:unitFlags fromDate:dateFromString];
    NSInteger day = [dateComponents day];
    NSInteger month = [dateComponents month];
    NSInteger year = [dateComponents year];
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    [dictionary setObject:[NSString stringWithFormat:@"%ld", (long)day] forKey:@"day"];
    [dictionary setObject:[NSString stringWithFormat:@"%ld", (long)month] forKey:@"month"];
    [dictionary setObject:[NSString stringWithFormat:@"%ld", (long)year] forKey:@"year"];
    
    return dictionary;
}

-(void) saveBankDetailsWithBankName:(NSString *)bankName accountNumber:(NSString *)accountNumber routingNumber:(NSString *)routingNumber birthDate:(NSString *)birthdate line1:(NSString *)line1 postalCode:(NSString *)postalCode city:(NSString *)city state:(NSString *)state andCountry:(NSString *)country forUserID:(NSString *)userID completion:(void(^)(BOOL success, id response, NSError *error))completion
{
    @autoreleasepool
    {
        NSString *path = [NSString stringWithFormat:@"/apis/paymentgateway/%@/bankaccount", userID];
        
        NSMutableDictionary *addressDictionary = [[NSMutableDictionary alloc] init];
        [addressDictionary setObject:city forKey:@"city"];
        [addressDictionary setObject:country forKey:@"country"];
        [addressDictionary setObject:line1 forKey:@"line1"];
        [addressDictionary setObject:postalCode forKey:@"postalCode"];
        [addressDictionary setObject:state forKey:@"state"];
        
        id dateJSON = [self dateDictionaryFromDateString:birthdate];
        
        NSArray *keyArray = [NSArray arrayWithObjects:@"address", @"bankName", @"accountNumber", @"routingNumber",@"birthDate", nil];
        NSArray *valueArray = [NSArray arrayWithObjects:addressDictionary, bankName, accountNumber, routingNumber, dateJSON, nil];
        
        NSDictionary *dataDictionary = [NSDictionary dictionaryWithObjects:valueArray forKeys:keyArray];
        
        id json = [self jsonFromDictionary:dataDictionary];
        
        [self POST:path parameters:json success:^(NSURLSessionDataTask *task, id responseObject) {
            
            if (completion) //if completion is NULL, calling it will crash the app so we always check that it is present.
            {
                completion(YES, responseObject, nil);
            }
            
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            if (completion) //if completion is NULL, calling it will crash the app so we always check that it is present.
            {
                completion(YES, nil, error);
            }
        }];
    }
}

-(void) saveCreditCardForUser:(NSString *)userID withCardLastFourDigit:(NSString *)lastFourDigit andTokenID:(NSString *)token completion:(void(^)(BOOL success, id response, NSError *error))completion
{
    @autoreleasepool
    {
        NSString *path = [NSString stringWithFormat:@"/apis/paymentgateway/%@/creditcard", userID];
        
        NSArray *keyArray = [NSArray arrayWithObjects:@"lastFourDigits", @"tokenId", nil];
        NSArray *valueArray = [NSArray arrayWithObjects:lastFourDigit, token, nil];
        NSDictionary *dataDictionary = [NSDictionary dictionaryWithObjects:valueArray forKeys:keyArray];
        
        id json = [self jsonFromDictionary:dataDictionary];
        
        [self POST:path parameters:json success:^(NSURLSessionDataTask *task, id responseObject) {
            
            if (completion) //if completion is NULL, calling it will crash the app so we always check that it is present.
            {
                completion(YES, responseObject, nil);
            }
            
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            if (completion) //if completion is NULL, calling it will crash the app so we always check that it is present.
            {
                completion(YES, nil, error);
            }
        }];
    }
}

-(void) latestInvoiceForUser:(NSString *)userID completion:(void(^)(BOOL success, id response, NSError *error))completion
{
    @autoreleasepool
    {
        NSString *path = [NSString stringWithFormat:@"/apis/payer/%@/transaction", userID];
        [self GET:path parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
            if (completion) //if completion is NULL, calling it will crash the app so we always check that it is present.
            {
                completion(YES, responseObject, nil);
            }

        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            if (completion) //if completion is NULL, calling it will crash the app so we always check that it is present.
            {
                completion(YES, nil, error);
            }
        }];
    }
}

-(void) performPaymentAction:(NSString *)paymentAction forInVoiceID:(NSString *)invoiceID withCardID:(NSString *)cardID forUser:(NSString *)userID completion:(void(^)(BOOL success, id response, NSError *error))completion
{
    @autoreleasepool
    {
        NSString *path = [NSString stringWithFormat:@"/apis/payer/%@/transactions/%@", userID, invoiceID];
        
        NSArray *keyArray = [NSArray arrayWithObjects:@"cardId", @"paymentAction", nil];
        NSArray *valueArray = [NSArray arrayWithObjects:cardID, paymentAction, nil];
        NSDictionary *dataDictionary = [NSDictionary dictionaryWithObjects:valueArray forKeys:keyArray];
        
        id json = [self jsonFromDictionary:dataDictionary];
        
        [self PUT:path parameters:json success:^(NSURLSessionDataTask *task, id responseObject) {
            
            if (completion) //if completion is NULL, calling it will crash the app so we always check that it is present.
            {
                completion(YES, responseObject, nil);
            }
            
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            if (completion) //if completion is NULL, calling it will crash the app so we always check that it is present.
            {
                completion(YES, nil, error);
            }
        }];
    }
}

-(void) cardListForUser:(NSString *)userID completion:(void(^)(BOOL success, id response, NSError *error))completion
{
    NSString *path = [NSString stringWithFormat:@"/apis/paymentgateway/%@/creditcard", userID];
    [self GET:path parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        if (completion) //if completion is NULL, calling it will crash the app so we always check that it is present.
        {
            completion(YES, responseObject, nil);
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (completion) //if completion is NULL, calling it will crash the app so we always check that it is present.
        {
            completion(YES, nil, error);
        }
    }];
}

-(void) payHistoryForUser:(NSString *)userID completion:(void(^)(BOOL success, id response, NSError *error))completion
{
    NSString *path = [NSString stringWithFormat:@"/apis/payer/%@/transactionList", userID];
    [self GET:path parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        if (completion) //if completion is NULL, calling it will crash the app so we always check that it is present.
        {
            completion(YES, responseObject, nil);
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (completion) //if completion is NULL, calling it will crash the app so we always check that it is present.
        {
            completion(YES, nil, error);
        }
    }];
}

-(void) receiverHistoryForUser:(NSString *)userID completion:(void(^)(BOOL success, id response, NSError *error))completion
{
    NSString *path = [NSString stringWithFormat:@"/apis/receiver/%@/transactionList", userID];
    [self GET:path parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        if (completion) //if completion is NULL, calling it will crash the app so we always check that it is present.
        {
            completion(YES, responseObject, nil);
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (completion) //if completion is NULL, calling it will crash the app so we always check that it is present.
        {
            completion(YES, nil, error);
        }
    }];
}

-(void) checkStatusOfInvoice:(NSString *)invoiceID andUserID:(NSString *)userID completion:(void(^)(BOOL success, id response, NSError *error))completion
{
    NSString *path = [NSString stringWithFormat:@"/apis/receiver/%@/transaction/%@", userID, invoiceID];
    [self GET:path parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        if (completion) //if completion is NULL, calling it will crash the app so we always check that it is present.
        {
            completion(YES, responseObject, nil);
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (completion) //if completion is NULL, calling it will crash the app so we always check that it is present.
        {
            completion(YES, nil, error);
        }
    }];
}

@end

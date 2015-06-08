#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, BraintreeDemoTransactionServiceEnvironment) {
    BraintreeDemoTransactionServiceEnvironmentSandboxBraintreeSampleMerchant,
    BraintreeDemoTransactionServiceEnvironmentProductionExecutiveSampleMerchant,
};

@interface BraintreeTransactionService : NSObject

+ (instancetype)sharedService;
+ (BraintreeDemoTransactionServiceEnvironment)mostRecentlyUsedEnvironment;

- (void)setEnvironment:(BraintreeDemoTransactionServiceEnvironment)environment;

- (void)fetchMerchantConfigWithCompletion:(void (^)(NSString *merchantId, NSError *error))completionBlock;
- (void)createCustomerAndFetchClientTokenWithCompletion:(void (^)(NSString *clientToken, NSError *error))completionBlock;
- (void)createCustomerAndFetchClientTokenWithParameters:(id)params withCompletion:(void (^)(NSString *, NSError *, BOOL))completionBlock;
- (void)makeTransactionWithPaymentMethodNonce:(NSString *)paymentMethodNonce completion:(void (^)(NSString *transactionId, NSError *error))completionBlock;

@end

//
//  GlobalConstants.h
//  LegitKicks
//
//  Created by Sunil Zalavadiya on 03/11/14.
//  Copyright (c) 2014 Sunil Zalavadiya. All rights reserved.
//

#ifndef LegitKicks_GlobalConstants_h
#define LegitKicks_GlobalConstants_h


#define IS_IPHONE_4 (fabs((double)[[UIScreen mainScreen] bounds].size.height - (double)480) < DBL_EPSILON)
#define IS_IPHONE_5 (fabs((double)[[UIScreen mainScreen] bounds].size.height - (double)568) < DBL_EPSILON)
#define IS_IPHONE_6 (fabs((double)[[UIScreen mainScreen]bounds].size.height - (double)667) < DBL_EPSILON)
#define IS_IPHONE_6_PLUS (fabs((double)[[UIScreen mainScreen]bounds].size.height - (double)736) < DBL_EPSILON)



#define IDIOM                           UI_USER_INTERFACE_IDIOM()
#define IPHONE                          UIUserInterfaceIdiomPhone
#define IPAD                            UIUserInterfaceIdiomPad

#define IS_IPHONE                       ( IDIOM == IPHONE )
#define IS_IPAD                         ( IDIOM == IPAD )
#define IS_HEIGHT_GTE_568               [[UIScreen mainScreen ] bounds].size.height >= 568.0f
//#define IS_IPHONE_5                     ( IS_IPHONE && IS_HEIGHT_GTE_568 )
#define IS_RETINA_DISPLAY               ([[UIScreen mainScreen] respondsToSelector:@selector(displayLinkWithTarget:selector:)] && ([UIScreen mainScreen].scale == 2.0))

#define IOS_VERSION                     [[[[UIDevice currentDevice].systemVersion componentsSeparatedByString:@"."] objectAtIndex:0] intValue]

#define IS_IOS5                         (IOS_VERSION >= 5 && IOS_VERSION < 6)
#define IS_IOS6                         (IOS_VERSION >= 6 && IOS_VERSION < 7)
#define IS_IOS7                         (IOS_VERSION >= 7)
#define IS_IOS8                         (IOS_VERSION >= 8)


#define APP_PRINT

#ifdef APP_PRINT
#define LKLog(fmt, ...)                  NSLog((fmt), ##__VA_ARGS__)
#else
#define LKLog(...)
#endif



#define SNEAKER_STATUS_IN_TRADE     2
#define SNEAKER_STATUS_TRADED       21
#define SNEAKER_STATUS_IN_SALE      3
#define SNEAKER_STATUS_SOLD         31


#define POST_APPLY_FILTER_NOTIFICATION  @"applyFilterNotification"


#define kClientId   @"354545867587-cv8o5ggqa1plvmld1a5f17jos4ji6ij6.apps.googleusercontent.com";

//#define BASE_API    @"http://54.209.58.155/legitkiks/webservices/legservice.php"
#define BASE_API    @"http://wobsites.com/legitkiks/webservices/legservice.php"

//#define BASE_API1   @"http://wobsites.com/legitkiks/webservices/legservice_more.php"
//#define  SEARCH_API_URL     (BASE_API1 @"?action=search")

#define BASE_API1   @"http://wobsites.com/legitkiks/webservices/"

#define SEARCH_API_URL                      (BASE_API1 @"legservice_search_keyword.php")
#define GET_SNEAKER_FOR_TRADE_API_URL       (BASE_API1 @"legservice_sneker_user_list.php")
#define CHECK_TRADE_ALLOW_STATUS_API_URL    (BASE_API1 @"legservice_check_trade_status.php")

#define ADD_TRADE_INFO_API_URL              (BASE_API1 @"legservice_add_trade_info.php")
#define ADD_SALE_INFO_API_URL               (BASE_API1 @"legservice_add_sell_info.php")
#define MAKE_SELL_OFFER_API_URL             (BASE_API1 @"legservice_make_offer_forsell.php")
#define MAKE_SELL_COUNTER_OFFER_API_URL     (BASE_API1 @"legservice_counter_offer_forsell.php")

#define GET_TRADE_REQUEST_API_URL           (BASE_API1 @"legservice_get_trade_request.php")
#define GET_SALE_REQUEST_API_URL            (BASE_API1 @"legservice_get_sell_request.php")
#define GET_BUY_REQUEST_API_URL             (BASE_API1 @"legservice_get_buy_request.php")

#define GET_TRADE_REQUEST_DETAIL_API_URL    (BASE_API1 @"legservice_get_trade_request_detail.php")
#define GET_SALE_REQUEST_DETAIL_API_URL     (BASE_API1 @"legservice_get_sell_request_detail.php")

#define ACCEPT_REJECT_TRADE_REQUEST_API_URL                 (BASE_API1 @"legservice_accept_reject_trade_request.php")
#define ACCEPT_REJECT_SELL_OFFER_REQUEST_API_URL            (BASE_API1 @"legservice_accept_reject_makeoffer_request.php")
#define ACCEPT_REJECT_SELL_COUNTER_OFFER_REQUEST_API_URL    (BASE_API1 @"legservice_accept_reject_counteroffer_request.php")
#define PAY_SELL_OFFER_API_URL                              (BASE_API1 @"legservice_pay_sell_offer.php")

#define SNEAKER_RECEIVED_FOR_TRADE_API_URL  (BASE_API1 @"legservice_sneaker_receive_fortrade.php")
#define SNEAKER_RECEIVED_FOR_SELL_API_URL   (BASE_API1 @"legservice_sneaker_recieve_forsell.php")

#define GET_ADDRESS_FOR_USER_API_URL        (BASE_API1 @"legservice_get_address_detail_user.php")
#define GET_SELL_ADDRESS_FOR_USER_API_URL   (BASE_API1 @"legservice_get_sell_addressdetail_foruser.php")

#define SEND_COURIER_DETAIL_API_URL         (BASE_API1 @"legservice_send_courier_detail.php")
#define SEND_COURIER_DETAILFOR_SALE_API_URL (BASE_API1 @"legservice_send_sell_courier_detail.php")

#define ADD_RATE_REVIEW_API_URL             (BASE_API1 @"legservice_add_rate_review.php")
#define GET_CONVERSATION_ACTIVITY_API_URL   (BASE_API1 @"legservice_get_conversation_activity.php")
#define GET_SNEAKER_DETAIL_API_URL          (BASE_API1 @"legservice_get_sneaker_detail.php")
#define GET_CLIENT_TOKEN_API_URL            (BASE_API1 @"legservice_get_client_token.php")
#define GET_REVIEW_LIST_URL                 (BASE_API1 @"legservice_review.php")
#define GET_USER_AVG_RATING                 (BASE_API1 @"legservice_get_userrating.php")

#define ADD_COVERSATION_API_URL             (BASE_API1 @"legservice_add_conversation.php")
#define GET_COVERSATION_API_URL             (BASE_API1 @"legservice_get_conversation_list.php")

#define CHECK_REMAIN_RATE_REVIEW_API_URL    (BASE_API1 @"legservice_check_review_remain.php")




#endif

//
//  HGAlipayManager.m
//  HappyGift
//
//  Created by Yujian Weng on 12-5-15.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "HGAlipayService.h"
#import "AlixPayOrder.h"
#import "AlixPay.h"
#import "DataSigner.h"
#import "DataVerifier.h"

#define kAlipaySellerID                   @"TODO_sellerID"
#define kAlipayPartnerID                  @"TODO_partnerID"
#define kAlipayRSAPrivateKey            @"MIICdwIBADANBgkqhkiG9w0BAQEFAASCAmEwggJdAgEAAoGBANyYiHUCb3TmDNvPCaHkwZR9tT4lNG6H7qQhErWRniqmPswnqa2Ws9o6ss1rurCHELab5KcsNWCzBqVHK+TqzHE0zzWTSwT3iG11yGlSs39nlOW7kXSsxBmzlhk31CFDbeQFnQNZthJvyJfRCo9vJEtn4Khejn/bmK7GyD0uOe7DAgMBAAECgYAyT6uXnDWVYL6AB2k3/jdUSZNjmBKsPt5jmpNsy8haC854u3cMezmLxSVwimhqyHM8YrO0mPWXl10lpuTQ8egsYQxPYRm9gI7FwJKHFaSNyCcPUT0m1WxYimV4l1sobYMWTuQKvnsLp5lsWsVSSRKn62GBXGZ2K9byR9QVZe9bAQJBAPlFxHfk0vG10l5FFI5luSErQWNCUsguug5U+73OtONAJGCFZL01dXJJZ4qpCragGhr8knMekIPPlPhHm+TJQUMCQQDijKMlR4/J+cDVkY10cimZwZlg4b1l2zxrWN7p/GJGvGvOxhm2a1+LQdb800JUPNuljRV+PMQo/fhpmZj62QSBAkEAi8970JtBTVzjrwgj7XJUkawHMrsCX1EF/f/gaqdDgap6PMDUreMMCpvtPTJu1duaiMRdB8B+4c9OCKtxXrMarQJBAI/a+/G9Kjn3pJI41ZjesTnYLFvPnCOkfg4wJYRw5brDBLYNJuCl98qGqUxrnY++AT9zgfViArGA64+qn/CRg4ECQDDtSWumXdv4l+NqAhAjzkzq37t02aV0vutbnzKUQk8+TAvJYd4iyea3zMlVCOJft7048KyzMzUYpurvwxF1mwA=";
#define kAlipayRSAPublicKey             @"MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDcmIh1Am905gzbzwmh5MGUfbU+JTRuh+6kIRK1kZ4qpj7MJ6mtlrPaOrLNa7qwhxC2m+SnLDVgswalRyvk6sxxNM81k0sE94htdchpUrN/Z5Tlu5F0rMQZs5YZN9QhQ23kBZ0DWbYSb8iX0QqPbyRLZ+CoXo5/25iuxsg9LjnuwwIDAQAB";  
#define kAlipayNotifyURL                @"TODO_notifyURL"

static HGAlipayService* alipayService = nil;

@implementation HGAlipayService

@synthesize sellerID        =   _sellerID;
@synthesize partnerID       =   _partnerID;
@synthesize rsaPrivateKey   =   _rsaPrivateKey;
@synthesize rsaPublicKey    =   _rsaPublicKey;
@synthesize notifyURL       =   _notifyURL;

+ (HGAlipayService*)sharedService {
    if (alipayService == nil){
        alipayService = [[HGAlipayService alloc] init];
        alipayService.sellerID = kAlipaySellerID;
        alipayService.partnerID = kAlipayPartnerID;
        alipayService.rsaPrivateKey = kAlipayRSAPrivateKey;
        alipayService.rsaPublicKey = kAlipayRSAPublicKey;
        alipayService.notifyURL = kAlipayNotifyURL;
    }
    return alipayService;
}

- (void) dealloc {
    [_sellerID release];
    [_partnerID release];
    [_rsaPrivateKey release];
    [_rsaPublicKey release];
    [_notifyURL release];
    [super dealloc];
}
//
//选中商品调用支付宝安全支付
//
- (void)payForGift:(HGGift*)gift withTradeNO:(NSString*)tradeNO {
	/*
	 *签约后，支付宝会为每个商户分配一个唯一的 parnter 和 seller。
	 */	
    
	//partner和seller获取失败,提示
	if ([self.partnerID length] == 0 || [self.sellerID length] == 0) {
        NSLog(@"缺少partner或者seller。");
		return;
	}
	
	/*
	 *生成订单信息及签名
	 *由于demo的局限性，本demo中的公私钥存放在AlixPayDemo-Info.plist中,外部商户可以存放在服务端或本地其他地方。
	 */
	//将商品信息赋予AlixPayOrder的成员变量
	AlixPayOrder *order = [[AlixPayOrder alloc] init];
	order.partner = self.partnerID;
	order.seller = self.sellerID;
	order.tradeNO = tradeNO; //订单ID（由商家自行制定）
	order.productName = gift.name; //商品标题
	order.productDescription = gift.description; //商品描述
	order.amount = [NSString stringWithFormat:@"%.2f", gift.price]; //商品价格
	order.notifyURL = self.notifyURL; //回调URL
	
	//应用注册scheme,在AlixPayDemo-Info.plist定义URL types,用于安全支付成功后重新唤起商户应用
	NSString *appScheme = @"HappyGift";
	
	//将商品信息拼接成字符串
	NSString *orderSpec = [order description];
	NSLog(@"orderSpec = %@",orderSpec);
	
	//获取私钥并将商户信息签名,外部商户可以根据情况存放私钥和签名,只需要遵循RSA签名规范,并将签名字符串base64编码和UrlEncode
	id<DataSigner> signer = CreateRSADataSigner(self.rsaPrivateKey);
	NSString *signedString = [signer signString:orderSpec];
	
	//将签名成功字符串格式化为订单字符串,请严格按照该格式
	NSString *orderString = nil;
	if (signedString != nil) {
		orderString = [NSString stringWithFormat:@"%@&sign=\"%@\"&sign_type=\"%@\"",
                       orderSpec, signedString, @"RSA"];
	}
    
	//获取安全支付单例并调用安全支付接口
	AlixPay * alixpay = [AlixPay shared];
	int ret = [alixpay pay:orderString applicationScheme:appScheme];
	
	if (ret == kSPErrorAlipayClientNotInstalled) {
		UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"提示" 
															 message:@"您还没有安装支付宝的客户端，请先安装。" 
															delegate:self 
												   cancelButtonTitle:@"确定" 
												   otherButtonTitles:nil];
		[alertView setTag:123];
		[alertView show];
		[alertView release];
	} else if (ret == kSPErrorSignError) {
		NSLog(@"签名错误！");
	}
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (alertView.tag == 123) {
		NSString * URLString = [NSString stringWithString:@"http://itunes.apple.com/cn/app/id333206289?mt=8"];
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:URLString]];
	}
}

- (void)parsePaymentResult:(NSURL *)url application:(UIApplication *)application {
	AlixPay *alixpay = [AlixPay shared];
	AlixPayResult *result = [alixpay handleOpenURL:url];
	if (result) {
		//是否支付成功
		if (9000 == result.statusCode) {
            /*
			 *用公钥验证签名
			 */
			id<DataVerifier> verifier = CreateRSADataVerifier(self.rsaPublicKey);
			if ([verifier verifyString:result.resultString withSign:result.signString]) {
				UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"提示" 
																	 message:result.statusMessage 
																	delegate:nil 
														   cancelButtonTitle:@"确定" 
														   otherButtonTitles:nil];
                [alertView show];
				[alertView release];
			} else {
                //验签错误
				UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"提示" 
																	 message:@"签名错误" 
																	delegate:nil 
														   cancelButtonTitle:@"确定" 
														   otherButtonTitles:nil];
				[alertView show];
				[alertView release];
			}
		} else {
            //如果支付失败,可以通过result.statusCode查询错误码
			UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"提示" 
																 message:result.statusMessage 
																delegate:nil 
													   cancelButtonTitle:@"确定" 
													   otherButtonTitles:nil];
			[alertView show];
			[alertView release];
		}
		
	}	
}

@end

/********* lantu-union-pay.m Cordova Plugin Implementation *******/

#import <Cordova/CDV.h>
#import "UPPaymentControl.h"

@interface LantuUnionPay : CDVPlugin {
	// Member variables go here.
}

@property(nonatomic, strong) NSString *lantuPresetUrlSchemeForUnionPay;
@property(nonatomic, weak) NSString *urlSchemeForPayCallback;
@property(nonatomic,strong) NSString *currentCallbackId;

- (void)pay:(CDVInvokedUrlCommand*)command;

- (void)isUnionAppInstalled:(CDVInvokedUrlCommand*)command;

@end


@implementation LantuUnionPay

@synthesize lantuPresetUrlSchemeForUnionPay;

- (void)pluginInitialize{
	
	// @Todo: 今后调整为通过 plugin.xml 安装并获取
	NSString *unionPaySchemeId = @"mobileCampusUnionPay";

	// 获取 -info.plist CFBundleURLTypes
	NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"Info" ofType:@"plist"];
	NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithContentsOfFile:bundlePath];
	NSArray *urlTypes = [dict objectForKey:@"CFBundleURLTypes"];
	
	// 得到 mobilecampus 的 CFBundleURLSchemes 值
	[urlTypes indexOfObjectPassingTest:^BOOL(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
		if([unionPaySchemeId isEqualToString:[obj objectForKey:@"CFBundleURLName"]]){
			self.lantuPresetUrlSchemeForUnionPay = [[obj objectForKey:@"CFBundleURLSchemes"] objectAtIndex:0];
			return YES;
		}
		return NO;
	}];
	
}

- (void)pay:(CDVInvokedUrlCommand*)command {
	
	self.currentCallbackId = command.callbackId;

	// 获取支付参数
	NSDictionary *options = [command argumentAtIndex:0];
	NSLog(@"支付参数%@", options);
	
	NSString *tn = [options objectForKey:@"tn"];
	NSString *mode = [options objectForKey:@"mode"];
	NSString *fromScheme = [options objectForKey:@"scheme"];

	if(!fromScheme){
		fromScheme = self.lantuPresetUrlSchemeForUnionPay;
	}

	self.urlSchemeForPayCallback = fromScheme;

	bool isStartPayReal = [[UPPaymentControl defaultControl] startPay:tn
									 fromScheme:fromScheme
										   mode:mode
								 viewController:[self viewController]
	 ];

	if(!isStartPayReal){

		NSDictionary *pluginResultInfo = @{
			@"type": @"fail",
			@"msg": @"拉起控件失败"
		};

		CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:pluginResultInfo];
		[self.commandDelegate sendPluginResult:pluginResult callbackId:self.currentCallbackId];
	}

}

-(void)isUnionAppInstalled:(CDVInvokedUrlCommand *)command{
	
	CDVPluginResult* pluginResult = nil;
	
	if ([[UPPaymentControl defaultControl] isPaymentAppInstalled]) {
		pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
										   messageAsBool:YES];
	} else {
		pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
										   messageAsBool:NO];
	}
	
	[self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
	
}

-(void)handleOpenURLWithApplicationSourceAndAnnotation:(NSNotification *)notification{


	
}

-(void)handleOpenURL:(NSNotification *)notification{
	
	NSURL* url = [notification object];
	
	if (![url isKindOfClass:[NSURL class]] || ![url.scheme isEqualToString:self.urlSchemeForPayCallback]) {
		return;
	}
	
	[[UPPaymentControl defaultControl] handlePaymentResult:url completeBlock:^(NSString *code, NSDictionary *data) {
		
		NSLog(@"支付结果代号: %@", code);
		NSLog(@"支付结果数据: %@", data);
		
		CDVPluginResult* pluginResult = nil;
		
		NSMutableDictionary* pluginResultInfo = [NSMutableDictionary dictionaryWithCapacity:3];
		[pluginResultInfo setObject:code forKey:@"code"];

		if([code isEqualToString:@"success"]) {
			// 结果code为成功时，去商户后台查询一下确保交易是成功的再展示成功
			[pluginResultInfo setObject:@"支付完成" forKey:@"msg"];
			[pluginResultInfo setObject:data forKey:@"successExtraData"];

			pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:pluginResultInfo];
			[self.commandDelegate sendPluginResult:pluginResult callbackId:self.currentCallbackId];
			
		}else if([code isEqualToString:@"fail"]) {
			// 交易失败
			[pluginResultInfo setObject:@"支付失败" forKey:@"msg"];

			pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:pluginResultInfo];
			[self.commandDelegate sendPluginResult:pluginResult callbackId:self.currentCallbackId];
			
		}else if([code isEqualToString:@"cancel"]) {
			// 交易取消
			[pluginResultInfo setObject:@"支付取消" forKey:@"msg"];

			pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:pluginResultInfo];
			[self.commandDelegate sendPluginResult:pluginResult callbackId:self.currentCallbackId];
		}
	}];

}

@end

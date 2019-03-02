const exec = require("cordova/exec");

exports.pay = pay;
exports.isUnionAppInstalled = isUnionAppInstalled;


/**
 * 支付参数
 * @typedef { Object } payInfo
 * @property { String } tn 银联交易流水号(支付空间使用)
 * @property { String } [mode] 支付模式
 * 						"00"代表接入生产环境（正式版本需要
 * 						"01"代表接入开发测试环境（测试版本需要）
 * @property { String } [scheme] ios scheme for host'app, 一般不传
 */

/**
 * 支付结果接口
 * @typedef { Object } payResult
 * @property { String } type 支付结果, 候选值 "success"、"fail"、"cancel"
 * @property { successPaySignData } [successExtraData] 仅有成功时返回
 *
 */
/**
 * 支付结果接口
 * @typedef { Object } successPaySignData
 * @property { String } sign 签名后做Base64的数据
 * @property { String } data 用于签名的原始数据，结构如: pay_result=success&tn=899394085660622736701&cert_id=68759585097
 *
 */


/**
 * @description 支付成功回调
 * @callback paySuccessCallback
 * @param { payResult } result
 */
/**
 * @description 支付失败回调
 * @callback payErrorCallback
 * @param { payResult } result
 */


/**
 * 唤起 银联云闪付SDK
 * @param { payInfo } payInfo
 * @param { paySuccessCallback } [success]
 * @param { payErrorCallback } [error]
 */
function pay(payInfo, success, error){

	payInfo = Object.assign({
		mode: "01"
	}, payInfo);

	exec((result) => {
		console.log("支付完成: ", result);
		_execFunction(success, arguments);
	}, (result) => {
		console.log("支付失败: ", result);
		_execFunction(error, arguments);
	}, "LantuUnionPay", "pay", [payInfo]);
	
}


/**
 * @description 检查是否安装银联App回调
 * @callback checkAppInstallCallback
 * @param { Boolean } isInstalled
 */

/**
 * 检查是否安装银联App
 * @param { checkAppInstallCallback } success
 * @param [error]
 */
function isUnionAppInstalled(success, error){

	exec((isInstalled) => {
		console.log("检查是否安装银联App: ", isInstalled);
		_execFunction(success, arguments);
	}, (error) => {
		console.log("检测发生异常: ", error);
		_execFunction(error, arguments);
	}, "LantuUnionPay", "isUnionAppInstalled");

}

/**
 * 支持 fn
 * @param { Function | * } fn
 * @param { Array } args
 * @param { * } [context]
 */
function _execFunction(fn, args, context){

	if("function" !== typeof fn){ return; }

	return fn.apply(context, args);

}

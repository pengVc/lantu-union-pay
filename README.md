# lantu-union-pay #

云闪付 cordova 插件

## 简介

集成银联手机控件:
- Android 手机支付控件开发包(安卓版)3.4.5
- IOS 手机支付控件开发包(iOS版)3.3.11


### 安装方法

`cordova plugin add https://gitee.com/lantutech/lantu-union-pay.git`

### 使用方法

```javascript

cordova.plugins.LantuUnionPay.pay(options, success, error)

```

__{ Object } options:__
* { String } tn - 银联交易流水号(支付空间使用)
* { String } [mode] - 支付模式, "00"代表接入生产环境（正式版本需要)、01"代表接入开发测试环境（测试版本需要）
* { String } [scheme] -  ios scheme for host'app, 一般情况不传


__{ Function } success:__
支付成功回调:

```javascript
function success(payResult){ 

	/**
     * 支付结果
     * @type { Object } payResult
     * @property { String } type 支付结果, 候选值 "success"、"fail"、"cancel"
     * @property { successPaySignData } [successExtraData] 仅有成功时返回
     */
	payResult;
	
	
	/**
	 * 额外迁移数据( 银联也建议不在客户端做处理, 忽略就好 )
	 * @typedef { Object } successPaySignData
	 * @property { String } sign 签名后做Base64的数据
	 * @property { String } data 用于签名的原始数据，结构如: pay_result=success&tn=899394085660622736701&cert_id=68759585097
	 */
	
}
```

__{ Function } success:__
支付失败回调:

```javascript
function error(payResult){ 

	/**
     * 支付结果
     * @type { Object } payResult
     * @property { String } type 支付结果, 候选值 "success"、"fail"、"cancel"
     */
	payResult;

}
```



demo:
```javascript
cordova.plugins.LantuUnionPay.pay({
	
	tn: "539872438627557871701"
	
}, (payResult) => {
	
	const { type, successPaySignData } = payResult;
	alert(`支付成功 ${ type } !`);
	
	console.log("仅有成功时返回: ", successPaySignData);
	
}, (payResult) => {
	
	const { type } = payResult;
	alert(`支付失败 ${ type }`);
	
});

```

### Todo 清单

- [ ] 兼容 cordova-android@7、cordova-android@8
- [ ] 补全 pkg.json 遗失的 cordova 版本等依赖
- [ ] IOS 安装时候提供 scheme variable 参数


### Release Log

+ v0.2.2: 实现 Android、IOS 核心支付方法, 并在 cordova@8、cordova-android@6.4.1 、cordova-ios@4.5.4 完成测试

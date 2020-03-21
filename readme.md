[![Build Status](https://travis-ci.org/coldbox-modules/pinpointsdk.svg?branch=master)](https://travis-ci.org/coldbox-modules/pinpointsdk)

# Welcome to the Amazon Pinpoint SDK

This SDK allows you to add Amazon Pinpoint capabilities to your ColdFusion (CFML) applications. It is also a ColdBox Module, so if you are using ColdBox, you get auto-registration and much more.

## Resources

* Pinpoint API Reference: https://docs.aws.amazon.com/pinpoint/latest/apireference/welcome.html

## Installation

This SDK can be installed as standalone or as a ColdBox Module.  Either approach requires a simple CommandBox command:

```bash
box install pinpointsdk
```

Then follow either the standalone or module instructions below.

### Standalone

This SDK will be installed into a directory called `pinpointsdk` and then the SDK can be instantiated via ` new pinpointsdk.models.AmazonPinPoint()` with the following constructor arguments:

```js
/**
 * Create a new PinPointSDK Instance
 *
 * @accessKey The Amazon access key.
 * @secretKey The Amazon secret key.
 * @awsRegion The Amazon region. Defaults to us-east-1
 * @awsDomain The Domain used PinPoint Service (amazonws.com). Defaults to amazonws.com
 * @encryption_charset The charset for the encryption. Defaults to UTF-8.
 * @ssl True if the request should use SSL. Defaults to true.
 * 
 * @return An AmazonPinPoint instance.
 */
public AmazonPinPoint function init(
	required string accessKey,
	required string secretKey,
	string awsRegion = "us-east-1",
	string awsDomain = "amazonaws.com",
	string encryption_charset = "UTF-8",
	boolean ssl = true
)
```

### ColdBox Module

This package also is a ColdBox module as well.  The module can be configured by creating an `pinpointsdk` configuration structure in your `moduleSettings` struct in the application configuration file: `config/Coldbox.cfc` with the following settings:

```js
moduleSettings = {
	pinpointsdk = {
		// Your amazon, digital ocean access key
		accessKey = "",
		// Your amazon, digital ocean secret key
		secretKey = "",
		// The default encryption character set: defaults to utf-8
		encryption_charset = "utf-8",
		// SSL mode or not on cfhttp calls: Defaults to true
		ssl = true,
		// Your AWS/Digital Ocean Region: Defaults to us-east-1
		awsregion = "us-east-1",
		// Your AWS/Digital Ocean Domain Mapping: defaults to amazonaws.com
		awsDomain = "amazonaws.com"
	}
};
```

Then you can leverage the SDK CFC via the injection DSL: `AmazonPinPoint@pinpointsdk`

/**
 * Copyright iSummation technologies Pvt. Ltd.
 * www.isummation.com
 * ---
 * This module connects your application to Amazon pinpoint
 **/
component {

	// Module Properties
	this.title 				= "Amazon Pinpoint SDK";
	this.author 			= "iSummation Technologies Pvt. Ltd";
	this.webURL 			= "https://www.isummation.com";
	this.description 		= "This SDK will provide you with Amazon Pinpoint connectivity for any ColdFusion (CFML) application.";
	// If true, looks for views in the parent first, if not found, then in the module. Else vice-versa
	this.viewParentLookup 	= true;
	// If true, looks for layouts in the parent first, if not found, then in module. Else vice-versa
	this.layoutParentLookup = true;
	this.autoMapModels 		= false;
	this.modelNamespace = "pinpointSDK";
	// CF Mapping
	this.cfmapping = "pinpointSDK";
	/**
	 * Configure
	 */
	function configure(){
		// Settings
		variables.settings = {
			accessKey           : "",
			secretKey           : "",
			encryption_charset  : "utf-8",
			ssl                 : true,
			awsregion           : "us-east-1",
			awsDomain 			: "amazonaws.com"
		};
	}

	/**
	 * Fired when the module is registered and activated.
	 */
	function onLoad(){
		binder.map( "AmazonPinPoint@pinpointsdk" )
			.to( "#moduleMapping#.models.AmazonPinpoint" )
			.initArg( name="accessKey", 			value=variables.settings.accessKey )
			.initArg( name="secretKey", 			value=variables.settings.secretKey )
			.initArg( name="encryption_charset", 	value=variables.settings.encryption_charset )
			.initArg( name="ssl", 					value=variables.settings.ssl )
			.initArg( name="awsRegion", 			value=variables.settings.awsregion )
			.initArg( name="awsDomain", 			value=variables.settings.awsDomain );

		binder.map( "Sv4Util@pinpointsdk" )
			.to( "#moduleMapping#.models.Sv4Util" )
			.initArg( name="accessKeyId", 			value=variables.settings.accessKey )
			.initArg( name="secretAccessKey", 		value=variables.settings.secretKey )
			.initArg( name="defaultRegionName", 	value=variables.settings.awsregion )
			.initArg( name="defaultServiceName",	value="pinpoint" );
	}

	/**
	* Fired when the module is unregistered and unloaded
	*/
	function onUnload(){
	}

}
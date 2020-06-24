/**
 ********************************************************************************
 * Copyright 2005-2007 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
 * www.coldboxframework.com | www.luismajano.com | www.ortussolutions.com
 ********************************************************************************
 *
 * Amazon Pinpoint REST Wrapper
 *
 * Written by Pritesh Patel (pritesh@isummation.com)
 * You will have to create some settings in your ColdBox configuration file:
 * Thanks to Coldbox module s3sdk developer, help me to start up this project.
 * Pinpoint_accessKey : The Amazon access key
 * Pinpoint_secretKey : The Amazon secret key
 * Pinpoint_encryption_charset : encryptyion charset (Optional, defaults to utf-8)
 * Pinpoint_ssl : Whether to use ssl on all cals or not (Optional, defaults to false)
 */
component accessors="true" singleton {

	// DI
	property name="log" inject="logbox:logger:{this}";

	// Properties
	property name="accessKey";
	property name="secretKey";
	property name="encryption_charset";
	property name="ssl";
	property name="URLEndpoint";
	property name="awsRegion";
	property name="awsDomain";
	property name="serviceName";

	/**
	 * Create a new PinpointSDK Instance
	 *
	 * @accessKey The Amazon access key.
	 * @secretKey The Amazon secret key.
	 * @awsRegion The Amazon region. Defaults to us-east-1
	 * @awsDomain The Domain used Pinpoint Service (amazonws.com, digitalocean.com). Defaults to amazonws.com
	 * @encryption_charset The charset for the encryption. Defaults to UTF-8.
	 * @ssl True if the request should use SSL. Defaults to true.
	 * @defaultDelimiter Delimter to use for getBucket calls. "/" is standard to treat keys as file paths
	 * @defaultBucketName Bucket name to use by default
	 *
	 * @return An AmazonPinpoint instance.
	 */
	AmazonPinpoint function init(
		required string accessKey,
		required string secretKey,
		string awsRegion          = "us-east-1",
		string awsDomain          = "amazonaws.com",
		string encryption_charset = "UTF-8",
		boolean ssl               = true,
		string defaultDelimiter   = "/",
		string defaultBucketName  = "",
		string serviceName        = "mobiletargeting"
	){
		variables.accessKey          = arguments.accessKey;
		variables.secretKey          = arguments.secretKey;
		variables.encryption_charset = arguments.encryption_charset;
		variables.awsRegion          = arguments.awsRegion;
		variables.awsDomain          = arguments.awsDomain;
		variables.serviceName        = arguments.serviceName;

		// Construct the SSL Domain
		setSSL( arguments.ssl );

		// Build out the endpoint URL
		buildUrlEndpoint();

		// Build signature utility
		variables.sv4Util = new Sv4Util();

		return this;
	}


	/**
	 * Set the Amazon Credentials.
	 *
	 * @accessKey The Amazon access key.
	 * @secretKey The Amazon secret key.
	 *
	 * @return    The AmazonPinpoint Instance.
	 */
	AmazonPinpoint function setAuth( required string accessKey, required string secretKey ){
		variables.accessKey = arguments.accessKey;
		variables.secretKey = arguments.secretKey;
		return this;
	}

	AmazonPinpoint function setAWSDomain( required string domain ){
		variables.awsDomain = arguments.domain;
		buildUrlEndpoint();
		return this;
	}

	AmazonPinpoint function setAWSRegion( required string region ){
		variables.awsRegion = arguments.region;
		buildUrlEndpoint();
		return this;
	}

	/**
	 * This function builds the variables.UrlEndpoint according to credentials and ssl configuration, usually called after init() for you automatically.
	 */
	AmazonPinpoint function buildUrlEndpoint(){
		// Build accordingly
		var URLEndPointProtocol = ( variables.ssl ) ? "https://" : "http://";
		variables.URLEndpoint   = ( variables.awsDomain contains "amazonaws.com" ) ? "#URLEndPointProtocol#pinpoint.#variables.awsRegion#.#variables.awsDomain#" : "#URLEndPointProtocol##variables.awsDomain#";
		return this;
	}

	/**
	 * Set the ssl flag.
	 * Alters the internal URL endpoint accordingly.
	 *
	 * @useSSL True if SSL should be used for the requests.
	 *
	 * @return The AmazonPinpoint instance.
	 */
	AmazonPinpoint function setSSL( boolean useSSL = true ){
		variables.ssl = arguments.useSSL;
		buildUrlEndpoint();
		return this;
	}

	/**
	 * Get phone information.
	 *
	 * @phoneNumber The phone number to retrieve information about. The phone number that you provide should include a valid numeric country code. Otherwise, the operation might result in an error.
	 * @countryCode The two-character code, in ISO 3166-1 alpha-2 format, for the country or region where the phone number was originally registered. 
	 * 
	 * @return The Pinpoint api response.
	 */
	any function validatePhone(
		required string phoneNumber,
		required string countryCode
	){
		var msgbody = {
			"PhoneNumber" : arguments.phoneNumber,
			"IsoCountryCode": arguments.countryCode			
		};

		var response = pinpointRequest(
			method   = "POST",
			resource = "/v1/phone/number/validate",
			body     = serializeJSON( msgbody )
		);
		return response;
	}
	/**
	 * Send SMS to set of mobile#s.
	 * Alters the internal URL endpoint accordingly.
	 *
	 * @appId   Pinpoint ApplicationId/ProjectId
	 * @sender    The number to send the SMS message from. This value should be one of the dedicated long or short codes that's assigned to your AWS account.
	 * @receivers     Array of receiver's email
	 * @body    The body of the SMS message.
	 * @traceId The unique identifier for tracing the message. This identifier is visible to message recipients.
	 * @senderId    The sender ID to display as the sender of the message on a recipient's device
	 * @messageType The SMS message type. Valid values are: TRANSACTIONAL,PROMOTIONAL
	 * @keyword     The SMS program name that you provided to AWS Support when you requested your dedicated number.
	 * @return The Pinpoint api response.
	 */
	any function sendTextMessage(
		required string appId,
		required array receivers,
		required string body,
		string sender,
		string traceId,
		string senderId,
		string messageType = "TRANSACTIONAL",
		string keyword
	){
		var mobileNos = {};
		arguments.receivers.map( function( mobileNo, index, arr ){
			mobileNos[ "#mobileNo#" ] = { "ChannelType" : "SMS" };
		} );
		var msgbody = {
			"MessageConfiguration" : {
				"SMSMessage" : {
					"Body"              : arguments.body,
					"OriginationNumber" : arguments.sender,
					"MessageType"       : arguments.messageType
				}
			},
			"Addresses" : mobileNos,
			
		};
		if ( structKeyExists( arguments, "traceId" ) ) {
			msgbody[ "TraceId" ] = arguments.traceId;
		}
		if ( structKeyExists( arguments, "senderId" ) ) {
			msgbody[ "MessageConfiguration" ][ "SMSMessage" ][ "SenderId" ] = arguments.senderId;
		}
		if ( structKeyExists( arguments, "keyword" ) ) {
			msgbody[ "MessageConfiguration" ][ "SMSMessage" ][ "Keyword" ] = arguments.keyword;
		}
		var response = pinpointRequest(
			method   = "POST",
			resource = "/v1/apps/#arguments.appId#/messages",
			body     = serializeJSON( msgbody )
		);
		return response;
	}
	
	/**
	 * Make a request to Amazon Pinpoint.
	 *
	 * @method     The HTTP method for the request.
	 * @resource   AWS API resource.
	 * @body       The body content of the request, if passed.
	 * @headers    A struct of HTTP headers to send.
	 * @amzHeaders A struct of special Amazon headers to send.
	 * @parameters A struct of HTTP URL parameters to send.
	 * @timeout    The default CFHTTP timeout.
	 * @throwOnError Flag to throw exceptions on any error or not, default is true
	 *
	 * @return     The response information.
	 */
	private struct function pinpointRequest(
		string method        = "GET",
		string resource      = "",
		any body             = "",
		struct headers       = {},
		struct amzHeaders    = {},
		struct parameters    = {},
		numeric timeout      = 20,
		boolean throwOnError = true
	){
		var results = {
			"error"          : false,
			"response"       : {},
			"message"        : "",
			"responseheader" : {}
		};
		var httpResults = "";
		var sortedAMZ   = listToArray( listSort( structKeyList( arguments.amzHeaders ), "textnocase" ) );

		// Default Content Type
		if ( NOT structKeyExists( arguments.headers, "content-type" ) ) {
			arguments.headers[ "Content-Type" ] = "";
		}

		// Prepare amz headers in sorted order
		for ( var x = 1; x <= arrayLen( sortedAMZ ); x++ ) {
			// Create amz signature string
			arguments.headers[ sortedAMZ[ x ] ] = arguments.amzHeaders[ sortedAMZ[ x ] ];
		}

		// Create Signature
		var signatureData = variables.sv4Util.generateSignatureData(
			requestMethod = arguments.method,
			// hostName 		= variables.URLEndpoint,
			hostName      = reReplaceNoCase(
				variables.URLEndpoint,
				"https?\:\/\/",
				""
			),
			requestURI     = arguments.resource,
			requestBody    = arguments.body,
			requestHeaders = arguments.headers,
			requestParams  = arguments.parameters,
			accessKey      = variables.accessKey,
			secretKey      = variables.secretKey,
			regionName     = variables.awsRegion,
			serviceName    = variables.serviceName
		);

		cfhttp(
			method   =arguments.method,
			url      ="#variables.URLEndPoint#/#arguments.resource#",
			charset  ="utf-8",
			result   ="httpResults",
			redirect =true,
			timeout  =arguments.timeout,
			useragent="ColdFusion-PinPointSDK"
		) {
			// Amazon Global Headers
			cfhttpparam(type="header", name="Date", value=signatureData.amzDate);

			cfhttpparam(type="header", name="Authorization", value=signatureData.authorizationHeader);

			for ( var headerName in signatureData.requestHeaders ) {
				cfhttpparam(type="header", name=headerName, value=signatureData.requestHeaders[ headerName ]);
			}

			for ( var paramName in signatureData.requestParams ) {
				cfhttpparam(type="URL", name=paramName, encoded=false, value=signatureData.requestParams[ paramName ]);
			}

			if ( len( arguments.body ) ) {
				cfhttpparam(type="body", value=arguments.body);
			}
		}

		if ( log.canDebug() ) {
			log.debug(
				"Amazon Rest Call ->Arguments: #arguments.toString()#, ->Encoded Signature=#signatureData.signature#",
				HTTPResults
			);
		}

		results.response       = HTTPResults.fileContent;
		results.responseHeader = HTTPResults.responseHeader;

		results.message = HTTPResults.errorDetail;
		if ( len( HTTPResults.errorDetail ) && HTTPResults.errorDetail neq "302 Found" ) {
			results.error = true;
		}

		// Check XML Parsing?
		if (
			structKeyExists( HTTPResults.responseHeader, "content-type" ) &&
			HTTPResults.responseHeader[ "content-type" ] == "application/xml" &&
			isXML( HTTPResults.fileContent )
		) {
			results.response = xmlParse( HTTPResults.fileContent );
			// Check for Errors
			if ( NOT listFindNoCase( "200,204,302", HTTPResults.responseHeader.status_code ) ) {
				results.error   = true;
				results.message = arrayToList(
					arrayMap( results.response.error.XmlChildren, function( node ){
						return "#node.XmlName#: #node.XmlText#";
					} ),
					"\n"
				);
			}
		}

		if ( results.error ) {
			log.error(
				"Amazon Rest Call ->Arguments: #arguments.toString()#, ->Encoded Signature=#signatureData.signature#",
				HTTPResults
			);
		}

		if ( results.error && arguments.throwOnError ) {
			/**
			writeDump( var=results );
			writeDump( var=signatureData );
			writeDump( var=arguments );
			writeDump( var=callStackGet() );
			abort;
			**/

			throw(
				type    = "PinpointSDKError",
				message = "Error making Amazon REST Call: #results.message#",
				detail  = serializeJSON( results.response )
			);
		}

		return results;
	}

	/**
	 * NSA SHA-1 Algorithm: RFC 2104HMAC-SHA1
	 */
	private binary function HMAC_SHA1( required string signKey, required string signMessage ){
		var jMsg = javacast( "string", arguments.signMessage ).getBytes( encryption_charset );
		var jKey = javacast( "string", arguments.signKey ).getBytes( encryption_charset );
		var key  = createObject( "java", "javax.crypto.spec.SecretKeySpec" ).init( jKey, "HmacSHA1" );
		var mac  = createObject( "java", "javax.crypto.Mac" ).getInstance( key.getAlgorithm() );

		mac.init( key );
		mac.update( jMsg );

		return mac.doFinal();
	}

}

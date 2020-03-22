component extends="coldbox.system.testing.BaseTestCase" {

	variables.targetEngine = getUtil().getSystemSetting( "ENGINE", "localhost" );
	variables.sender       = "+12057724xxx";
	variables.receiver     = [ "+12057724xxx" ];
	variables.appId        = "1f2573fbfe3b493f9bc75decf43ccad9";
	function beforeAll(){
		variables.pinpoint = new pinpointsdk.models.AmazonPinpoint(
			getUtil().getSystemSetting( "AWS_ACCESS_KEY" ),
			getUtil().getSystemSetting( "AWS_ACCESS_SECRET" ),
			getUtil().getSystemSetting( "AWS_REGION" ),
			getUtil().getSystemSetting( "AWS_DOMAIN" )
		);
		prepareMock( pinpoint );
		pinpoint.$property( propertyName = "log", mock = createLogStub() );
	}

	function afterAll(){
	}

	private function isOldACF(){
		return listFind( "11,2016", listFirst( server.coldfusion.productVersion ) );
	}

	function run(){
		describe( "Amazon pinpoint SDK", function(){
			describe( "objects", function(){
				afterEach( function( currentSpec ){
				} );

				it( "Send SMS", function(){
					var args = {
						appId       : variables.appId,
						sender      : variables.sender,
						receivers   : variables.receiver,
						body        : "Hello Visit http://bit.ly/me",
						traceId     : "#createUUID()#",
						messageType : "TRANSACTIONAL"
					};
					var md = pinpoint.sendTextMessage( argumentCollection = args );
					debug( md );
					expect( md ).notToBeEmpty();
				} );
			} );
		} );
	}

	private function createLogStub(){
		return createStub()
			.$( "canDebug", false )
			.$( "debug" )
			.$( "error" );
	}

}

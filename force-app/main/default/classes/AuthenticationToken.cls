global class AuthenticationToken {

	global String access_token {get; set;}
	global String token_type {get; set;}
	global Integer expires_in {get; set;}
	global String scope {get; set;}
	global String jti {get; set;}
	global String client_id {get; set;}
	global String version {get; set;}

	global Boolean isSuccess {get; set;}
	global String errorMesssage {get; set;}
	global String errorMessage {get; set;}

	global String requestBody {get; set;}
	global String responseBody {get; set;}
	
	// Erorr handler
	global Status status {get; set;}

	global class Status {
		global String code {get; set;}
		global String message {get; set;}

		global String parseToJSON() {
			return (String)System.JSON.Serialize(this);
		}
	}

	global AuthenticationToken(){
		this.access_token = '';
		this.token_type = '';
		this.expires_in = 0;
		this.scope = '';
		this.jti = '';
		this.client_id = '';
		this.version = '';

		this.isSuccess = false;
		this.errorMessage = '';
		this.requestBody = '';
		this.responseBody = '';
	}

	global static AuthenticationToken parse(String json) {
		return (AuthenticationToken) System.JSON.deserialize(json, AuthenticationToken.class);
	}
}
global class SmartBDMEnliteToken {

    global TokenRequest request;
    global TokenResponse response;

    global SmartBDMEnliteToken() {
        request = new TokenRequest();
        response = new TokenResponse();
    }

    global class TokenRequest {
        global Request GetTokenRequest {get; set;}

        global String parseJson() {
            return System.JSON.serialize(this);
        }
    }
    global class Request {
        global String ClientName {get; set;}
        global String UserName {get; set;}

        global Request(String clientName, String userName){
            this.ClientName = clientName;
            this.UserName = userName;            
        }
    }
    

    global class TokenResponse {
        global Response GetTokenResponse {get; set;}
        // Handler erorr
        global Status status {get; set;}

        global String parseJson() {
            return System.JSON.serialize(this);
        }

        global Response convertToObject(String responseBody) {
            Map<String, Object> mapBody = (Map<String, Object>)JSON.deserializeUntyped(responseBody);
            GetTokenResponse = (Response)JSON.deserialize(JSON.serialize(mapBody.get('GetTokenResponse')), Response.class);
            return GetTokenResponse;
        }
    }
    global class Response {
        global String Status {get; set;}
        global String TokenKey {get; set;}
        global Reconcile Reconcile {get; set;}
        // global Datetime endTime {get; set;}
    }
    global class Reconcile { 
        global Integer TotalCount {get; set;}
    }
    global class Status {
        // global String system {get; set;}
        global String code {get; set;}
        global String description {get; set;}
    }
}
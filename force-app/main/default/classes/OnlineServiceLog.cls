global class OnlineServiceLog {
    // global String serviceName {get;set;}
    global Boolean isSuccess {get;set;}
    global String errorMesssage {get;set;}
    global String requestBody {get;set;}
    global String responseBody {get;set;}
    global Datetime startTime {get;set;}
    global Datetime endTime {get;set;}
    global String rmId {get;set;}

    global String parseToJson(){
        return System.JSON.serialize(this);
    }

    global OnlineServiceLog(Boolean isSuccess, String requestBody, String responseBody) {
        this.isSuccess = isSuccess;
        this.errorMesssage = '';
        this.requestBody = requestBody;
        this.responseBody = responseBody;
    }

    global OnlineServiceLog(Boolean isSuccess, String errorMessage, String requestBody, String responseBody) {
        this.isSuccess = isSuccess;
        this.errorMesssage = errorMessage;
        this.requestBody = requestBody;
        this.responseBody = responseBody;
    }

    global OnlineServiceLog(Boolean isSuccess, String errorMessage, String requestBody, String responseBody, Datetime startTime, Datetime endTime) {
        this.isSuccess = isSuccess;
        this.errorMesssage = errorMessage;
        this.requestBody = requestBody;
        this.responseBody = responseBody;
        this.startTime = startTime;
        this.endTime = endTime;
    }
    global OnlineServiceLog(Boolean isSuccess, String errorMessage, String requestBody, String responseBody, String rmId) {
        this.isSuccess = isSuccess;
        this.errorMesssage = errorMessage;
        this.requestBody = requestBody;
        this.responseBody = responseBody;
        this.rmId = rmId;
    }
}
global class SmartBDMBusinessType {

    global Request Request;
    global Response Response;

    global class Request {
        global String endpoint {get;set;}
        global String fields {get;set;}
        global Integer initial {get;set;}
        global Integer to {get;set;}

        global Request() {
            fields = 'all';
            initial = 1;
            to = 100;
        }
        
        global String parseToURLParam() {
            return '?fields=' + this.fields + '&from=' + this.initial + '&to=' + this.to;
        }

        global String parseEndpoint() {
            return 'callout:' + this.endpoint + this.parseToURLParam();
        }

        global String parseToJSON() {
            return (String)System.JSON.Serialize(this);
        }
    }

    global class Response {
        global businessType businessType {get;set;}
        global String negative {get;set;}
        global String highRisk {get;set;}
        global String diversification {get;set;}
        global String suspend {get;set;}
        global String highlySelectiveIndustry {get;set;}

        global name name {get;set;}
        global String code {get;set;}
        global Integer arDay {get;set;}
        global Integer invDay {get;set;}
        global Integer apDay {get;set;}
        global String incomeFactor {get;set;}
        global String cogDay {get;set;}

        // Erorr handler
        global Status status {get; set;}
    }

    global class businessType {
        global String code {get;set;}
        global String name {get;set;}
        global String isicCode {get;set;}
        global String groupCode {get;set;}
        global String subGroup {get;set;}
    }

    global class name {
        global String th {get;set;}
        global String en {get;set;}
    }

    global SmartBDMBusinessType() {
        Request = new Request();
        Response = new Response();
    }

    global class Status {
        global String code {get; set;}
        global String message {get; set;}

        global String parseToJSON() {
            return (String)System.JSON.Serialize(this);
        }
    }

}
global class SmartBDMWorkingCapital {

    global Request request;
    global Response response;

    global class Request {
        global String businessGroupCode {get;set;}
        global Decimal salePerYear {get;set;}
        global Decimal tmbWcLimit {get;set;}

        global Request() {
            businessGroupCode = '';
            salePerYear = 0.0;
            tmbWcLimit = 0.0;
        }

        global String parseToJSON() {
            return (String)System.JSON.Serialize(this);
        }
    }

    global class Status {
        global String code {get; set;}
        global String message {get; set;}

        global String parseToJSON() {
            return (String)System.JSON.Serialize(this);
        }
    }

    global class Response {
        global Decimal wcLimit {get;set;}
        global Status status {get; set;}
    }

    global SmartBDMWorkingCapital() {
        request = new Request();
        response = new Response();
    }


}
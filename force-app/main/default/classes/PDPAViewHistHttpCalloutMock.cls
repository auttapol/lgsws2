@isTest
global class PDPAViewHistHttpCalloutMock implements HttpCalloutMock{
    global HTTPResponse respond(HTTPRequest request) {
        // Create a fake response
        System.debug('MockHttpCallout\n\n');
        System.debug('Request:'+request);
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json; charset=utf-8');
        response.setHeader('request-uid', '1563286287422');
        response.setHeader('request-datetime', DateTime.now().format('yyyy-MM-dd\'T\'HH:mm:ss'));
        
        String responseBody;
        
        responseBody = '{\n'+ '\"status\": {\n\"code\": \"0000\",\n\"description\": \"Success\"\n},\n'+
            '\"data\": {\n\"customerId\": \"00000000000500",\n'+
            '\"tcifNo\": \"\",\n'+
            '\"customerNo\": \"\",\n'+
            '\"consents\": [\n'+
            makeConsentString('MARKET','Y','20','MB','12345',Datetime.now().Adddays(-20),Date.toDay().Adddays(-20))+',\n'+
            makeConsentString('PDPA-DEPOSIT','Y','10','MEIB','12345',Datetime.now().Adddays(-10),Date.toDay().Adddays(-10))+',\n'+
            makeConsentString('MARKET','Y','11','MB','12345',Datetime.now().Adddays(-11),Date.toDay().Adddays(-11))+',\n'+
            makeConsentString('PDPA-DEPOSIT','N','1','MEIB','12345',Datetime.now().Adddays(-1),Date.toDay().Adddays(-1))+',\n'+
            makeConsentString('MARKET','Y','87','MB','12345',Datetime.now().Adddays(-87),Date.toDay().Adddays(-87))+',\n'+
            makeConsentString('PDPA-DEPOSIT','N','3','MEIB','12345',Datetime.now().Adddays(-3),Date.toDay().Adddays(-3))+',\n'+
            makeConsentString('MARKET','Y','5','MB','12345',Datetime.now().Adddays(-5),Date.toDay().Adddays(-5))+',\n'+
            makeConsentString('MARKET','N','16','MB','12345',Datetime.now().Adddays(-16),Date.toDay().Adddays(-16))+',\n'+
            makeConsentString('PDPA-DEPOSIT','Y','60','MB','12345',Datetime.now().Adddays(-60),Date.toDay().Adddays(-60))+',\n'+
            makeConsentString('PDPA-DEPOSIT','Y','70','MB','12345',Datetime.now().Adddays(-70),Date.toDay().Adddays(-70))+',\n'+
            makeConsentString('MARKET','Y','2','MEIB','12345',Datetime.now().Adddays(-2),Date.toDay().Adddays(-2))+
            '\n]\n}\n}';
		System.debug('json:'+responseBody+'\n');
        System.debug('Obj'+ PDPAStructure.parseJsontoObj(responseBody));
        /*
        responseBody ='{\n\"customerId\": \"001100000001100000000009399743",'+
            '\"customerNo\": \"\",'+
            '\"consents\": ['+
            makeConsentString('MARKET','Y','20','MB','9882741D',Datetime.now().Adddays(-20),Date.toDay().Adddays(-20))+',\n'+
            makeConsentString('PDPA-DEPOSIT','Y','10','MEIB','98750099',Datetime.now().Adddays(-10),Date.toDay().Adddays(-10))+',\n'+
            makeConsentString('MARKET','Y','11','MB','98750999',Datetime.now().Adddays(-11),Date.toDay().Adddays(-11))+',\n'+
            makeConsentString('PDPA-DEPOSIT','N','1','MEIB','98750749',Datetime.now().Adddays(-1),Date.toDay().Adddays(-1))+',\n'+
            makeConsentString('MARKET','Y','87','MB','98717259',Datetime.now().Adddays(-87),Date.toDay().Adddays(-87))+',\n'+
            makeConsentString('PDPA-DEPOSIT','N','3','MEIB','98750749',Datetime.now().Adddays(-3),Date.toDay().Adddays(-3))+',\n'+
            makeConsentString('MARKET','Y','5','MB','98750259',Datetime.now().Adddays(-5),Date.toDay().Adddays(-5))+',\n'+
            makeConsentString('MARKET','N','16','MB','98716259',Datetime.now().Adddays(-16),Date.toDay().Adddays(-16))+',\n'+
            makeConsentString('PDPA-DEPOSIT','Y','60','MB','98716259',Datetime.now().Adddays(-60),Date.toDay().Adddays(-60))+',\n'+
            makeConsentString('PDPA-DEPOSIT','Y','70','MB','98717259',Datetime.now().Adddays(-70),Date.toDay().Adddays(-70))+',\n'+
            makeConsentString('MARKET','Y','2','MEIB','98750749',Datetime.now().Adddays(-2),Date.toDay().Adddays(-2))+
            ']}';
        */
        System.debug('MockresponseBody: \n***********\n'+ responseBody);
        response.setBody(responseBody);
        response.setStatusCode(200);
        response.setStatus('success');
        response.setHeader('response-datetime', DateTime.now().format('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ'));
        System.debug('responseMock: \n***********\n'+response);
        return response; 
    }
    
    public String makeConsentString(String type,String flag, String version, String channel, String consentBy, Datetime consentDateTime, Date consentSignDate){
        String responseBody;
        String monthSpace = '';
        String daySpace = '';
        if(consentSignDate.month()<10){
            monthSpace = '0';
        }
        if(consentSignDate.day()<10){
            daySpace = '0';
        }
        responseBody = '{\n'+
            '\"type\": \"'+type+'\",\n'+				
            '\"flag\": \"'+flag+'\",\n'+				
            '\"version\": \"'+version+'\",\n'+				
            '\"consentDateTime\": \"'+consentDateTime.format('yyyy-MM-dd\'T\'HH:mm:ss')+'\",\n'+				
            '\"consentSignDate\": \"'+consentSignDate.year()+'-'+monthSpace+''+consentSignDate.month()+'-'+daySpace+''+consentSignDate.day()+'\",\n'+	
            '\"channel\": \"'+channel+'\",\n'+				
            '\"consentBy\": \"'+consentBy+'\"\n'+	
            '}';			
        return responseBody;
    }
}
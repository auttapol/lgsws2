public class ApiCallLightningComponent {

    public static String fetchUserSessionId(){
        String sessionId = '';
        // Refer to the Page
        PageReference reportPage = Page.GetSessionIdVF;
        // Get the content of the VF page
        String vfContent;
        if (!Test.isRunningTest()) { 
            vfContent = reportPage.getContent().toString();
            
            System.debug('vfContent '+vfContent);
            // Find the position of Start_Of_Session_Id and End_Of_Session_Id
            Integer startP = vfContent.indexOf('Start_Of_Session_Id') + 'Start_Of_Session_Id'.length(),
                endP = vfContent.indexOf('End_Of_Session_Id');
            // Get the Session Id
            sessionId = vfContent.substring(startP, endP);
        }
        System.debug('sessionId '+sessionId);
        // Return Session Id
        return sessionId;
    }
    
    static String restGet(String endPoint, String method, String sid) {
        String sessionId = fetchUserSessionId();       
        Http h = new Http();
        HttpRequest hr = new HttpRequest();
        hr.setHeader('Authorization', 'Bearer ' + sessionId);
        hr.setTimeout(60000);
        hr.setEndpoint(endPoint);
        hr.setMethod(method);
        
        HttpResponse r;
        if (!Test.isRunningTest()) { 
            r = h.send(hr);
        }
        else
        {
            r = new HttpResponse();
            r.setHeader('Content-Type', 'application/json');
            r.setHeader('Sforce-Auto-Assign', 'false');
            r.setBody(JSON.serialize(''));
            r.setStatusCode(200);
        }
        return r.getBody();
    }
    static String toolingAPISOQL( String query) {
        String baseURL = URL.getSalesforceBaseUrl().toExternalForm();
        return restGet( baseURL +
                       '/services/data/v41.0/tooling/query?q='+ (query.replace(' ', '+'))
                       ,
                       'GET', UserInfo.getSessionId() );
    } 
    
    public static String getLayoutNameForCurrentUserProfile(Id recordId,String objectName ) {
        String query = 'select RecordTypeId  from '+objectName+' where id =: recordId';
        List<sObject> getObject = Database.query(query);
        System.debug('getObject:'+getObject);
        String recordTypeId;
        if(getObject.size() > 0)
        {
            if(objectName == 'Account')
            {
                Account acc = (Account)getObject[0];
                recordTypeId = acc.recordTypeId;
            }
            else if(objectName == 'Contact')
            {
                Contact ct = (Contact)getObject[0];
                recordTypeId = ct.recordTypeId;
            } 
            else if(objectName == 'Lead')
            {
                Lead ld = (Lead)getObject[0];
                recordTypeId = ld.recordTypeId;
            }   
            else if(objectName == 'RTL_Referral__c')
            {
                RTL_Referral__c rf = (RTL_Referral__c)getObject[0];
                recordTypeId = rf.recordTypeId;
            }   
            else if(objectName == 'CampaignMember')
            {
                CampaignMember cm = (CampaignMember)getObject[0];
                recordTypeId = cm.recordTypeId;
            }   
        }
        String body = toolingAPISOQL('select Layout.Name from ProfileLayout where ProfileId = \'' + UserInfo.getProfileId() + '\' AND RecordTypeId = \'' + recordTypeId + '\'');
        System.debug('body: ' + body );
        String name = body.substringBetween('"Name":"', '"');
        System.debug('name: ' + name );
        return name;
    }
}
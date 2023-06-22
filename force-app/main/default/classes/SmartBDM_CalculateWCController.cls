global class SmartBDM_CalculateWCController {
    public String lightningBaseURL {get;set;}
    /* check if the VF page is display by SF1 */
    public Boolean isSF1 {
        get {                   
            if(String.isNotBlank(ApexPages.currentPage().getParameters().get('sfdcIFrameHost')) ||
                String.isNotBlank(ApexPages.currentPage().getParameters().get('sfdcIFrameOrigin')) ||
                ApexPages.currentPage().getParameters().get('isdtp') == 'p1' ||
                (ApexPages.currentPage().getParameters().get('retURL') != null && ApexPages.currentPage().getParameters().get('retURL').contains('projectone') )
            ) {
                return true;
            }else{
                return false;
            }
        }
    }

    public SmartBDM_CalculateWCController() {

        if (!isSF1) {
            String hostname = Url.getSalesforceBaseUrl().getHost();
            String myDomain = hostname.split('\\.')[0];
            if(myDomain.contains('--')) {
                //uses lastIndex to exclude namespace but include sandbox names
                // e.g. https://mydomain--sandbox--namespace.visualforce.com
                // and https://mydomain--namespace.visualforce.com
                myDomain = myDomain.substring(0, hostname.lastIndexOf('--'));
            }
            lightningBaseURL = 'https://' + myDomain + '.lightning.force.com';
            ApexPages.currentPage().getHeaders().put('X-Frame-Options', 'ALLOW-FROM ' + lightningBaseURL);
            ApexPages.currentPage().getHeaders().put('Content-Security-Policy', 'frame-ancestors ' + lightningBaseURL);
        }
    }

    @AuraEnabled
    public static List<String> getVFBaseURL() {
        String hostname = Url.getSalesforceBaseUrl().getHost();
        // will support prod and sandboxes
        // e.g. https://mydomain--sandbox.lightning.force.com
            // and https://mydomain.lightning.force.com
        System.debug(hostname);
        String myDomain = hostname.split('\\.')[0];
        // String namespace = SmartBDM_CalculateWCController.class.getName().split('\\.')[0];
        String namespace = 'c';

        System.debug('namespace :: ' + namespace);
        String pod = [SELECT InstanceName FROM Organization].InstanceName.toLowerCase();
        return new List<String>{
                'https://' + myDomain + '--' + namespace + '.visualforce.com',
                'https://' + myDomain + '--' + namespace + '.' + pod + '.visual.force.com'
        };
    }

    @AuraEnabled
    public static String getDeepLink(){
        return Smart_BDM_Constant.DEEP_LINK_TO_KONY_CAL_TOOLS;
    }

    global class WorkingCapitalWrapper {
        @AuraEnabled
        public Boolean isSuccess {get;set;}
        @AuraEnabled
        public String errorMessage {get;set;}
        @AuraEnabled
        public Decimal wcLimit {get;set;}
    }

    @AuraEnabled(cacheable=true)
    public static List<AggregateResult> getBusinessGroup() {
        List<String> filterCriteriaBusinessGroupTH = Smart_BDM_Constant.FIlTER_TYPE_CRITERIA_BUSINESS_GROUP_TH.split(',');
        return [SELECT BusinessGroupCode__c, BusinessGroupNameEN__c, BusinessGroupNameTH__c FROM IndustryMaster__c WHERE BusinessGroupNameTH__c NOT IN :filterCriteriaBusinessGroupTH AND BusinessGroupNameTH__c != null GROUP BY BusinessGroupCode__c, BusinessGroupNameEN__c, BusinessGroupNameTH__c ORDER BY BusinessGroupNameTH__c];
    }

    public class WorkingCapitalState {
        public String state {get;set;}
        public SmartBDMWorkingCapital.Request request {get;set;}
        public Datetime startTime {get;set;}

        public WorkingCapitalState(String state, SmartBDMWorkingCapital.Request reqWC, Datetime sTime){
            this.state = state;
            this.request = reqWC;
            this.startTime = sTime;
        }
    }

    // Action method
    // @RemoteAction
    @AuraEnabled(continuation=true)
    global static Object getWorkingCapitalContinuation(String businessGroupCode, Decimal salePerYear, Decimal tmbWcLimit){
        SmartBDMWorkingCapital.Request request = new SmartBDMWorkingCapital.Request();
        request.businessGroupCode = businessGroupCode == null ? '' : businessGroupCode;
        request.salePerYear = salePerYear == null ? 0 : salePerYear;
        request.tmbWcLimit = tmbWcLimit == null ? 0 : tmbWcLimit;
        return SmartBDM_Service.startCallGetCalculateWorkingCapitalContinuation(request);
    }

    // Callback method
    @AuraEnabled
    global static Object callBackGetCalculateWorkingCapitalContinuation(Object state) {
        WorkingCapitalState workingCapitalState = (WorkingCapitalState)state;
        return SmartBDM_Service.callBackGetCalculateWorkingCapitalContinuation(workingCapitalState.state, workingCapitalState.request, workingCapitalState.startTime);
    }
}
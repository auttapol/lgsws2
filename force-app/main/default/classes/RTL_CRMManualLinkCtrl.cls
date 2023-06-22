public class RTL_CRMManualLinkCtrl {

    public integer countNewReferral {get{
        if (countNewReferral == null){
            countNewReferral = 0;
        }
        return countNewReferral;
        
    }set;}
    
    public string reportPageReferral {get{
        if (reportPageReferral == null){
            reportPageReferral = '';
            
            profile pro = [select id,name from profile where id =: userinfo.getprofileID()];
            list<ReportProfileMapping__c> rpm = new list<ReportProfileMapping__c>();
                rpm = [select ReferralReportName__c from ReportProfileMapping__c 
                                           where isActive__c = true and ProfileName__c =: pro.name];
            if (rpm.size() == 0)
                rpm = [select ReferralReportName__c from ReportProfileMapping__c 
                                           where isActive__c = true and ProfileName__c = 'Default'];
                                           
            if (rpm.size() > 0 && rpm.get(0).ReferralReportName__c != null)
            {
                list<report> res = [select id from Report where DeveloperName =: rpm.get(0).ReferralReportName__c]; 
                if (res.size() > 0)
                    reportPageReferral = res.get(0).id;
            }

        }
        return reportPageReferral;
    }set;}
    
    public RTL_CRMManualLinkCtrl (){
		countNewReferral = [SELECT count() FROM RTL_Referral__c WHERE 
                            (RTL_Stage__c = 'New' OR RTL_Stage__c = 'In progress_contacted' ) AND 
                            (RTL_IsUserInQueue__c = true OR RTL_Is_Owner__c = true)];        
    }
}
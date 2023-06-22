public class CollateralReportExtension {

    public string AccId {get;set;}

    public CollateralReportExtension (apexPages.standardController sc)
    {
        account accTemp = (account)sc.getRecord();
        AccId = accTemp.id;
    }
    
    public class wrapperClass {
        public string groupType {get;set;}
        public decimal sumPledge {get;set;}
        public decimal sumAppraisal {get;set;}
        public list<Collateral_Detail__c> listCollateralDetail {get;set;}
        public wrapperClass (string gt, decimal sp, decimal sa, list<Collateral_Detail__c> lcd) {
            groupType = gt;
            sumPledge = sp;
            sumAppraisal = sa;
            listCollateralDetail = lcd;
        }
    }
    
    public list<wrapperClass> getCollateralData()
    {
        list<wrapperClass> retData = new list<wrapperClass>();
        list<string> collateralID = new list<string>();
        list<Collateral__c> listCollateral = new list<Collateral__c>();
        list<Collateral_Detail__c> listCollateralDetail = new list<Collateral_Detail__c>();
        
        for (Collateral__c co : [select Id,Account__c,Appraisal_Value__c,Pledge_Value__c,Collateral_Group_Type__c
                                 from Collateral__c where Account__c =: AccId])
        {
            collateralID.add(co.id);
            listCollateral.add(co);
        }
        
        for (Collateral_Detail__c cod : [select Name,Collateral_No__c,Collateral_Code__c,Reference__c,Pledge_Value__c
                                        ,Appraisal_Value__c,Appraisal_Date__c,Data_As_of__c,Collateral_Group_Type__c,Collateral__c, Collateral_Owner__c,Collateral_Joint__c,Collateral_Joint_BOT__c 
                                        from Collateral_Detail__c where Collateral__c in: collateralID])
        {
            listCollateralDetail.add(cod);
        }
        
        for (Collateral__c co : listCollateral)
        {
            list<Collateral_Detail__c> listColDtl = new list<Collateral_Detail__c>();
            for (Collateral_Detail__c cod : listCollateralDetail)
            {
                if (cod.Collateral__c == co.Id)
                {
                    listColDtl.add(cod);
                }
            }
            retData.add(new wrapperClass(co.Collateral_Group_Type__c, co.Pledge_Value__c, co.Appraisal_Value__c, listColDtl));
        }
        
        return retData;
    }
    
}
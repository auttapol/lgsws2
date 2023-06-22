public with sharing class TransferToBranchExtension {

	public RTL_Referral__c referral {get;set;}   
    public RTL_Referral__c newReferral {get;set;}

    public Boolean isValid {get;set;}

    public List<SelectOption> interestedProductList { get{
        if(interestedProductList == null){
            interestedProductList = new List<SelectOption>();
        }
        return interestedProductList;
    }set;}

    public List<SelectOption> interestedProductSelectedList { get{
        if(interestedProductSelectedList ==null){
            interestedProductSelectedList = new List<SelectOption>();
        }
        return interestedProductSelectedList;
    }set;}
    
    public Boolean hasError { get { return ApexPages.hasMessages(); } }
        

    private List<RTL_Referral__c> referralToUpsert;
    private String referToRetailId = Schema.SobjectType.RTL_Referral__c.getRecordTypeInfosByName().get('Refer to Retail').getRecordTypeId();

    public TransferToBranchExtension(ApexPages.StandardController stdController) {
        referral = (RTL_Referral__c)stdController.getRecord();
        referral = [SELECT Id,Name,RTL_Title__c,RTL_FirstName__c,RTL_LastName__c,
                          RTL_Company__c,RTL_Sales_Amount_Per_Year__c,RTL_Position__c,
                          RTL_Mobile1__c,RTL_Mobile2__c,RTL_Phone1__c,RTL_Ext__c,
                          RTL_Email__c,RTL_Account_Name__c,RTL_Type__c,RTL_Preferred_Branch__c,
                          RTL_Stage__c,RTL_Comment__c,RTL_EmployeeID__c,RTL_Employee_Name__c,
                          RTL_Channel_Segment__c 
                          FROM RTL_Referral__c 
                          WHERE Id=:referral.id];

        referralToUpsert = new List<RTL_Referral__c>();
        newReferral = new RTL_Referral__C();
        newReferral.RTL_Type__c = 'Account Opening/Service (เพื่อเปิดบัญชี / สมัครบริการ)';
        newReferral.RecordTypeId = referToRetailId;//'01290000001UROS';
        newReferral.RTL_Transfer_from_Referral_Id__c = referral.id;

        PicklistFieldController controller = new PicklistFieldController();
        Map<String,List<String>> valueMap = controller.getDependentOptionsImpl('RTL_Referral__c','RTL_Type__c','RTL_Interested_Product__c');
        List<String> interestedProductDependentList = new List<String>();
        if(valueMap.containsKey(newReferral.RTL_Type__c)){
            interestedProductDependentList = valueMap.get(newReferral.RTL_Type__c);
        }
        
        for(String option : interestedProductDependentList){
            interestedProductList.add(new SelectOption(option,option));
        }
        
    }

    public void validateReferral(){
        isvalid = true;
        String errorMessage = '';
        if(referral.RTL_Channel_Segment__c != 'Web' && referral.RTL_Channel_Segment__c != 'Biztouch'){
            isValid = false;
            errorMessage = System.Label.RTL_Referral_ERR018;
            
        }
        if(referral.RTL_Stage__c != 'New' && referral.RTL_Stage__c != 'In progress_Contacted' && referral.RTL_Stage__c != 'Closed (Interested)'){
            isValid = false;
            errorMessage = System.Label.RTL_Referral_ERR019;
        }

        if(isValid == false){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,errorMessage));
        }
        
    }

    public PageReference saveMobile(){
        if(interestedProductSelectedList.size() == 0){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Interested Product: You must enter a value'));
            return null;
        }

        String interestedProduct = '';
        Integer index =1;
            for(SelectOption selected : interestedProductSelectedList){
                interestedProduct += selected.getValue();
                if(index != interestedProductSelectedList.size()){
                    interestedProduct += '; ';
                }
            }
                
        newReferral.RTL_Interested_Product__c = interestedProduct;
        return  save();
    }

    public PageReference save(){
        isvalid = true;
        try{
            referral.RTL_Stage__c = 'Closed (Transferred)';
            referral.Is_Transfer_Page__c = true;
            copyReferralInfo(referral,newReferral);

            update referral;
            System.debug(newReferral);
            insert newReferral;
        
        }catch(Exception e){
            isValid = false;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,e.getMessage()));
            System.debug('ERROR Saving referral record :: '+e.getMessage());
        }
        // return null;
        return new PageReference('/'+newReferral.id);
    }

    public void copyReferralInfo(RTL_Referral__c sourceReferral,RTL_Referral__c destinationReferral){
        destinationReferral.RTL_Title__c = sourceReferral.RTL_Title__c;
        destinationReferral.RTL_FirstName__c = sourceReferral.RTL_FirstName__c;
        destinationReferral.RTL_LastName__c = sourceReferral.RTL_LastName__c;
        destinationReferral.RTL_Company__c = sourceReferral.RTL_Company__c;
        destinationReferral.RTL_Sales_Amount_Per_Year__c = sourceReferral.RTL_Sales_Amount_Per_Year__c;
        destinationReferral.RTL_Position__c = sourceReferral.RTL_Position__c;
        destinationReferral.RTL_Mobile1__c = sourceReferral.RTL_Mobile1__c;
        destinationReferral.RTL_Mobile2__c = sourceReferral.RTL_Mobile2__c;
        destinationReferral.RTL_Phone1__c = sourceReferral.RTL_Phone1__c;
        destinationReferral.RTL_Ext__c = sourceReferral.RTL_Ext__c;
        destinationReferral.RTL_Email__c = sourceReferral.RTL_Email__c;
        destinationReferral.RTL_Account_Name__c = sourceReferral.RTL_Account_Name__c;
        destinationReferral.RTL_Preferred_Branch__c = sourceReferral.RTL_Preferred_Branch__c;
        destinationReferral.RTL_Comment__c = sourceReferral.RTL_Comment__c;
        destinationReferral.RTL_EmployeeID__c = sourceReferral.RTL_EmployeeID__c;
        destinationReferral.RTL_Employee_Name__c = sourceReferral.RTL_Employee_Name__c;
        destinationReferral.RTL_Channel_Segment__c = sourceReferral.RTL_Channel_Segment__c;
                           
    }

}
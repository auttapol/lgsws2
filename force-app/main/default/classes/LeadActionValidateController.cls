public class LeadActionValidateController {

	// private final sObject mysObject;
    private Lead lead;
    private RTL_Referral__c referral;
    private String recordtypeId;
    private String ids;

    // The extension constructor initializes the private member
    // variable mysObject by using the getRecord method from the standard
    // controller.
    public LeadActionValidateController(ApexPages.StandardController stdController) {
        this.lead = (lead)stdController.getRecord();
        this.recordtypeId = ApexPages.currentPage().getParameters().get('RecordType');
        this.recordtypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Retail Banking').getRecordTypeId();
        this.ids = ApexPages.currentPage().getParameters().get('id');
    }

    public PageReference StatusQualifiedValidation(){
        PageReference pg;
        // Validate info qualified
        if(lead.Customer__c != null)
        {
            if(lead.Status == 'Qualified' && lead.RTL_Count_InterestedProducts_Primary__c == 1){
                pg = new PageReference('/apex/DuplicateAccount?Id=' + ids + '&parentpage=LeadDetail');

                pg.setRedirect(true);
                return pg;
            } else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.Qualified_Lead_Validation_ExistingCustomer_Error_Message));
            }
        }
        else 
        {                 
            if(lead.RTL_Mobile_Number__c != null && lead.RTL_ID_Type__c != null && lead.RTL_Citizen_Id__c != null && lead.Status == 'Qualified' && lead.RTL_Count_InterestedProducts_Primary__c == 1){
                pg = new PageReference('/apex/DuplicateAccount?Id=' + ids + '&parentpage=LeadDetail');

                // pg = new PageReference('/lead/leadconvert.jsp?retURL=%2F'+ this.ids +'&id=' + this.ids);

                pg.setRedirect(true);
                return pg;
            } else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.Qualified_Lead_Validation_Error_Message));
            }
        }
        return null;
    }

    public PageReference cancelLead(){
        PageReference leadHome = new PageReference('/00Q/o');
        if(null != lead.id) {
            leadHome = new PageReference('/'+lead.id);
        }
        leadHome.setRedirect(true);
        return leadHome;
    }

    public Integer getDisplayS1() {
      return (UserInfo.getUiThemeDisplayed() == 'Theme4t'? 1:2);
    }
}
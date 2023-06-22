public class SLOSProductLineItemProxyCtrl {
    private final ApexPages.StandardController std;
    private final Opportunity oppty;
    private List<RecordType> recTypes;
    //public String paramRec { get; set; }


    public SLOSProductLineItemProxyCtrl(ApexPages.StandardController controller) {
        std = controller;
        oppty = (Opportunity) std.getRecord();

        System.debug('Opportunity id is : '+ oppty.Id);
        //System.debug('RecordTypeId id is : '+ oppty.RecordTypeId);
        // Get Record TypeID and Name
        recTypes = [select Id, Name, sobjectType, DeveloperName from RecordType where Id = :oppty.RecordTypeId];
        //paramRec = ApexPages.currentPage().getParameters().get('RecordType');
    }
    public PageReference redirectPageAddProductLineItem() {
        system.debug(':::: Opportunity Id  = ' + oppty.Id);
        string url = '/';
        if (oppty.id != null) {

            if (recTypes[0].DeveloperName == 'SE_Credit_Product') {
                url = '/apex/AddOppProduct?id=' + oppty.Id;
            }
            else if (recTypes[0].DeveloperName == 'WBG_Non_credit_Product' || recTypes[0].DeveloperName == 'WBG_Credit_Product') {
                url = '/apex/AddProductLineItem?id=' + oppty.Id;
                
                //system.debug(ApexPages.currentPage().getParameters());                
                String theme = UserInfo.getUiThemeDisplayed();
                if(theme == 'Theme4u' || theme == 'Theme4t' || theme == 'Theme4d'){
                    url = '/apex/AddProductLineItem?id=' + oppty.Id;
                }
                else if (String.isNotBlank(ApexPages.currentPage().getParameters().get('sfdcIFrameHost')) 
                    || String.isNotBlank(ApexPages.currentPage().getParameters().get('sfdcIFrameOrigin')) 
                    || ApexPages.currentPage().getParameters().get('isdtp') == 'p1' 
                    || (ApexPages.currentPage().getParameters().get('retURL') != null && ApexPages.currentPage().getParameters().get('retURL').contains('projectone') )
                ){
                    if (ApexPages.currentPage().getParameters().get('isdtp') == 'p1'){
                        url = '/apex/AddProductLineItemMobile?id=' + oppty.Id;
                    }
                }

            } else {
                url = '/' + oppty.id ; 
            }

        }

        system.debug(':::: url  = ' + url);
        PageReference page = new PageReference(url);
        page.setRedirect(true);
        system.debug(page);
        return page;
    }

    public PageReference redirectPageEditAllProductLineItem() {
        system.debug(':::: Opportunity Id  = ' + oppty.Id);
        string url = '/';
        if (oppty.id != null) {

            if (recTypes[0].DeveloperName == 'SE_Credit_Product') {
                url = '/apex/SLOSEditAllOppProduct?id=' + oppty.Id;
            }
            else if (recTypes[0].DeveloperName == 'WBG_Non_credit_Product' || recTypes[0].DeveloperName == 'WBG_Credit_Product') {
                url = '/apex/EditOppProductAll?id=' + oppty.Id;
            }

        }

        system.debug(':::: url  = ' + url);
        PageReference page = new PageReference(url);
        page.setRedirect(true);
        return page;
    }


public PageReference redirectPageCloseWon() {
        system.debug(':::: Opportunity Id  = ' + oppty.Id);
        string url = '/';
        if (oppty.id != null) {

            if (recTypes[0].DeveloperName == 'SE_Credit_Product2' || recTypes[0].DeveloperName == 'SE_Credit_Product3') {
                url = '/apex/SLOSCloseWonOppProduct?id=' + oppty.Id;
            }
            else {  
                url = '/apex/CloseWonOppProduct?id=' + oppty.Id;
            }

        }
  
        system.debug(':::: url  = ' + url);
        PageReference page = new PageReference(url);
        page.setRedirect(true);
        return page; 
    }
    /*public PageReference redirectPageEditSingleProductLineItem() {
        system.debug(':::: Opportunity Id  = ' + oppty.Id);
        string url = '/';
        if (oppty.id != null) {

            if (recTypes[0].DeveloperName == 'SE_Credit_Product') {
                url = '/apex/SLOSEditAllOppProduct?id=' + oppty.Id;
            }
            else if (recTypes[0].DeveloperName == 'WBG_Non_credit_Product' || recTypes[0].DeveloperName == 'WBG_Credit_Product') {
                url = '/apex/EditOppProductAll?id=' + oppty.Id;
            }

        }

        system.debug(':::: url  = ' + url);
        PageReference page = new PageReference(url);
        page.setRedirect(true);
        return page;
    }*/
}
@isTest
public class MarketConductConsentPDFControllerTest {

    @isTest
    public static void testRenderPage() {
        Test.startTest();  

            PageReference pageRef = Page.MarketConductConsentPDF;
            Test.setCurrentPage(pageRef);
            pageRef.getParameters().put('ver', '10');
            pageRef.getParameters().put('type', 'PDPA');
            pageRef.getParameters().put('via', 'CRM-CC');
            pageRef.getParameters().put('name', null);
            pageRef.getParameters().put('grantdate', '12/02/2022');
            pageRef.getParameters().put('consentAccept', 'ยินยอม');
            pageRef.getParameters().put('emp', 'test@mock.com');
            pageRef.setRedirect(true);    
            
            MarketConductConsentPDFController ctl = new MarketConductConsentPDFController();
            ctl.renderPage();
        Test.stopTest();
    }
}
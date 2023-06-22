public class MarketConductConsentPDFController {
    public static String requestdate {get; set;}
    public String type {get; set;}
    public String ver {get; set;}
    public String name {get; set;}
    public String via {get; set;}
    public String grantdate {get; set;}
    public String consentAccept {get; set;}
    public String emp {get; set;}
    // public String lang {get; set;}
    
    public MarketConductConsentPDFController() {

    }

    private String replaceStr(String str) {
        if(str == 'null' || str == null) {
            str = '';
        } else if(str != '') {
            str = str.replace('+',' ');
        }

        return str;
    }

    public void renderPage() {
       requestdate = string.valueof(Datetime.now().format('dd/MM/YYYY'));
       ver = apexpages.currentpage().getparameters().get('ver');
       type = replaceStr(apexpages.currentpage().getparameters().get('type'));

       via = replaceStr(apexpages.currentpage().getparameters().get('via'));
       grantdate = apexpages.currentpage().getparameters().get('grantdate');
       
        name = replaceStr(apexpages.currentpage().getparameters().get('name'));
        consentAccept = replaceStr(apexpages.currentpage().getparameters().get('consentAccept'));
       emp = apexpages.currentpage().getparameters().get('emp');

       String fileName = 'Copy of consent.pdf';
    //    if(name == 'null' || name == null || name == '') {
    //         if(lang == 'en') {
    //             fileName = 'Copy of consent.pdf';
    //         } else {
    //             fileName = 'สำเนาการขอความยินยอมของ.pdf';
    //         }
    //    } else {
    //         if(lang == 'en') {
    //             fileName = 'Copy of consent of ' + name + '.pdf';
    //         } else {
    //             fileName = 'สำเนาการขอความยินยอมของคุณ ' + name + '.pdf';
    //         }
    //    }
       Apexpages.currentPage().getHeaders().put('content-disposition', 'inline; filename='+fileName);
    }

    

    
}
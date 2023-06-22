@isTest
public class InvestmentAcountDetailController_Test {
    private class getInvestment200Mockup implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setBody('{"product":{"GetInvestmentAccountRequest":{"FundCode":"JSM","UnitHolderNo":"PT000000000000173140"}},"GetInvestmentAccountDetailResponse":{"Result":{"Status":"SUCCESS","Message":"","InvestmentInformation":{"Status":"SUCCESS","Message":"","NumberOfUnit":"96.5456","CostOfInvestment":"1999.99","MarketValue":"2005.56","UnrealizedGL":"5.57","NAVUnit":"20.7732","AipInstruction":"No"},"InvestmentTransaction":{"Status":"SUCCESS","Message":""},"AutoInvestmentPlan":{"Status":"SUCCESS","Message":""}}},"Status":{"StatusCode":"200","StatusDesc":"success"},"InvestmentDetail":{"UnitHolderNo":"PT000000000000173140","FundCode":"JSM","ProductName":"กองทุนเปิด เจแปน สมอล แอนด์ มิด แคป ฟันด์","SubProductGroup":"NON MM","AssetClass":"FIF EQUITY","SeqGrp":"5","IssuerFundHouse":"UOB"}}');
            res.setStatusCode(200);
            return res;
        }
    }

    private class getInvestment401Mockup implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setBody('{"product":{"GetInvestmentAccountRequest":{"FundCode":"JSM","UnitHolderNo":"PT000000000000173140"}},"GetInvestmentAccountDetailResponse":{"Result":{"Status":"SUCCESS","Message":"","InvestmentInformation":{"Status":"SUCCESS","Message":"","NumberOfUnit":"96.5456","CostOfInvestment":"1999.99","MarketValue":"2005.56","UnrealizedGL":"5.57","NAVUnit":"20.7732","AipInstruction":"No"},"InvestmentTransaction":{"Status":"SUCCESS","Message":""},"AutoInvestmentPlan":{"Status":"SUCCESS","Message":""}}},"Status":{"StatusCode":"400","StatusDesc":"no endpoint"},"InvestmentDetail":{"UnitHolderNo":"PT000000000000173140","FundCode":"JSM","ProductName":"กองทุนเปิด เจแปน สมอล แอนด์ มิด แคป ฟันด์","SubProductGroup":"NON MM","AssetClass":"FIF EQUITY","SeqGrp":"5","IssuerFundHouse":"UOB"}}');
            res.setStatusCode(200);
            return res;
        }
    }

    private class getInvestment200ListMockup implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setBody('{"product":{"GetInvestmentAccountRequest":{"FundCode":"JSM","UnitHolderNo":"PT000000000000173140"}},"GetInvestmentAccountDetailResponse":{"Result":{"Status":"SUCCESS","Message":"","InvestmentInformation":{"Status":"SUCCESS","Message":"","NumberOfUnit":"96.5456","CostOfInvestment":"1999.99","MarketValue":"2005.56","UnrealizedGL":"5.57","NAVUnit":"20.7732","AipInstruction":"No"},"InvestmentTransaction":{"Status":"SUCCESS","Message":"", "InvestmentTransaction":[{"SettlementDate":"2022-07-25+07", "TransactionType":"", "InteractChannel":"", "UnitMovement":"", "TransactionValue":"", "ValuePerUnit":"", "Statue":""}]},"AutoInvestmentPlan":{"Status":"SUCCESS","Message":"", "AutoInvestmentPlan":[{"SinceDate":"2022-07-25+07", "CreatedChannel":"", "Frequency":"", "Date":"2022-07-25+0", "Balance":"", "SavingAccountBundling":""}, {"SinceDate":"2022-07-25+07", "CreatedChannel":"", "Frequency":"", "Date":"2022-07-25+0", "Balance":"", "SavingAccountBundling":""}]}}},"Status":{"StatusCode":"200","StatusDesc":"success"},"InvestmentDetail":{"UnitHolderNo":"PT000000000000173140","FundCode":"JSM","ProductName":"กองทุนเปิด เจแปน สมอล แอนด์ มิด แคป ฟันด์","SubProductGroup":"NON MM","AssetClass":"FIF EQUITY","SeqGrp":"5","IssuerFundHouse":"UOB"}}');
            res.setStatusCode(200);
            return res;
        }
    }

    private class getInvestment200ObjMockup implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setBody('{"product":{"GetInvestmentAccountRequest":{"FundCode":"JSM","UnitHolderNo":"PT000000000000173140"}},"GetInvestmentAccountDetailResponse":{"Result":{"Status":"SUCCESS","Message":"","InvestmentInformation":{"Status":"SUCCESS","Message":"","NumberOfUnit":"96.5456","CostOfInvestment":"1999.99","MarketValue":"2005.56","UnrealizedGL":"5.57","NAVUnit":"20.7732","AipInstruction":"No"},"InvestmentTransaction":{"Status":"SUCCESS","Message":"", "InvestmentTransaction":{"SettlementDate":"2022-07-25+07", "TransactionType":"", "InteractChannel":"", "UnitMovement":"", "TransactionValue":"", "ValuePerUnit":"", "Statue":""}},"AutoInvestmentPlan":{"Status":"SUCCESS","Message":"", "AutoInvestmentPlan":{"SinceDate":"2022-07-25+07", "CreatedChannel":"", "Frequency":"", "Date":"2022-07-25+0", "Balance":"", "SavingAccountBundling":""}}}},"Status":{"StatusCode":"200","StatusDesc":"success"},"InvestmentDetail":{"UnitHolderNo":"PT000000000000173140","FundCode":"JSM","ProductName":"กองทุนเปิด เจแปน สมอล แอนด์ มิด แคป ฟันด์","SubProductGroup":"NON MM","AssetClass":"FIF EQUITY","SeqGrp":"5","IssuerFundHouse":"UOB"}}');
            res.setStatusCode(200);
            return res;
        }
    }

    @isTest static void testGetInvestData200(){
        Test.setMock(HttpCalloutMock.class, new getInvestment200Mockup());
        Object returnMap = InvestmentAcountDetailController.getInvestmentDetailProduct('PT000000000000173140', 'JSM', '001p0000010nWtu', '001100000000000000000001601819');
    }

    @isTest static void testGetInvestData200Obj(){
        Test.setMock(HttpCalloutMock.class, new getInvestment200ObjMockup());
        Object returnMap = InvestmentAcountDetailController.getInvestmentDetailProduct('PT000000000000173140', 'JSM', '001p0000010nWtu', '001100000000000000000001601819');
    }

    @isTest static void testGetInvestData200List(){
        Test.setMock(HttpCalloutMock.class, new getInvestment200ListMockup());
        Object returnMap = InvestmentAcountDetailController.getInvestmentDetailProduct('PT000000000000173140', 'JSM', '001p0000010nWtu', '001100000000000000000001601819');
    }

    @isTest static void testGetInvestData401(){
        Test.setMock(HttpCalloutMock.class, new getInvestment401Mockup());
        Object returnMap = InvestmentAcountDetailController.getInvestmentDetailProduct('PT000000000000173140', 'JSM', '001p0000010nWtu', '001100000000000000000001601819');
    }

    @isTest static void testGenDateFormat(){
        String returnMap = InvestmentAcountDetailController.genDateFormat('2008-05-26+07:00');
    }

    @isTest static void testGenDateFormat2(){
        String returnMap = InvestmentAcountDetailController.genDateFormat('2008+05+26+07:00');
    }

    @isTest static void testGetCents(){
        String returnMap = InvestmentAcountDetailController.getCents(Decimal.valueOf('55577'));
    }

    @isTest static void testGetCents2(){
        String returnMap = InvestmentAcountDetailController.getCents(Decimal.valueOf('55577.66'));
    }

    @isTest static void testGetWaterMark(){
        String returnMap = InvestmentAcountDetailController.getWatermarkHTML();
    }

    @isTest static void testCalAVGCostPerUnit(){
        String returnMap = InvestmentAcountDetailController.calculateAverageCostPerUnit((Object) '22222', (Object) '111');
    }

    @isTest static void testCalAVGCostPerUnit2(){
        String returnMap = InvestmentAcountDetailController.calculateAverageCostPerUnit((Object) '22222', (Object) 111);
    }

    @isTest static void testCalUnrealizeGLPerc(){
        String returnMap = InvestmentAcountDetailController.calculateUnrealizedGLPerc((Object) '22222', (Object) '111', (Object) '333');
    }

    @isTest static void testCalUnrealizeGLPerc2(){
        String returnMap = InvestmentAcountDetailController.calculateUnrealizedGLPerc((Object) '22222', (Object) '111', (Object) 333);
    }
}
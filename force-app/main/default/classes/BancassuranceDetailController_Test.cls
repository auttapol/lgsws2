@IsTest
public class BancassuranceDetailController_Test extends AbstractCoreClass {

    private class getBancDetail200Mockup implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setBody('{"GetBancassuranceAccountDetailResponse":{"Result":{"Status":"SUCCESS","Message":"","BancassuranceInformation":{"Status":"SUCCESS","Message":"","ProductType":"LIFE INSURANCE","TMBProductCode":"En05","ProductName":"Smart Life 15/8","EffectiveDate":"2008-05-26+07:00","PolicyStatus":"Active","PolicyNo":"T00004644","SumInsured":"100000","AFYP":"25700","ExpiryDate":"2023-05-26+07:00","Sales":"14487"},"BancassuranceDetails":{"Status":"SUCCESS","Message":"","InsuranceCompany":"FWD Life Insurance"},"PaymentInformation":{"Status":"SUCCESS","Message":"","PaymentMode":"Annual","PremiumAmount":"25700","PaymentMethod":"Cheque","TotalPremiumPaid":"25700","YearOfPayment":" of 8","NumberOfTimePremiumPaid":"1"},"NextCashBackInformation":{"Status":"SUCCESS","Message":"","PaymentDate":"2018-05-16+07:00","Amount":"5000"},"InsuredPropertyAsset":{"Status":"SUCCESS","Message":"","Address":", , , , "},"InsuredAutomobileAsset":{"Status":"SUCCESS","Message":"","Brand":"","YearOfManufactured":"","Model":"","PlateNumber":""},"BeneficiaryInformation":{"Status":"SUCCESS","Message":"","Beneficiary":[{"Name":" ??????????????","Relationship":"คู่สมรส"},{"Name":"","Relationship":"น้อง"}]},"InsuranceClaimRecord":{"Status":"SUCCESS","Message":""}}},"Status":{"StatusCode":"200","StatusDesc":"success"}}');
            res.setStatusCode(200);
            return res;
        }
    }

    private class getBancDetail200WMockup2 implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setBody('{"GetBancassuranceAccountDetailResponse":{"Result":{"Status":"SUCCESS","Message":"","BancassuranceInformation":{"Status":"SUCCESS","Message":"","ProductType":"LIFE INSURANCE","TMBProductCode":"En05","ProductName":"Smart Life 15/8","EffectiveDate":"2008-05-26+07:00","PolicyStatus":"Active","PolicyNo":"T00004644","SumInsured":"100000","AFYP":"25700","ExpiryDate":"2023-05-26+07:00","Sales":"14487"},"BancassuranceDetails":{"Status":"SUCCESS","Message":"","InsuranceCompany":"FWD Life Insurance"},"PaymentInformation":{"Status":"SUCCESS","Message":"","PaymentMode":"Annual","PremiumAmount":"25700","PaymentMethod":"Cheque","TotalPremiumPaid":"25700","YearOfPayment":" of 8","NumberOfTimePremiumPaid":"1"},"NextCashBackInformation":{"Status":"SUCCESS","Message":"","PaymentDate":"2018-05-16+07:00","Amount":"5000"},"InsuredPropertyAsset":{"Status":"SUCCESS","Message":"","Address":", , , , "},"InsuredAutomobileAsset":{"Status":"SUCCESS","Message":"","Brand":"","YearOfManufactured":"","Model":"","PlateNumber":""},"BeneficiaryInformation":{"Status":"SUCCESS","Message":"","Beneficiary":{"Name":" ??????????????","Relationship":"คู่สมรส"}},"InsuranceClaimRecord":{"Status":"SUCCESS","Message":"", "ClaimRecord":[{"Date":"2018-05-16+07:00", "Type": "Something", "Description": "nothing", "RequestAmount" : "5000", "ApprovedAmount": "5000"}]}}},"Status":{"StatusCode":"200","StatusDesc":"success"}}');
            res.setStatusCode(200);
            return res;
        }
    }

    private class getBancDetail200WMockup3 implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setBody('{"GetBancassuranceAccountDetailResponse":{"Result":{"Status":"SUCCESS","Message":"","BancassuranceInformation":{"Status":"SUCCESS","Message":"","ProductType":"LIFE INSURANCE","TMBProductCode":"En05","ProductName":"Smart Life 15/8","EffectiveDate":"2008-05-26+07:00","PolicyStatus":"Active","PolicyNo":"T00004644","SumInsured":"100000","AFYP":"25700","ExpiryDate":"2023-05-26+07:00","Sales":"14487"},"BancassuranceDetails":{"Status":"SUCCESS","Message":"","InsuranceCompany":"FWD Life Insurance"},"PaymentInformation":{"Status":"SUCCESS","Message":"","PaymentMode":"Annual","PremiumAmount":"25700","PaymentMethod":"Cheque","TotalPremiumPaid":"25700","YearOfPayment":" of 8","NumberOfTimePremiumPaid":"1"},"NextCashBackInformation":{"Status":"SUCCESS","Message":"","PaymentDate":"2018-05-16+07:00","Amount":"5000"},"InsuredPropertyAsset":{"Status":"SUCCESS","Message":"","Address":", , , , "},"InsuredAutomobileAsset":{"Status":"SUCCESS","Message":"","Brand":"","YearOfManufactured":"","Model":"","PlateNumber":""},"BeneficiaryInformation":{"Status":"SUCCESS","Message":"","Beneficiary":{"Name":" ??????????????","Relationship":"คู่สมรส"}},"InsuranceClaimRecord":{"Status":"SUCCESS","Message":"", "ClaimRecord":{"Date":"2018-05-16+07:00", "Type": "Something", "Description": "nothing", "RequestAmount" : "5000", "ApprovedAmount": "5000"}}}},"Status":{"StatusCode":"200","StatusDesc":"success"}}');
            res.setStatusCode(200);
            return res;
        }
    }

    private class getBancDetail200WMockup4 implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setBody('{"GetBancassuranceAccountDetailResponse":{"Result":{"Status":"SUCCESS","Message":"","BancassuranceInformation":{},"BancassuranceDetails":{},"PaymentInformation":{"Status":"SUCCESS","Message":"","PaymentMode":"Annual","LastPaymentDate":"2018-05-16+07:00", "NextDueDate":"2018-05-16+07:00", "PremiumAmount":"25700","PaymentMethod":"Cheque","TotalPremiumPaid":"25700","YearOfPayment":" of 8","NumberOfTimePremiumPaid":"1"},"NextCashBackInformation":{},"InsuredPropertyAsset":{},"InsuredAutomobileAsset":{"Status":"SUCCESS","Message":"","Brand":"","YearOfManufactured":"","Model":"","PlateNumber":""},"BeneficiaryInformation":{"Status":"SUCCESS","Message":""},"InsuranceClaimRecord":{"Status":"SUCCESS","Message":"", "ClaimRecord":[{"Date":"2018-05-16+07:00", "Type": "Something", "Description": "nothing", "RequestAmount" : "5000", "ApprovedAmount": "5000"}]}}},"Status":{"StatusCode":"200","StatusDesc":"success"}}');
            res.setStatusCode(200);
            return res;
        }
    }

    private class getBancDetail200WMockup5 implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setBody('{"GetBancassuranceAccountDetailResponse":{"Result":{"Status":"SUCCESS","Message":"","BancassuranceInformation":{},"BancassuranceDetails":{},"PaymentInformation":{"Status":"SUCCESS","Message":"","PaymentMode":"Annual","LastPaymentDate":"2018%05%16%07%00", "NextDueDate":"05/05/05+07:00", "PremiumAmount":"25700","PaymentMethod":"Cheque","TotalPremiumPaid":"25700","YearOfPayment":" of 8","NumberOfTimePremiumPaid":"1"},"NextCashBackInformation":{},"InsuredPropertyAsset":{},"InsuredAutomobileAsset":{"Status":"SUCCESS","Message":"","Brand":"","YearOfManufactured":"","Model":"","PlateNumber":""},"BeneficiaryInformation":{"Status":"SUCCESS","Message":""},"InsuranceClaimRecord":{"Status":"SUCCESS","Message":"", "ClaimRecord":[{"Date":"2018-05-16+07:00", "Type": "Something", "Description": "nothing", "RequestAmount" : "5000", "ApprovedAmount": "5000"}]}}},"Status":{"StatusCode":"200","StatusDesc":"success"}}');
            res.setStatusCode(200);
            return res;
        }
    }

    private class getBancDetail400Mockup implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setBody('{"Status":{"StatusCode":"400","StatusDesc":"Sorry, some error occurred while getting information."},"GetBancassuranceAccountResponse":{}}');
            res.setStatusCode(200);
            return res;
        }
    }

    @isTest static void testGetBancDetailData200(){
        Test.setMock(HttpCalloutMock.class, new getBancDetail200Mockup());
        Object returnMap = BancassuranceDetailController.getBancDetailData('1150', 'T00004644', '001p0000010nXLSAA2', '001100000000000000000000051187');
    }

    @isTest static void testGetBancDetailData2002(){
        Test.setMock(HttpCalloutMock.class, new getBancDetail200WMockup2());
        Object returnMap = BancassuranceDetailController.getBancDetailData('1150', 'T00004644', '001p0000010nXLSAA2', '001100000000000000000000051187');
    }

    @isTest static void testGetBancDetailData2003(){
        Test.setMock(HttpCalloutMock.class, new getBancDetail200WMockup3());
        Object returnMap = BancassuranceDetailController.getBancDetailData('1150', 'T00004644', '001p0000010nXLSAA2', '001100000000000000000000051187');
    }

    @isTest static void testGetBancDetailData2004(){
        Test.setMock(HttpCalloutMock.class, new getBancDetail200WMockup4());
        Object returnMap = BancassuranceDetailController.getBancDetailData('1150', 'T00004644', '001p0000010nXLSAA2', '001100000000000000000000051187');
    }

    @isTest static void testGetBancDetailData2005(){
        Test.setMock(HttpCalloutMock.class, new getBancDetail200WMockup5());
        Object returnMap = BancassuranceDetailController.getBancDetailData('1150', 'T00004644', '001p0000010nXLSAA2', '001100000000000000000000051187');
    }

    @isTest static void testGetBancDetailData400(){
        Test.setMock(HttpCalloutMock.class, new getBancDetail400Mockup());
        Object returnMap = BancassuranceDetailController.getBancDetailData('1150', 'T00004644', '001p0000010nXLSAA2', '001100000000000000000000051187');
    }

    @isTest static void testGetUnmask(){
        String returnMap = BancassuranceDetailController.getUnmaskBalance();
    }

    @isTest static void testGetWaterMark(){
        String returnMap = BancassuranceDetailController.getWatermark();
    }

    @isTest static void testGetMakeValue(){
        String returnMap = BancassuranceDetailController.getMakeValue('something', 'hello world');
    }

    @isTest static void testGenDateFormat(){
        String returnMap = BancassuranceDetailController.genDateFormat('2008-05-26+07:00');
    }

    @isTest static void testGenDateFormat2(){
        String returnMap = BancassuranceDetailController.genDateFormat('2008+05+26+07:00');
    }

    @isTest static void testGetCents(){
        String returnMap = BancassuranceDetailController.getCents(Decimal.valueOf('55577'));
    }

    @isTest static void testGetCents2(){
        String returnMap = BancassuranceDetailController.getCents(Decimal.valueOf('1666666.66'));
    }
}
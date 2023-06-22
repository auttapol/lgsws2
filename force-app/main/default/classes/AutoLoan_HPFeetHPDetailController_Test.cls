@isTest
public class AutoLoan_HPFeetHPDetailController_Test extends AbstractCoreClass {

    private class getAutoLoan200Mockup implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setBody('{"isError":false,"Output":[{"ContractNo":"252016203974","CustomerCode":"1844976","ContractDate10":"28/02/2562","DealerName":"บจก. 107993 ชื่อผูเ้ช่าซื้อ 107993 นามสกุล","CarpriceAmt":"605000.00","HPTotalAmount":"350016.00","InstallmentAmount":"7292.00","InterestedRate":".00","TotalInstallments":"48","CurrentOfInstallments":"48","NumberOfInstallmentBalance":"0","CarBrandName":"MAZDA","CarModel":"2","CarColorName":"แดง","ProductCarType":"รถใหม่","FinancialAmount":"350000.00","OverdueAmount":"0.77","PenaltyAmount":"0.00","OverdueNo":"0","HubOwnerName":"งามวงศ์วาน","ProductCode":"NEW","LastDueDate":"10/03/2566","MarketingOfficerName":"น.ส. 3867038 ชื่อผูเ้ช่าซื้อ 3867038 นามสกุล","CarDownAmt":"255000.00","DueDay":"10","PaymentMethodDesc":"2 :Auto Debit","FirstInstallmentDate10":"10/04/2562","OutstandingAmount":"0.00","ContractStatusCode":"92","ContractStatusName":"ปิดสัญญาล่วงหน้า","CarYear":"2019","CarTypeDesc":"เก๋ง 2 ตอน","CarRegno":"8กส745","CarRegProv":"กรุงเทพ ฯ","CarChasis":"MM8DJ2H3A0W428926","CarEngno":"P350338083","CarEngineSize":"1299","GuarantorName1":"","GuarantorBD1":"","GuarantorIDNo1":"","GuarantorName2":"","GuarantorBD2":"","GuarantorIDNo2":"","GuarantorName3":"","GuarantorBD3":"","GuarantorIDNo3":"","GuarantorName4":"","GuarantorBD4":"","GuarantorIDNo4":""}],"RES":{"RESPONSECODE":"HP001","RESPONSEMESSAGE":"Successful response"},"HTTPStatusCode":200}');
            res.setStatusCode(200);
            return res;
        }
    }

    private class getAutoLoan200Mockup2 implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setBody('{"isError":false,"Output":[{"ContractNo":"252016203974","CustomerCode":"1844976","ContractDate10":"28/02/2562","DealerName":"บจก. 107993 ชื่อผูเ้ช่าซื้อ 107993 นามสกุล","CarpriceAmt":"605000.00","HPTotalAmount":"350016.00","InstallmentAmount":"7292.00","InterestedRate":".00","TotalInstallments":"48","CurrentOfInstallments":"48","NumberOfInstallmentBalance":"0","CarBrandName":"MAZDA","CarModel":"2","CarColorName":"แดง","ProductCarType":"รถใหม่","FinancialAmount":"350000.00","OverdueAmount":"0.77","PenaltyAmount":"0.00","OverdueNo":"0","HubOwnerName":"งามวงศ์วาน","ProductCode":"NEW","LastDueDate":"10/03/2566","MarketingOfficerName":"น.ส. 3867038 ชื่อผูเ้ช่าซื้อ 3867038 นามสกุล","CarDownAmt":"255000.00","DueDay":"10","PaymentMethodDesc":"2 :Auto Debit","FirstInstallmentDate10":"10/04/2562","OutstandingAmount":"0.00","ContractStatusCode":"92","ContractStatusName":"ปิดสัญญาล่วงหน้า","CarYear":"2019","CarTypeDesc":"เก๋ง 2 ตอน","CarRegno":"8กส745","CarRegProv":"กรุงเทพ ฯ","CarChasis":"MM8DJ2H3A0W428926","CarEngno":"P350338083","CarEngineSize":"1299","GuarantorName1":"","GuarantorBD1":"28+02+2562","GuarantorIDNo1":"","GuarantorName2":"","GuarantorBD2":"28%02%2562","GuarantorIDNo2":"","GuarantorName3":"","GuarantorBD3":"28(02(2562","GuarantorIDNo3":"","GuarantorName4":"","GuarantorBD4":"28#02#2562","GuarantorIDNo4":""}],"RES":{"RESPONSECODE":"HP001","RESPONSEMESSAGE":"Successful response"},"HTTPStatusCode":200}');
            res.setStatusCode(200);
            return res;
        }
    }

    private class getAutoLoan200Mockup3 implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setBody('{"isError":false,"Output":[{"ContractNo":"252016203974","CustomerCode":"1844976","ContractDate10":"28/02/2562","DealerName":"บจก. 107993 ชื่อผูเ้ช่าซื้อ 107993 นามสกุล","CarpriceAmt":"605000.00","HPTotalAmount":"350016.00","InstallmentAmount":"7292.00","InterestedRate":".00","TotalInstallments":"48","CurrentOfInstallments":"48","NumberOfInstallmentBalance":"0","CarBrandName":"MAZDA","CarModel":"2","CarColorName":"แดง","ProductCarType":"รถใหม่","FinancialAmount":"350000.00","OverdueAmount":"0.77","PenaltyAmount":"0.00","OverdueNo":"0","HubOwnerName":"งามวงศ์วาน","ProductCode":"NEW","LastDueDate":"10/03/2566","MarketingOfficerName":"น.ส. 3867038 ชื่อผูเ้ช่าซื้อ 3867038 นามสกุล","CarDownAmt":"255000.00","DueDay":"10","PaymentMethodDesc":"2 :Auto Debit","FirstInstallmentDate10":"10/04/2562","OutstandingAmount":"0.00","ContractStatusCode":"92","ContractStatusName":"ปิดสัญญาล่วงหน้า","CarYear":"2019","CarTypeDesc":"เก๋ง 2 ตอน","CarRegno":"8กส745","CarRegProv":"กรุงเทพ ฯ","CarChasis":"MM8DJ2H3A0W428926","CarEngno":"P350338083","CarEngineSize":"1299","GuarantorName1":"","GuarantorBD1":"2562/31/12","GuarantorIDNo1":"","GuarantorName2":"","GuarantorBD2":"2562/2562/2562","GuarantorIDNo2":"","GuarantorName3":"","GuarantorBD3":"05/30/12","GuarantorIDNo3":"","GuarantorName4":"","GuarantorBD4":"05/05/05","GuarantorIDNo4":""}],"RES":{"RESPONSECODE":"HP001","RESPONSEMESSAGE":"Successful response"},"HTTPStatusCode":200}');
            res.setStatusCode(200);
            return res;
        }
    }

    private class getAutoLoan200Mockup4 implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setBody('{"isError":false,"Output":[{"ContractNo":"252016203974","CustomerCode":"1844976","ContractDate10":"28/02/2562","DealerName":"บจก. 107993 ชื่อผูเ้ช่าซื้อ 107993 นามสกุล","CarpriceAmt":"605000.00","HPTotalAmount":"350016.00","InstallmentAmount":"7292.00","InterestedRate":".00","TotalInstallments":"48","CurrentOfInstallments":"48","NumberOfInstallmentBalance":"0","CarBrandName":"MAZDA","CarModel":"2","CarColorName":"แดง","ProductCarType":"รถใหม่","FinancialAmount":"350000.00","OverdueAmount":"0.77","PenaltyAmount":"0.00","OverdueNo":"0","HubOwnerName":"งามวงศ์วาน","ProductCode":"NEW","LastDueDate":"10/03/2566","MarketingOfficerName":"น.ส. 3867038 ชื่อผูเ้ช่าซื้อ 3867038 นามสกุล","CarDownAmt":"255000.00","DueDay":"10","PaymentMethodDesc":"2 :Auto Debit","FirstInstallmentDate10":"10/04/2562","OutstandingAmount":"0.00","ContractStatusCode":"92","ContractStatusName":"ปิดสัญญาล่วงหน้า","CarYear":"2019","CarTypeDesc":"เก๋ง 2 ตอน","CarRegno":"8กส745","CarRegProv":"กรุงเทพ ฯ","CarChasis":"MM8DJ2H3A0W428926","CarEngno":"P350338083","CarEngineSize":"1299","GuarantorName1":"","GuarantorBD1":"28/02/2562","GuarantorIDNo1":"","GuarantorName2":"","GuarantorBD2":"28/02/2562","GuarantorIDNo2":"","GuarantorName3":"","GuarantorBD3":"28/02/2562","GuarantorIDNo3":"","GuarantorName4":"","GuarantorBD4":"28/02/2562","GuarantorIDNo4":""}],"RES":{"RESPONSECODE":"HP001","RESPONSEMESSAGE":"Successful response"},"HTTPStatusCode":200}');
            res.setStatusCode(200);
            return res;
        }
    }

    private class getAutoLoan401Mockup implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setBody('{"isError":true,"Output":[],"RES":{"RESPONSECODE":"","RESPONSEMESSAGE":"unauthorize response"}}');
            res.setStatusCode(400);
            return res;
        }
    }

    @isTest static void testGetBancDetailData200(){
        Test.setMock(HttpCalloutMock.class, new getAutoLoan200Mockup());
        Object returnMap = AutoLoan_HPFeetHPDetailController.getHPFeetDetail('TBANK', '252016203974', '20221129', '03134487', '001p0000010nWtu', '001100000000000000000001601819');
    }

    @isTest static void testGetBancDetailData2002(){
        Test.setMock(HttpCalloutMock.class, new getAutoLoan200Mockup2());
        Object returnMap = AutoLoan_HPFeetHPDetailController.getHPFeetDetail('TBANK', '252016203974', '20221129', '03134487', '001p0000010nWtu', '001100000000000000000001601819');
    }

    @isTest static void testGetBancDetailData2003(){
        Test.setMock(HttpCalloutMock.class, new getAutoLoan200Mockup3());
        Object returnMap = AutoLoan_HPFeetHPDetailController.getHPFeetDetail('TBANK', '252016203974', '20221129', '03134487', '001p0000010nWtu', '001100000000000000000001601819');
    }

    @isTest static void testGetBancDetailData2004(){
        Test.setMock(HttpCalloutMock.class, new getAutoLoan200Mockup4());
        Object returnMap = AutoLoan_HPFeetHPDetailController.getHPFeetDetail('TBANK', '252016203974', '20221129', '03134487', '001p0000010nWtu', '001100000000000000000001601819');
    }

    @isTest static void testGetBancDetailData401(){
        Test.setMock(HttpCalloutMock.class, new getAutoLoan401Mockup());
        Object returnMap = AutoLoan_HPFeetHPDetailController.getHPFeetDetail('TBANK', '252016203974', '20221129', '03134487', '001p0000010nWtu', '001100000000000000000001601819');
    }

    @isTest static void testGetUnmaskBalance(){
        String returnMap = AutoLoan_HPFeetHPDetailController.getUnmaskBalance();
    }

    @isTest static void testGetCents(){
        String returnMap = AutoLoan_HPFeetHPDetailController.getCents(Decimal.valueOf('55577'));
    }

    @isTest static void testGetCents2(){
        String returnMap = AutoLoan_HPFeetHPDetailController.getCents(Decimal.valueOf('1666666.66'));
    }

    @isTest static void testGetCents3(){
        String returnMap = AutoLoan_HPFeetHPDetailController.maskWithXX('0');
    }

    @isTest static void testGetCents4(){
        String returnMap = AutoLoan_HPFeetHPDetailController.maskWithXX('88');
    }

    @isTest static void testMarkContractNo(){
        String returnMap = AutoLoan_HPFeetHPDetailController.maskContractNo('252016203974');
    }

    @isTest static void testMaskWithXX(){
        String returnMap = AutoLoan_HPFeetHPDetailController.maskWithXX('6000000');
    }
    
}
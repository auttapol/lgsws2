@istest
public class SLOSSoapServiceTest {

    public static testmethod void myUnitTest(){
        Test.setMock(WebServiceMock.class, new SLOSSoapServiceMockImp());
        
        try{
            Test.startTest();
        SLOSSoapService.CreateOpportunityRequest opptyRequest = new SLOSSoapService.CreateOpportunityRequest();
        new SLOSSoapService.FacilityInfoRequest();
        new SLOSSoapService.FacilityInfos_element();
        new SLOSSoapService.CreateOpportunityResponse_element();
        new SLOSSoapService.OpportunityResponse();
            
        SLOSSoapService.SlsServicesPort servicesPort = new SLOSSoapService.SlsServicesPort();
        SLOSSoapService.OpportunityResponse response =   servicesPort.CreateOpportunity(opptyRequest);
        SLOSSoapService.FacilityInfoRequest fopptyRequest = new SLOSSoapService.FacilityInfoRequest();
        SLOSSoapService.FacilityInfoRequest fresponse =   new SLOSSoapService.FacilityInfoRequest();
            test.stopTest();
        }catch(Exception e){
            System.debug(e.getMessage());
        }
       
    }
}
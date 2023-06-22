global with sharing class SLOSServiceImpl implements SLOSServiceBroker.ISLOSService {
    global SLOSContext.SLOSRespond sendRequest(SLOSContext.SLOSRequest slosReq) {
       // Call SLS Soap Service here

        SLOSContext.MulesoftDTO ms = slosReq.m_mulesoftDto;

        SLOSSoapService.CreateOpportunityRequest wrapRequest = new SLOSSoapService.CreateOpportunityRequest();
        wrapRequest.JobName = ms.jobName;
        wrapRequest.CaNumber = ms.caNumber;
        wrapRequest.OldCaNumber = '';
        wrapRequest.AccountNo1 = '';
        wrapRequest.CustomerId = ms.customerId;
        wrapRequest.CustomerName = ms.customerName;
        wrapRequest.CitizenId = ms.citizenId;
        wrapRequest.RequestType = ms.requestType;
        wrapRequest.CustomerType = ms.customerType;
        wrapRequest.BdmId = ms.bdmId;
        wrapRequest.HubCode = ms.hubCode;
        wrapRequest.RegionCode = ms.regionCode;
        wrapRequest.UwId = '';
        wrapRequest.AppInDateBDM = ms.appInDateBDM;
        wrapRequest.FinalApproved_x = '';
        wrapRequest.Parallel_x = ms.parallel_c;
        wrapRequest.Pending = '';
        wrapRequest.CaExist = '';
        wrapRequest.CaEnd = '';
        wrapRequest.AccountNo2 = '';
        wrapRequest.AccountNo3 = '';
        wrapRequest.AccountNo4 = '';
        wrapRequest.AccountNo5 = '';
        wrapRequest.AccountNo6 = '';
        wrapRequest.AccountNo7 = '';
        wrapRequest.AccountNo8 = '';
        wrapRequest.AccountNo9 = '';
        wrapRequest.AccountNo10 = '';
        wrapRequest.AppInDateUW = '';
        wrapRequest.RefAppNumber = ms.appRefNumber;
        wrapRequest.Reason = '';
        wrapRequest.CheckNCB = '';
        wrapRequest.Ssoid = '';
        /*SLS Mobility*/
        wrapRequest.MobileNo = ms.mobileNo;
        wrapRequest.Province = ms.province;
        wrapRequest.District = ms.district;
        wrapRequest.SubDistrict = ms.subDistrict; 
        wrapRequest.ZipCode = ms.zipCode;
        wrapRequest.Country = ms.country;
        wrapRequest.SaleAmount = ms.saleAmount;
        wrapRequest.YearInBusiness = ms.yearInBusiness;
        wrapRequest.ProductGroupId = ms.productGroupId;
        wrapRequest.FacilityInfos = ms.facilityInfos;
        
        system.debug(wrapRequest);
        
        SLOSSoapService.SlsServicesPort SLOSSoap = new SLOSSoapService.SlsServicesPort();        
        SLOSSoapService.OpportunityResponse SLOSResponse = SLOSSoap.CreateOpportunity(wrapRequest);

        system.debug(SLOSResponse);

        SLOSContext.SLOSRespond ret = new SLOSContext.SLOSRespond();
        ret.Message     = SLOSResponse.Message;
        ret.ErrorCode   = SLOSResponse.Code;
        ret.Status      = (SLOSResponse.Status.toLowerCase().contains('success')) ? true : false;//true;
        ret.AppRefNo    = SLOSResponse.AppRefNumber;
        return ret ;
    }
}
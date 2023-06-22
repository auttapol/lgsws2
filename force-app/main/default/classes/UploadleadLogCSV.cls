public class UploadleadLogCSV {
    
    public transient List<UploadLead> logsuccess      {get; set;}
    public transient List<UploadLead> logerror        {get; set;}
    public transient List<UploadLead> logall          {get; set;}
    public transient LeadLogHeader__c header  {get; set;}
    
    public void logdetail() {
        String logheader ='';
        logheader = ApexPages.currentPage().getParameters().get('idname');
        system.debug('##idname = '+logheader); 
        
        logall      = new List<Uploadlead>();
        logsuccess  = new List<UploadLead>();
        logerror    = new List<UploadLead>();
        header      = new LeadLogHeader__c();
        
        header = [Select Id,name from LeadLogHeader__c where Id =: logheader];
        List<LeadLogDetail__c> logdetailone = [Select Id,name,Content__c,Error_Message__c
                                               ,Lead_ID__c,Parrent__c,Lead_Valid__c,Success__c 
                                               from LeadLogDetail__c where Parrent__c =: logheader
                                             LIMIT 2000];
       
        System.debug(header.name);
        header.name = header.name.replaceAll('[^a-zA-Z0-9]','');
        for(LeadLogDetail__c logde : logdetailone)
        {
                UploadLead tr = new UploadLead();
                String refinedString = logde.Content__c.replace('null','');
                system.debug('refinedString '+refinedString);
                string[] csvRecordData      = refinedString.split((',(?=([^\"]*\"[^\"]*\")*[^\"]*$)'),-1);
            	system.debug('csvRecordData '+csvRecordData.size());
                tr.leadOwner                = csvRecordData[0].replace('\"','');
                tr.PrimaryCampaign          = csvRecordData[1].replace('\"','');
                tr.LeadOwnerExceptionFlag   = csvRecordData[2].replace('\"','');
                tr.LinktoCustomer           = csvRecordData[3].replace('\"','');
                tr.CustomerType             = csvRecordData[4].replace('\"','');
                tr.CustomerName             = csvRecordData[5].replace('\"','');
                tr.CustomerNameEN           = csvRecordData[6].replace('\"','');
                tr.IDType                   = csvRecordData[7].replace('\"','');
                tr.IDNumber                 = csvRecordData[8].replace('\"','');
                tr.ContactTitle             = csvRecordData[9].replace('\"','');
                tr.ContactFirstname         = csvRecordData[10].replace('\"','');
                tr.ContactLastname          = csvRecordData[11].replace('\"','');
                tr.ContactPosition          = csvRecordData[12].replace('\"','');
                tr.DecisionMap              = csvRecordData[13].replace('\"','');
                tr.ContactPhoneNumber       = csvRecordData[14].replace('\"','');
                tr.Industry                 = csvRecordData[15].replace('\"','');
                tr.Groupname                = csvRecordData[16].replace('\"','');
                tr.NoOfyears                = csvRecordData[17].replace('\"','');
                tr.SalesAmountperyear       = csvRecordData[18].replace('\"','');
                tr.LeadSource               = csvRecordData[19].replace('\"','');
                tr.OtherSource              = csvRecordData[20].replace('\"','');
                tr.BranchedReferred         = csvRecordData[21].replace('\"','');
                tr.ReferralStaffID          = csvRecordData[22].replace('\"','');
                tr.ReferralStaffName        = csvRecordData[23].replace('\"','');
                tr.TotalExpectedRevenue     = csvRecordData[24].replace('\"','');
                tr.Address                  = csvRecordData[25].replace('\"','');
                tr.SubDistrict              = csvRecordData[26].replace('\"','');
                tr.District                 = csvRecordData[27].replace('\"','');
                tr.Province                 = csvRecordData[28].replace('\"','');
                tr.ZipCode                  = csvRecordData[29].replace('\"','');
                tr.Country                  = csvRecordData[30].replace('\"','');
                tr.MobileNo                 = csvRecordData[31].replace('\"','');
                tr.OfficeNo                 = csvRecordData[32].replace('\"','');
                tr.Ext                      = csvRecordData[33].replace('\"','');
                tr.Email                    = csvRecordData[34].replace('\"','');
                tr.Rating                   = csvRecordData[35].replace('\"','');
            	tr.prescreen				= csvRecordData[36].replace('\"','');
                tr.Status					= csvRecordData[37].replace('\"','');
            if(csvRecordData.size() > 38) {
                tr.Remark                   = csvRecordData[38].replace('\"','');
            }
                tr.Success                  = logde.Success__c;
                tr.Invialid                 = logde.Lead_Valid__c;
                tr.id                       = logde.Lead_ID__c;
                tr.Errormessage             = logde.Error_Message__c;
                logall.add(tr);
            	
                if(tr.Invialid == false)
                {
                    logsuccess.add(tr);
                }
                else if(tr.Invialid == true)
                {
                    logerror.add(tr);
                }
          } 
        
        
        System.debug('logsuccess'+logsuccess.size());
        
    }
}
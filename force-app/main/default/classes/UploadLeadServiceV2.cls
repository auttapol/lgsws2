public class UploadLeadServiceV2{
    public Blob csvFileBody           			{get;set;}
    public string csvAsString                   {get;set;}
    public String[] csvFileLines                {get;set;}
    public string validheaderId                 {get;set;}
    public integer rows                         {get;set;}
    
    
    List<ValidWarpper> validlogs {get;set;}
    Public Integer size{get;set;} 
    Public Integer noOfRecords{get; set;} 
    public List<SelectOption> paginationSizeOptions{get;set;}
    
    public List<LeadLogValidDetail__c> ValidDetail   {get; set;}
    
    public List<UploadLead> RowList             {get; set;}
    //public List<UploadLead> RowListTrue         {get; set;}
    //public List<UploadLead> RowListTrueDup      {get; set;}
    //public List<UploadLead> RowTruebeforeinsert {get; set;}
    //public List<UploadLead> RowListFalse        {get; set;}
    //public List<UploadLead> Leadafterinsert     {get; set;}
    public List<UploadLead> allLeadlog          {get; set;}
    
    //public List<UploadLead> fileDuptrue         {get; set;}
    public List<LeadLogHeader__c> loghead       {get; set;}
    public List<LeadLogHeader__c> logheadFalse  {get; set;}
    
    public String messagefiletype 			{get; set;}
    
    Map<Integer,UploadLead> leadmap         = new map<Integer,UploadLead>();
    Map<Integer,UploadLead> leadmapCheck    = new map<Integer,UploadLead>();
    Map<Integer,UploadLead> leadmapinsert   = new map<Integer,UploadLead>();
    Map<Integer,DisqualifiedProcessBuilder.LeadWrapperSOAP> mapleadwarpper = new map<Integer,DisqualifiedProcessBuilder.LeadWrapperSOAP>();
    
    public UploadLeadServiceV2(){
        
        csvFileLines = new String[]{};
        messagefiletype = status_code__c.getValues('5101').status_message__c;   
        set<id> headset = new set<id>();
        set<id> logfalseset = new set<id>();
        set<id> logtrueset = new set<id>();
        loghead = new List<LeadLogHeader__c>();
        logheadFalse = new List<LeadLogHeader__c>();
        //loghead = [Select Id,OwnerID,name,Createddate,Row__c from LeadLogHeader__c where OwnerID =: UserInfo.getUserId() order by Createddate desc];
        List<LeadLogHeader__c> temphead = [Select Id,OwnerID,name,Createddate,Row__c from LeadLogHeader__c where OwnerID =: UserInfo.getUserId() order by Createddate desc];
        for(LeadLogHeader__c sh : temphead) {
            headset.add(sh.Id);
        }
        
        List<LeadLogDetail__c> templogFalse = [Select id,parrent__c,name,Lead_Valid__c from LeadLogDetail__c where parrent__c IN: headset and Lead_Valid__c =: True];
        if(templogFalse.size() > 0) {
            for(LeadLogDetail__c sf : templogFalse) {
                logfalseset.add(sf.parrent__c);
            }
        }
        
        
        
		loghead = [Select Id,OwnerID,name,Createddate,Row__c,Total_Success__c,Total_Fail__c,Total_Import_Records__c,Total_Invalid__c from LeadLogHeader__c where OwnerID =: UserInfo.getUserId() order by Createddate desc];       
        if(loghead.size() > 0)
        {
            Integer newrow = 1;
            for(LeadLogHeader__c listrow : loghead)
            {
                listrow.Row__c = newrow;
                newrow++;
            }
        }
        
        logheadFalse = [Select Id,OwnerID,name,Createddate,Row__c,Total_Success__c,Total_Fail__c,Total_Import_Records__c,Total_Invalid__c from LeadLogHeader__c where OwnerID =: UserInfo.getUserId() and Id IN:logfalseset order by Createddate desc];       
        if(logheadFalse.size() > 0)
        {
            Integer newrow = 1;
            for(LeadLogHeader__c listrow : logheadFalse)
            {
                listrow.Row__c = newrow;
                newrow++;
            }
        }
        //system.debug('headset = '+headset);
        //system.debug('templogFalse = '+templogFalse);
    }
    
    public PageReference importCSVFile(){
        	Boolean isUTF8 = true;
        	string csvdetail;
            try{
             	csvdetail = csvFileBody.tostring() ;
            }catch(Exception e){
                isUTF8 = false;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, status_code__c.getValues('5108').status_message__c));
				return null;                
            }
        if(isUTF8){
            Integer size = csvFileBody.size();
            csvdetail = csvFileBody.tostring();
            UploadLeadUtilityRowIterator r = New UploadLeadUtilityRowIterator(csvdetail,'\r\n'); //Replace \n with whatever delineates your row
            String firstRow;
            if(r.hasNext()) {
                firstRow = r.next();
            }
            List<String> csvdetail2 = new list<String>();
            while(r.hasNext())
            {
                // Read line
                String line = r.next();
                csvdetail2.add(line);
            }
            //RowListTrue     = new List<UploadLead>();
            //RowListFalse    = new List<UploadLead>();
            //Leadafterinsert = new List<UploadLead>();
            //RowListTrueDup  = new List<Uploadlead>();
            RowList         = new List<UploadLead>();
            allLeadlog      = new list<UploadLead>();
            //RowTruebeforeinsert = new List<UploadLead>();
            //fileDuptrue     = new list<UploadLead>();
            
            List<String> csvRecordData = new List<String>();
            
           UploadLead tr;
            Integer row1 = 1;
            //Tinnakrit Comment: - <=2001 is means 2001 is acceptable so it should be <2001 or <=2000
            if(csvdetail2.size() <= 2001){
                for(Integer i=0;i<csvdetail2.size();i++){
                    tr = new UploadLead();
                    // String[] splitted = s.split(',(?=([^\"]*\"[^\"]*\")*[^\"]*$)');
                    if(csvdetail2[i].length() > 38) {
                        csvRecordData = csvdetail2[i].trim().split((',(?=([^\"]*\"[^\"]*\")*[^\"]*$)'),-1);
                        boolean isAllBlank = true;
                        for(String recorddate : csvRecordData){
                            if(recorddate !=null && recorddate !=''){
                               isAllBlank = false;
                            }
                        }
                        
                        
                        
                        if(!isAllBlank){
                            tr.row                      = row1;
                        tr.leadOwner                = csvRecordData[0];
                        tr.leadOwnername            = csvRecordData[0];
                        tr.PrimaryCampaign          = csvRecordData[1];
                        tr.PrimaryCampaignName      = csvRecordData[1];
                        tr.LeadOwnerExceptionFlag   = csvRecordData[2];
                        tr.LinktoCustomer           = csvRecordData[3];
                        tr.LinktoCustomerName       = csvRecordData[3];
                        tr.CustomerType             = csvRecordData[4];
                        tr.CustomerName             = csvRecordData[5];
                        tr.CustomerNameEN           = csvRecordData[6];
                        tr.IDType                   = csvRecordData[7];
                        tr.IDNumber                 = csvRecordData[8];
                        tr.ContactTitle             = csvRecordData[9];
                        tr.ContactFirstname         = csvRecordData[10];
                        tr.ContactLastname          = csvRecordData[11];
                        tr.ContactPosition          = csvRecordData[12];
                        tr.DecisionMap              = csvRecordData[13];
                        tr.ContactPhoneNumber       = csvRecordData[14];
                        tr.Industry                 = csvRecordData[15];
                        tr.IndustryName             = csvRecordData[15];
                        tr.Groupname                = csvRecordData[16];
                        tr.Groupname2               = csvRecordData[16];
                        tr.NoOfyears                = csvRecordData[17];
                        tr.SalesAmountperyear       = csvRecordData[18];
                        tr.LeadSource               = csvRecordData[19];
                        tr.OtherSource              = csvRecordData[20];
                        tr.BranchedReferred         = csvRecordData[21];
                        tr.BranchedReferredName     = csvRecordData[21];
                        tr.ReferralStaffID          = csvRecordData[22];
                        tr.ReferralStaffName        = csvRecordData[23];
                        tr.TotalExpectedRevenue     = csvRecordData[24];
                        tr.Address                  = csvRecordData[25];
                        tr.SubDistrict              = csvRecordData[26];
                        tr.District                 = csvRecordData[27];
                        tr.Province                 = csvRecordData[28];
                        tr.ZipCode                  = csvRecordData[29];
                        tr.Country                  = csvRecordData[30];
                        tr.MobileNo                 = csvRecordData[31];
                        tr.OfficeNo                 = csvRecordData[32];
                        tr.Ext                      = csvRecordData[33];
                        tr.Email                    = csvRecordData[34];
                        tr.Rating                   = csvRecordData[35];
                        tr.prescreen				= csvRecordData[36].tolowercase().trim();//CR Edit 11/06/2016
                        if(csvRecordData.size() > 37) {
                            tr.Remark                   = csvRecordData[37];
                        }
                        leadmap.put(row1, tr);
                        row1++;
                        
                        RowList.add(tr);   
                        }
                        
                        
                        
                        
                    }
                    
                }
                //string test = string.join(RowList, ','); 
            }else{
                ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.severity.ERROR,status_code__c.getValues('5001').status_message__c);
                ApexPages.addmessage(errorMessage);
                return null;
            }
            
            
            
            Map<String,string> mapdupfile = new Map<String,string>();
            set<String> setidnumber = new set<string>();
            
            set<String> s1 = new set<String>();
            set<Integer> s2 = new set<Integer>();

            
				//RowList = LeadValidation.Leadvalid(RowList,null);
           
            for(uploadlead row : RowList)//RowList
            {
                if(!string.isBlank(row.Errormessage)){
                   string err = row.Errormessage.substring(0,row.Errormessage.length() -1 );
                   
                }
                allLeadlog.add(row);
            }
            
        }            
        	
        return validfiles();
		
    }

    
    
    /***********************************************************************/
    /*************************** validfiles ********************************/
    /********************************************************************** */
    Public PageReference validfiles(){
    	LeadLogValidHeader__c  newvalidheader = new LeadLogValidHeader__c();
        newvalidheader.name = csvAsString;
    	insert newvalidheader;   
        
        List<LeadLogValidDetail__c> Inligvalid = new List<LeadLogValidDetail__c>();
        for(Uploadlead validlog : RowList){//allLeadlog){
            LeadLogValidDetail__c val = new LeadLogValidDetail__c();
            val.LeadLogValidHeader__c = newvalidheader.id;
            val.leadOwnerName__c  = validlog.leadOwnername.replace('\"','');
            val.PrimaryCampaignName__c = validlog.PrimaryCampaignName.replace('\"','');
            val.LeadRecordtypeName__c = validlog.LeadRecordtypeName;
            val.LeadRecordtypeId__c = validlog.LeadRecordtypeId;
            val.IndustryName__c = validlog.IndustryName.replace('\"','');
            val.Groupname2__c = validlog.Groupname2.replace('\"','');
            val.row__c = validlog.row;
            val.leadOwner__c = validlog.leadOwner.replace('\"','');
            val.LinktoCustomerName__c = validlog.LinktoCustomerName.replace('\"','');
            val.PrimaryCampaign__c = validlog.PrimaryCampaign.replace('\"','');
            val.LeadOwnerExceptionFlag__c = validlog.LeadOwnerExceptionFlag;
            val.LinktoCustomer__c = validlog.LinktoCustomer.replace('\"','');
            val.CustomerType__c = validlog.CustomerType.replace('\"','');
            val.CustomerName__c = validlog.CustomerName.replace('\"','').left(255);
            val.CustomerNameEN__c = validlog.CustomerNameEN.replace('\"','').left(255);
            val.DecisionMap__c = validlog.DecisionMap.replace('\"','');
            val.IDType__c = validlog.IDType.replace('\"','');
            val.IDNumber__c = validlog.IDNumber.replace('\"','').left(255);
            val.ContactTitle__c = validlog.ContactTitle.replace('\"','');
            val.ContactFirstname__c = validlog.ContactFirstname.replace('\"','').left(255);
            val.ContactLastname__c = validlog.ContactLastname.replace('\"','').left(255);
            val.ContactPosition__c = validlog.ContactPosition.replace('\"','').left(255);
            val.ContactPhoneNumber__c = validlog.ContactPhoneNumber.replace('\"','').left(255);
            val.Industry__c = validlog.Industry.replace('\"','');
            val.Groupname__c = validlog.Groupname.replace('\"','');
            val.NoOfyears__c = validlog.NoOfyears.replace('\"','').left(255);
            val.SalesAmountperyear__c = validlog.SalesAmountperyear.replace('\"','').left(255);
            val.LeadSource__c = validlog.LeadSource.replace('\"','');
            val.OtherSource__c = validlog.OtherSource.replace('\"','').left(255);
            val.BranchedReferred__c = validlog.BranchedReferred.replace('\"','');
            val.BranchedReferredName__c = validlog.BranchedReferredName.replace('\"','');
            val.ReferralStaffID__c = validlog.ReferralStaffID.replace('\"','').left(255);    
            val.ReferralStaffName__c = validlog.ReferralStaffName.replace('\"','').left(255);
            val.TotalExpectedRevenue__c = validlog.TotalExpectedRevenue.replace('\"','').left(255);
            val.Address__c = validlog.Address.replace('\"','').left(255);    
            val.SubDistrict__c = validlog.SubDistrict.replace('\"','').left(255);
            val.District__c = validlog.District.replace('\"','').left(255);    
            val.Province__c = validlog.Province.replace('\"','').left(255);
            val.ZipCode__c = validlog.ZipCode.replace('\"','').left(255);
            val.Country__c = validlog.Country.replace('\"','');
            val.MobileNo__c = validlog.MobileNo.replace('\"','').left(255);
            val.OfficeNo__c = validlog.OfficeNo.replace('\"','').left(255);
            val.Ext__c = validlog.Ext.replace('\"','').left(255);
           	val.Email__c = validlog.Email.replace('\"','').left(255);
            val.Rating__c = validlog.Rating.replace('\"','');
            val.Remark__c = validlog.Remark.replace('\"','').left(1000);
            val.Prescreen__c  = validlog.prescreen.replace('\"','');
            val.Errormessage__c = validlog.Errormessage;
            val.valid__c = true;
            Inligvalid.add(val);
        }
        
        
        if(Inligvalid.size() > 0){
            insert Inligvalid;
        }
        validheaderId = newvalidheader.id;
        allLeadlog.clear();
        PageReference redirectPage = Page.UploadleadvalidV2;
        redirectPage.setRedirect(true);
        redirectPage.getParameters().put('id',newvalidheader.id);
        redirectPage.getParameters().put('name',csvAsString);
        return redirectPage;
    }
    
    
    /****************************************************************************
    **********************************Log files**********************************
    ****************************************************************************/
    
    Public void  logfiles()
    {
        set<id> headset = new set<id>();
        set<id> logfalseset = new set<id>();
        set<id> logtrueset = new set<id>();
        loghead = new List<LeadLogHeader__c>();
        logheadFalse = new List<LeadLogHeader__c>();
        //loghead = [Select Id,OwnerID,name,Createddate,Row__c from LeadLogHeader__c where OwnerID =: UserInfo.getUserId() order by Createddate desc];
        List<LeadLogHeader__c> temphead = [Select Id,OwnerID,name,Createddate,Row__c,Total_Success__c,Total_Fail__c,Total_Import_Records__c,Total_Invalid__c from LeadLogHeader__c where OwnerID =: UserInfo.getUserId() order by Createddate desc];
        for(LeadLogHeader__c sh : temphead) {
            headset.add(sh.Id);
        }
        
        List<LeadLogDetail__c> templogFalse = [Select id,parrent__c,name,Lead_Valid__c from LeadLogDetail__c where parrent__c IN: headset and Lead_Valid__c =: True];
        if(templogFalse.size() > 0) {
            for(LeadLogDetail__c sf : templogFalse) {
                logfalseset.add(sf.parrent__c);
            }
        }
        
        /*List<LeadLogDetail__c> templogTrue = [Select id,parrent__c,name,Lead_Valid__c from LeadLogDetail__c where parrent__c IN: headset and Lead_Valid__c =: False];
        if(templogTrue.size() > 0) {
            for(LeadLogDetail__c sf : templogTrue) {
                logtrueset.add(sf.parrent__c);
            }
        }*/
        
        
		loghead = [Select Id,OwnerID,name,Createddate,Row__c,Total_Success__c,Total_Fail__c,Total_Import_Records__c from LeadLogHeader__c where OwnerID =: UserInfo.getUserId() order by Createddate desc];       
        if(loghead.size() > 0)
        {
            Integer newrow = 1;
            for(LeadLogHeader__c listrow : loghead)
            {
                listrow.Row__c = newrow;
                newrow++;
            }
        }
        
        logheadFalse = [Select Id,OwnerID,name,Createddate,Row__c,Total_Success__c,Total_Fail__c,Total_Import_Records__c from LeadLogHeader__c where OwnerID =: UserInfo.getUserId() and Id IN:logfalseset order by Createddate desc];       
        if(logheadFalse.size() > 0)
        {
            Integer newrow = 1;
            for(LeadLogHeader__c listrow : logheadFalse)
            {
                listrow.Row__c = newrow;
                newrow++;
            }
        }
       // system.debug('headset = '+headset);
    }
   
    
    
}
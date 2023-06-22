public class LeadValidationV2 
{
    private static Boolean isValidDecimal(string valDecimal){
        if(valDecimal != null){
            try{
                Decimal.valueOf(valDecimal);
            }
            catch(TypeException e){
               return false; 
            }
        }
        return true;
    }

    public static List<LeadLogValidDetail__c> Leadvalid(List<LeadLogValidDetail__c> validList, String Numbers)
    {
       
        List<LeadLogValidDetail__c> tempvalid = new List<LeadLogValidDetail__c>();
        set<id> setaccId = new set<id>();
        set<String> setaccExId = new set<String>();
        set<id> setUserex = new set<id>();
        set<String> setUserName = new set<String>();
        set<String> setCampaignName = new set<String>();
        set<String> setIndustryName = new set<String>();
        set<String> setGroupName = new set<String>();
        Set<String> setBranch = new set<String>();
        Set<String> setIdNumber = new set<String>();
        set<String> s1 = new set<String>();
        set<Integer> s2 = new set<Integer>();
        
        for(LeadLogValidDetail__c checkvalid : validList)
        {
            if(checkvalid.PrimaryCampaignName__c != null)
            {
                String campaignname = checkvalid.PrimaryCampaignName__c.trim();
                setCampaignName.add(campaignname);
            }
            if(checkvalid.Industry__c != null)
            {
                String Industryname = checkvalid.Industry__c.trim();
                setIndustryName.add(Industryname);
            }
            if(checkvalid.Groupname__c != null)
            {
                String Groupnames = checkvalid.Groupname__c.trim();
                setGroupName.add(Groupnames);
            }
            if(checkvalid.BranchedReferred__c != null)
            {
                if(Pattern.matches('^[0-9]{3}+$',checkvalid.BranchedReferred__c))
                {
                    setBranch.add(checkvalid.BranchedReferred__c);
                }
            }
            if(checkvalid.LinktoCustomer__c != null && checkvalid.LinktoCustomer__c.isNumeric() && checkvalid.LinktoCustomer__c.length() > 5 && checkvalid.LinktoCustomer__c.length() < 30)
            {
                string a = '0';
            	Integer i = 25 - checkvalid.LinktoCustomer__c.trim().length();
                checkvalid.LinktoCustomer__c = '00110'+ a.repeat(i) + checkvalid.LinktoCustomer__c.trim();
        	}
            if(checkvalid.LinktoCustomer__c != null)
            {
                if(checkvalid.LinktoCustomer__c.trim().length() == 30)
                {
                    setaccExId.add(checkvalid.LinktoCustomer__c.trim());
                }
            }
            if(checkvalid.IDNumber__c != null && checkvalid.IDNumber__c != '')
            {
                setIdNumber.add(checkvalid.IDNumber__c);
            }
            if(checkvalid.idtype__c != null 
               && checkvalid.IDNumber__c != null 
               && checkvalid.idtype__c != '' 
               && checkvalid.IDNumber__c != '')
            {
					string typename = checkvalid.idtype__c.replaceAll('\\s+','');
                    //Tinnakrit Comment - Change To Map<String,String> do not compare with IDTYPE+IDNUMBER because ID TYPE has whitespace
                    //and make sure that program must be ignored Case Sensitives
                    if (s1.contains(typename.toLowerCase().trim()+checkvalid.IDNumber__c)) {
                        s2.add(Integer.valueOf(checkvalid.row__c));
                    }else {
                        s1.add(typename.toLowerCase().trim()+checkvalid.IDNumber__c);
                    }
            }
        }
        
        
        
        /*****************************User ID************************************/
        List<User> tempuser = [Select Id,IsActive,Employee_ID__c,name from user];
        Map<String,User> mapuserEx = new Map<String,User>();
        Map<String,Id> mapuserName = new Map<String,Id>();
        Map<String,Id> MapqueueName = new Map<String,Id>();
        
        Map<String,List<Id>> Mapcheckqueue = new Map<String,List<Id>>();
        List<Group> tempqueue = [Select Id,name,type from group where type =: 'Queue'];
        //system.debug('tempqueue = '+tempqueue);
        for(User usr: tempuser)
        {
            mapuserEx.put(usr.Employee_ID__c, usr);
            //mapuserName.put(usr.Name, usr.Id);
        }
        for(Group que :tempqueue)
        {
            MapqueueName.put(que.name.tolowercase().trim(), que.Id);
        }
        //System.debug('Check Mapcheckqueue 1 = '+Mapcheckqueue);
        
        /*****************************Custom Setting Error Message**********************************/
        Map<String,String> MapErrMsg = new Map<String,String>();
        List<Status_Code__c> errmsg = [Select Id,name,Status_Message__c from Status_Code__c];
        
        for(Status_Code__c er : errmsg) {
            MapErrMsg.put(er.name, er.Status_Message__c);
        }
        
        
        
        /*****************************Primary Campaign**********************************/
        List<Campaign> tempcampaign = [Select id,name,Isactive from Campaign where name IN: setCampaignName];
        Map<String,Campaign> mapCampaignName = new Map<String,Campaign>();
        if(tempcampaign.size() > 0)
        {
            for(Campaign tempcam : tempcampaign)
            {
                mapCampaignName.put(tempcam.name.tolowercase().trim(), tempcam);
            }
            //system.debug('##mapCampaignName = '+mapCampaignName);
        }
        
        /********************************Industry*************************************/
        List<Industry__c> tempIndustry = [Select Id,name from Industry__c where name IN: setIndustryName];
        Map<String,Id> mapIndustryName = new Map<String,Id>();
        if(tempIndustry.size() > 0)
        {
            for(Industry__c tempin : tempIndustry)
            {
                mapIndustryName.put(tempin.name.tolowercase().trim(), tempin.Id);
            }
        }
        
        
        
        /*******************************Group Name***********************************/
        List<Group__c > tempGroup = [Select Id,name from Group__c where name IN: setGroupName];
        Map<String,Id> mapGroupName = new Map<String,Id>();
        if(tempGroup.size() > 0)
        {
            for(Group__c tempgro : tempGroup)
            {
                mapGroupName.put(tempgro.name.tolowercase().trim(), tempgro.Id);
            }
        }
        
        
        /***************************Check Account ID*********************************/
        Map<String,Id> mapaccUserEx = new Map<String,Id>();
        List<account> tempacc = [Select Id,
                                 		name,
                                 		OwnerId,
                                 		TMB_Customer_ID_PE__c
                                 		//CRM_ID__c
                                 from Account 
                                 where TMB_Customer_ID_PE__c IN: setaccExId];
        //system.debug('##tempacc = '+tempacc);
        if(tempacc.size() > 0)
        {
            for(Account acc : tempacc)
            {
                mapaccUserEx.put(acc.TMB_Customer_ID_PE__c, acc.Id);
            }
        }
        
        
        
        /*******************************Check Dup Id Number Account************************************/
        Map<String,Id> mapaccUserIdnumber = new Map<String,Id>();
        /*List<account> tempIdnumber = [Select Id,
                                 		name,
                                 		OwnerId,
                                 		CRM_ID__c,
                                 		ID_Number_PE__c
                                 from Account 
                                 where ID_Number_PE__c  IN: setIdNumber];*/
        //FIND {setIdNumber} IN ID_Number_PE__c Fields RETURNING Account(Id);
        //List<List<SObject>> searchList = [FIND setIdNumber IN ID_Number_PE__c Fields RETURNING 
                                  //Account (Id)];
        
   
        
        
        
        
        
        /*******************************Branch and Zone************************************/
        List<Branch_and_Zone__c> tempBranch = [Select Id,name,Branch_Code__c,Branch_Name__c from Branch_and_Zone__c where Branch_Code__c IN: setBranch];
        Map<String,Branch_and_Zone__c> mapBranch = new Map<String,Branch_and_Zone__c>();
        if(tempBranch.size() > 0 )
        {
            for(Branch_and_Zone__c tempBr : tempBranch)
            {
                mapBranch.put(tempBr.Branch_Code__c , tempBr);
            }
        }
        
        
        
        /*****************************Validation************************************/
        
        //Tinnakrit Edit Jun 13 12:27 AM
        //
        //
        //
        //List<Group> sizequeue = [Select Id,name,type from group where type =: 'Queue' and  name =: checkvalid.leadOwner];
        //
        Set<String> QueueNameSet = new Set<String>();
        Map<String,List<Group>> queueNameMap = new Map<String,List<Group>>();
        for(LeadLogValidDetail__c checkvalid : validList)
        {
            if(MapqueueName.get(checkvalid.leadOwner__c.tolowercase().trim()) != null && !Pattern.matches('^[0-9]{5}+$',checkvalid.leadOwner__c)){
                QueueNameSet.add(checkvalid.leadOwner__c.tolowercase().trim());
            }
        }
        for(Group queueValue : [Select Id,name,type from group where type =: 'Queue' and  name IN: QueueNameSet]){
            if(queueNameMap.containsKey(queueValue.name.tolowercase().trim())){
                queueNameMap.get(queueValue.name.tolowercase().trim()).add(queueValue);
            }else{
                List<Group> groupList = new List<group>();
                groupList.add(queueValue);
                queueNameMap.put(queueValue.name.tolowercase().trim(),groupList);
            }
        }
        
        
        //
        //
        //Tinnakrit Edit Jun 13 12:27 AM
        
        
         for(LeadLogValidDetail__c checkvalid : validList)
        {
            checkvalid.Errormessage__c = '';
            

            if(checkvalid.LinktoCustomer__c !=null)
            {
                    if(checkvalid.LinktoCustomer__c.trim().length() == 30 /*&& mapaccUserEx.size() != 0*/)
                    {
                     	if(mapaccUserEx.keySet().contains(checkvalid.LinktoCustomer__c.trim()) == true && mapaccUserEx.get(checkvalid.LinktoCustomer__c.trim()) != null )
                        { 
                          checkvalid.LinktoCustomer__c = mapaccUserEx.get(checkvalid.LinktoCustomer__c.trim());
                            if(checkvalid.valid__c != False){   
                          		checkvalid.valid__c = True;  
                            }
                        }else{
                          checkvalid.valid__c = False;
                        checkvalid.errormessage__c += MapErrMsg.get('5014')+', \r\n';    
                    	}
                    }
              //  system.debug('##checkvalid.LinktoCustomer new = '+checkvalid.LinktoCustomer);
            }
            /*if(string.isBlank(checkvalid.leadOwner)) {
                checkvalid.errormessage += 'Lead Owner is required. \r\n';
                checkvalid.flag = False; 
            }*/
           
            if(string.isBlank(checkvalid.CustomerType__c)) {
                checkvalid.errormessage__c += MapErrMsg.get('5015')+', \r\n'; 
                checkvalid.valid__c = False;
            }
            
            if(string.isBlank(checkvalid.CustomerName__c)) {
                checkvalid.errormessage__c += MapErrMsg.get('5016')+', \r\n';
                checkvalid.valid__c = False;
            }
            
            if(string.isBlank(checkvalid.ContactLastname__c)) {
                checkvalid.errormessage__c += MapErrMsg.get('5017')+', \r\n';
                checkvalid.valid__c = False;
            }
            if(checkvalid.IDNumber__c != null && checkvalid.IDNumber__c != '' && checkvalid.IDNumber__c.length() > 25) {
                checkvalid.errormessage__c += MapErrMsg.get('5024')+', \r\n';
                checkvalid.valid__c = False;
            }
            if(checkvalid.Address__c != null && checkvalid.Address__c.length() > 40) {
                checkvalid.errormessage__c += MapErrMsg.get('5025')+', \r\n';
                checkvalid.valid__c = False;
            }
            if(checkvalid.SubDistrict__c != null && checkvalid.SubDistrict__c.length() > 40) {
                checkvalid.errormessage__c += MapErrMsg.get('5026')+', \r\n';
                checkvalid.valid__c = False;
            }
            if(checkvalid.District__c != null && checkvalid.District__c.length() > 40) {
                checkvalid.errormessage__c += MapErrMsg.get('5027')+', \r\n';
                checkvalid.valid__c = False;
            }
            if(checkvalid.Email__c != null && checkvalid.Email__c.length() > 80) {
                checkvalid.errormessage__c += MapErrMsg.get('5028')+', \r\n';
                checkvalid.valid__c = False;
            }
            if(checkvalid.Ext__c != null && checkvalid.Ext__c.length() > 10) {
                checkvalid.errormessage__c += MapErrMsg.get('5029')+', \r\n';
                checkvalid.valid__c = False;
            }
            if(checkvalid.ZipCode__c != null && checkvalid.ZipCode__c.length() > 10) {
                checkvalid.errormessage__c += MapErrMsg.get('5030')+', \r\n';
                checkvalid.valid__c = False;
            }
            if(checkvalid.ReferralStaffID__c != null && checkvalid.ReferralStaffID__c.length() > 5) {
                checkvalid.errormessage__c += MapErrMsg.get('5031')+', \r\n';
                checkvalid.valid__c = False;
            }
            if(checkvalid.ReferralStaffName__c != null && checkvalid.ReferralStaffName__c.length() > 100) {
                checkvalid.errormessage__c += MapErrMsg.get('5032')+', \r\n';
                checkvalid.valid__c = False;
            }
            if(checkvalid.customerName__C != null && checkvalid.customerName__c.length() > 255) {
                checkvalid.errormessage__c += MapErrMsg.get('5034')+', \r\n';
                checkvalid.valid__c = False;
            }
            if(checkvalid.customerNameEN__c != null && checkvalid.customerNameEN__c.length() > 100) {
                checkvalid.errormessage__c += MapErrMsg.get('5035')+', \r\n';
                checkvalid.valid__c = False;
            }
            if(checkvalid.ContactPhoneNumber__C != null && checkvalid.ContactPhoneNumber__c.length() > 40) {
                checkvalid.errormessage__c += MapErrMsg.get('5036')+', \r\n';
                checkvalid.valid__c = False;
            }
            if(checkvalid.MobileNo__c != null && checkvalid.MobileNo__c.length() > 40) {
                checkvalid.errormessage__c += MapErrMsg.get('5037')+', \r\n';
                checkvalid.valid__c = False;
            }
            if(checkvalid.OfficeNo__c != null && checkvalid.OfficeNo__c.length() > 40) {
                checkvalid.errormessage__c += MapErrMsg.get('5038')+', \r\n';
                checkvalid.valid__c = False;
            }
            if(checkvalid.ContactPosition__c != null && checkvalid.ContactPosition__c.length() > 128) {
                checkvalid.errormessage__c += MapErrMsg.get('5039')+', \r\n';
                checkvalid.valid__c = False;
            }
            if(checkvalid.ContactFirstname__c != null && checkvalid.ContactFirstname__c.length() > 40) {
                checkvalid.errormessage__c += MapErrMsg.get('5040')+', \r\n';
                checkvalid.valid__c = False;
            }
            if(checkvalid.ContactLastname__c != null && checkvalid.ContactLastname__c.length() > 80) {
                checkvalid.errormessage__c += MapErrMsg.get('5046')+', \r\n';
                checkvalid.valid__c = False;
            }
            if(checkvalid.NoOfyears__c != null && checkvalid.NoOfyears__c != ''){
                if(checkvalid.NoOfyears__c.length() > 5 || !checkvalid.NoOfyears__c.isNumeric()) {
                checkvalid.errormessage__c += MapErrMsg.get('5044')+', \r\n';
                checkvalid.valid__c = False;
                }
            }
            if(checkvalid.OtherSource__c != null && checkvalid.OtherSource__c.length() > 25) {
                checkvalid.errormessage__c += MapErrMsg.get('5045')+', \r\n';
                checkvalid.valid__c = False;
            }
            if(checkvalid.Remark__c != null && checkvalid.Remark__c.length() > 1000) {//change from 255 to 1000
                checkvalid.errormessage__c += MapErrMsg.get('5047')+', \r\n';
                checkvalid.valid__c = False;
            }
            if((checkvalid.prescreen__c != null && checkvalid.prescreen__c != '') && checkvalid.prescreen__c.tolowercase().trim() != 'passed') {
                checkvalid.errormessage__c += MapErrMsg.get('5048')+', \r\n';
                checkvalid.valid__c = False;
            }
            if(checkvalid.SalesAmountperyear__c != null && checkvalid.SalesAmountperyear__c != ''){

                if(isValidDecimal(checkvalid.SalesAmountperyear__c)){
                    List<String> SalesAmount = checkvalid.SalesAmountperyear__c.trim().split('\\.');
                    if(SalesAmount.size() == 1) {
                        if(SalesAmount[0] != null && SalesAmount[0].length() > 13) {
                            checkvalid.errormessage__c += MapErrMsg.get('5041')+', \r\n';
                            checkvalid.valid__c = False;
                        }
                    }else if(SalesAmount.size() == 2) {
                        if(SalesAmount[1] != null && SalesAmount[1].length() > 2) {
                            checkvalid.errormessage__c += MapErrMsg.get('5041')+', \r\n';
                            checkvalid.valid__c = False;
                        }
                    }
                }
                else{
                    checkvalid.errormessage__c += MapErrMsg.get('5041')+', \r\n';
                    checkvalid.valid__c = False;
                }            	
            }
            if(checkvalid.TotalExpectedRevenue__c != null && checkvalid.TotalExpectedRevenue__c != ''){
                List<String> TotalExpected = checkvalid.TotalExpectedRevenue__c.trim().split('\\.');
                if(TotalExpected.size() == 1) {
                    if(TotalExpected[0] != null && TotalExpected[0].length() > 16) {
                        checkvalid.errormessage__c += MapErrMsg.get('5042')+', \r\n';
                        checkvalid.valid__c = False;
                    }
                }else if(TotalExpected.size() == 2) {
                    if(TotalExpected[1] != null && TotalExpected[1].length() > 2) {
                        checkvalid.errormessage__c += MapErrMsg.get('5042')+', \r\n';
                        checkvalid.valid__c = False;
                    }
                }
            }
            if(checkvalid.leadOwner__c != null && checkvalid.leadOwner__c != '')
            {
                
                //System.debug('Check Mapcheckqueue 2 = '+Mapcheckqueue.get(checkvalid.leadOwner.trim()));
                if(Pattern.matches('^[0-9]{5}+$',checkvalid.leadOwner__c))
                {
                    if(mapuserEx.containsKey(checkvalid.leadOwner__c))
                    {
                        if( mapuserEx.get(checkvalid.leadOwner__c).isActive == true) {
                            checkvalid.leadOwner__c = mapuserEx.get(checkvalid.leadOwner__c).Id;
                            if(checkvalid.valid__c != False){
                                checkvalid.valid__c = True;
                            }
                        }else if(mapuserEx.get(checkvalid.leadOwner__c).isActive == false ) {
                            checkvalid.errormessage__c += MapErrMsg.get('5033')+', \r\n'; 
                       		checkvalid.valid__c = False; 
                        }
                    }
                    else
                    {
                       checkvalid.errormessage__c += MapErrMsg.get('5019')+', \r\n'; 
                       checkvalid.valid__c = False; 
                    }
                }
               // else if(MapqueueName.get(checkvalid.leadOwner.trim()) != null)
                  else if(queueNameMap.containsKey(checkvalid.leadOwner__c.tolowercase().trim()))
                {
                    List<group> sizequeue = queueNameMap.get(checkvalid.leadOwner__c.tolowercase().trim());
                   // List<Group> sizequeue = [Select Id,name,type from group where type =: 'Queue' and  name =: checkvalid.leadOwner];
                    if(sizequeue.size() > 1){
                        checkvalid.errormessage__C += MapErrMsg.get('5004')+' \r\n'; 
                        checkvalid.valid__c = False;
                    }else{
                        checkvalid.leadOwner__c = MapqueueName.get(checkvalid.leadOwner__c.tolowercase().trim());
                        if(checkvalid.valid__c != False){
                        	checkvalid.valid__c = True;
                        }
                    }
                }
                else
                {
                   checkvalid.errormessage__c += MapErrMsg.get('5019')+', \r\n'; 
                   checkvalid.valid__c = False; 
                }
            }
            else
            {
                checkvalid.leadOwner__c = UserInfo.getUserId();
                if(checkvalid.valid__c != False){
                   checkvalid.valid__c = True;
                }  
            }
            if(s2.contains(Integer.valueof(checkvalid.row__c)))
            {
                    checkvalid.Errormessage__C += MapErrMsg.get('5003')+', \r\n';
                    checkvalid.valid__c = false;
            }
            if(checkvalid.PrimaryCampaign__c != null && checkvalid.PrimaryCampaign__c != '')
            {
                if(mapCampaignName.get(checkvalid.PrimaryCampaign__c.tolowercase().trim()) != null)
                {
                    //if(mapCampaignName.get(checkvalid.PrimaryCampaign.tolowercase().trim()).isActive == true) {   
                        checkvalid.PrimaryCampaign__c = mapCampaignName.get(checkvalid.PrimaryCampaign__c.tolowercase().trim()).id;
                       // system.debug('checkvalid.flag = '+checkvalid.flag);
                        if(checkvalid.valid__c != false){
                            checkvalid.valid__c = True; 
                        }
                   /* }else if(mapCampaignName.get(checkvalid.PrimaryCampaign.tolowercase().trim()).isActive == false) {
                        checkvalid.errormessage += MapErrMsg.get('5020')+', \r\n'; 
                    	checkvalid.flag = False;
                    }*/
                }
                else
                {
                    checkvalid.errormessage__c += MapErrMsg.get('5005')+', \r\n'; 
                    checkvalid.valid__c = False;
                    //system.debug('##checkvalid.errormessage = '+checkvalid.errormessage);
                    //system.debug('##checkvalid.flag(campaign) = '+checkvalid.flag);
                }
            }
            if(checkvalid.Industry__c != null && checkvalid.Industry__c != '' && checkvalid.Industry__c.length() != 0)
            {
                if(mapIndustryName.get(checkvalid.Industry__c.tolowercase().trim()) != null)
                {
                   checkvalid.Industry__c = mapIndustryName.get(checkvalid.Industry__c.tolowercase().trim());
                   // system.debug('##mapIndustryName.Industry = '+mapIndustryName.get(checkvalid.Industry.tolowercase().trim()));
                    if(checkvalid.valid__c != false){
                        checkvalid.valid__c = True;
                    }
                }
                else if(mapIndustryName.get(checkvalid.Industry__c.tolowercase().trim()) == null)
                {
                    checkvalid.errormessage__c += MapErrMsg.get('5006')+', \r\n'; 
                    checkvalid.valid__c = False;
                }
            }
            if(checkvalid.Groupname__c != null && checkvalid.Groupname__c != '')
            {
                if(mapGroupname.get(checkvalid.Groupname__c.tolowercase().trim()) != null)
                {
                   checkvalid.Groupname__c = mapGroupname.get(checkvalid.Groupname__c.tolowercase().trim());
                    if(checkvalid.valid__c != false){
                        checkvalid.valid__c = True;
                    }
                }
                else if(mapGroupname.get(checkvalid.Groupname__c.tolowercase().trim()) == null)
                {
                    checkvalid.errormessage__c += MapErrMsg.get('5007')+', \r\n'; 
                    checkvalid.valid__c = False;
                }
                
            }
            if(checkvalid.BranchedReferred__c!=null)
            {
                //system.debug('##checkvalid.BranchedReferred.length() = '+checkvalid.BranchedReferred.length());
                if(Pattern.matches('^[0-9]{3}+$',checkvalid.BranchedReferred__c) || Pattern.matches('^[0-9]{4}+$',checkvalid.BranchedReferred__c ))
                {
                    //system.debug('(mapBranch.get(checkvalid.BranchedReferred) = '+mapBranch.get(checkvalid.BranchedReferred).Id);
                    //system.debug('mapBranch.get(checkvalid.BranchedReferred).Branch_Name__c = '+mapBranch.get(checkvalid.BranchedReferred).Branch_Name__c);
                    //system.debug('## validation BranchedReferredName : '+checkvalid.BranchedReferredName);
                    if(mapBranch.get(checkvalid.BranchedReferred__c) != null)
                    {
                        checkvalid.BranchedReferred__c = mapBranch.get(checkvalid.BranchedReferred__c).Id;
                        checkvalid.BranchedReferredName__c = mapBranch.get(checkvalid.BranchedReferredName__c).Branch_Name__c;
                        if(checkvalid.valid__c != false){
                            checkvalid.valid__c = True;  
                        }
                    }
                    else
                    {
                        checkvalid.errormessage__c += MapErrMsg.get('5008')+', \r\n'; 
                        checkvalid.valid__c = False;
                    }
                }
                else
                {
                    checkvalid.errormessage__c += MapErrMsg.get('5009')+', \r\n'; 
                    checkvalid.valid__c = False;
                }
            }
            if(checkvalid.CustomerType__c == 'Juristic' && (checkvalid.IDType__c != null && checkvalid.IDType__c != '')&& checkvalid.IDType__c != 'BRN ID' ){
                checkvalid.errormessage__c += MapErrMsg.get('5010')+', \r\n';
                checkvalid.valid__c = False;
            }
            if(checkvalid.CustomerType__c == 'Individual' && checkvalid.IDType__c == 'BRN ID') {
                checkvalid.errormessage__c += MapErrMsg.get('5018')+', \r\n';
                checkvalid.valid__c = False;  
            }
            if(checkvalid.ContactPhoneNumber__c != '' && checkvalid.ContactPhoneNumber__c != null) {
                if(!Pattern.matches('[\\d\\-\\s]*',checkvalid.ContactPhoneNumber__c)) {
                   checkvalid.errormessage__c += MapErrMsg.get('5021')+', \r\n'; 
                   checkvalid.valid__c = False; 
                }
            }
            if(checkvalid.OfficeNo__c != '' && checkvalid.OfficeNo__c != null) {
                if(!Pattern.matches('[\\d\\-\\s]*',checkvalid.OfficeNo__c)) {
                   checkvalid.errormessage__c += MapErrMsg.get('5022')+', \r\n'; 
                   checkvalid.valid__c = False; 
                }
            }
            if(checkvalid.MobileNo__c != '' && checkvalid.MobileNo__c != null) {
                if(!Pattern.matches('[\\d\\-\\s]*',checkvalid.MobileNo__c)) {
                   checkvalid.errormessage__c += MapErrMsg.get('5023')+', \r\n'; 
                   checkvalid.valid__c = False; 
                }
            }
            if(checkvalid.CustomerType__c == 'Individual' && checkvalid.IDType__c == 'Citizen ID' && checkvalid.IdNumber__c != null && checkvalid.IdNumber__c != '')
            {
                if(checkvalid.IDType__c == 'Citizen ID' && !Pattern.matches('^[0-9]{13}+$',checkvalid.IdNumber__c)){         
                    checkvalid.errormessage__c += MapErrMsg.get('5011')+', \r\n';
                    checkvalid.valid__c = False;    
                }else if(checkvalid.IDType__c == 'Citizen ID' && Pattern.matches('^[0-9]{13}+$',checkvalid.IdNumber__c)){
                    string[] citizen = checkvalid.IdNumber__c.split('');
                   // system.debug('citizen = '+citizen);
                    integer sum = 0; 
                    for(integer i = 0; i < 12; i++) { 
                        sum += Integer.valueof(citizen[i])*(13-i);
                    }
                   // system.debug('sum is : '+sum);
                    //system.debug('math.mod(11-(math.mod(s,11))) = '+11-math.mod(sum,11);
                  //  system.debug('math.mod(11-(math.mod(s,11)),10) = '+math.mod(11-(math.mod(sum,11)),10));
                   // system.debug('integer.valueOf(citizen[12]) = '+integer.valueOf(citizen[12]));
                    if(math.mod(11-math.mod(sum,11),10) != Integer.valueof(citizen[12])){
                        checkvalid.errormessage__c += MapErrMsg.get('5011')+', \r\n';
                        checkvalid.valid__c = False;
                    }else{
                        if(checkvalid.valid__c != false){
                        checkvalid.valid__c = True;
                        }else{
                            checkvalid.valid__c = False;
                        }
                    }
                }
            }
            if(checkvalid.Email__c != null && checkvalid.Email__c != '' && !Pattern.matches('^[a-zA-Z0-9._|\\\\%#~`=?&/$^*!}{+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,4}$',checkvalid.Email__c)){
               checkvalid.errormessage__c += MapErrMsg.get('5012')+', \r\n';
               checkvalid.valid__c = False;
            }
            if(checkvalid.errormessage__c != null){
            	checkvalid.errormessage__c = checkvalid.errormessage__c.removeEnd(',');
            }
            if(checkvalid.LeadOwnerExceptionFlag__c == null){
               checkvalid.LeadOwnerExceptionFlag__c = 'No'; 
            }
			//checkvalid.errormessage = checkvalid.errormessage.subString(0,checkvalid.errormessage.Length()-2);
            //system.debug(checkvalid.errormessage);
            tempvalid.add(checkvalid);
        }
        
        
        
        //system.debug('##tempvalid = '+tempvalid);
        return tempvalid;
    }   
    
}
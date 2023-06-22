public class slaByHopCtl {

    public slaByHopCtl(){

    }

    public list<SLA_By_Hop__c>  addSLAByHop(Service_Type_Matrix__c ServiceRecord, Case caseRecord, Map<String,Schema.SObjectField> fieldNames,
                                            Map<ID,List<SLA_By_Hop__c>> mapSLAbyHopList, Map<ID,List<SLA_Per_Owner__c>> mapSLAPerOwnerList){

        list<SLA_By_Hop__c> oldSlaByHop = New list<SLA_By_Hop__c>();
        if(mapSLAbyHopList.size() > 0){
            oldSlaByHop = mapSLAbyHopList.get(caseRecord.id);
        }
        

        list<SLA_By_Hop__c> slaByHopAddList = new list<SLA_By_Hop__c>();
        Integer hopNumber = 1;
        Map<String, SLA_By_Hop__c> mapSLAByHop = new Map<String, SLA_By_Hop__c>();

        SLA_By_Hop__c existingRegister = new SLA_By_Hop__c();
        list<SLA_Per_Owner__c> oldSLAPerOwner = New list<SLA_Per_Owner__c>();
        if(mapSLAPerOwnerList.size() > 0){
             oldSLAPerOwner = mapSLAPerOwnerList.get(caseRecord.id);
        }
       
        list<SLA_Per_Owner__c> SLAPerOwnerUpdateList = new list<SLA_Per_Owner__c>();
        //Clear all existing SLA by Hop before create new SLA by Hop
        if(oldSlaByHop.size() > 0 ){
            existingRegister  = deleteSLAByHop(oldSlaByHop, caseRecord, oldSLAPerOwner);           
        }

        //Add first Hop (Responsible BU)
        if(ServiceRecord.Responsible_BU__c != null){
            SLA_By_Hop__c slaByHopRecord = new SLA_By_Hop__c();
            slaByHopRecord.Name = ServiceRecord.Responsible_BU__c;
            slaByHopRecord.Hop__c = String.valueOf(hopNumber);
            slaByHopRecord.Case__c = caseRecord.id;
            slaByHopRecord.SLA_Hop_Day__c = ServiceRecord.SLA_Hop_1_Day__c;
            slaByHopAddList.add(slaByHopRecord);
            mapSLAByHop.put(ServiceRecord.Responsible_BU__c,slaByHopRecord);
            hopNumber = hopNumber + 1;
        }
        

        //Add 'SLA by Hop' hop 2 to hop 'N'
        if(hopNumber == 1){
            hopNumber = 2;
        }
        for(integer i =0; i < fieldNames.size(); i++){
            String ResponsibleBU =  'Responsible_BU_Hop_'+hopNumber+'__c';
            String SLAHop = 'SLA_Hop_'+hopNumber+'_Day__c';
            Sobject serviceIssue = ServiceRecord;              
            if(fieldNames.containsKey(ResponsibleBU) ==  true){
                if((String)serviceIssue.get(ResponsibleBU) != null && !mapSLAByHop.containsKey((String)serviceIssue.get(ResponsibleBU))){
                    SLA_By_Hop__c slaByHopRecord = new SLA_By_Hop__c();
                    slaByHopRecord.Name = (String)serviceIssue.get(ResponsibleBU);
                    slaByHopRecord.Hop__c = String.valueOf(hopNumber);
                    slaByHopRecord.Case__c = caseRecord.id;
                    slaByHopRecord.SLA_Hop_Day__c = (decimal)serviceIssue.get(SLAHop);
                    slaByHopAddList.add(slaByHopRecord);
                    mapSLAByHop.put((String) serviceIssue.get(ResponsibleBU),slaByHopRecord);
                    hopNumber = hopNumber + 1;
                }
            }else{
                break;
            }
        }
        
        
       //Add Closed Hop (Closed by BU)
        if(ServiceRecord.Closed_By_BU__c != null && !mapSLAByHop.containsKey(ServiceRecord.Closed_By_BU__c)
        && ServiceRecord.Closed_By_BU__c != 'REGISTER' ){
            SLA_By_Hop__c slaByHopRecord = new SLA_By_Hop__c();
            slaByHopRecord.Name = ServiceRecord.Closed_By_BU__c;
            slaByHopRecord.Hop__c = String.valueOf(hopNumber);
            slaByHopRecord.Case__c = caseRecord.id;
            slaByHopRecord.SLA_Hop_Day__c = ServiceRecord.SLA_Closed_By_BU_Day__c;
            slaByHopAddList.add(slaByHopRecord); 
                    
        }else if(ServiceRecord.Closed_By_BU__c == 'REGISTER' && existingRegister.id == null){
            SLA_By_Hop__c slaByHopRecord = new SLA_By_Hop__c();
            slaByHopRecord.Name = ServiceRecord.Closed_By_BU__c;
            slaByHopRecord.Hop__c = String.valueOf(hopNumber);
            slaByHopRecord.Case__c = caseRecord.id;
            slaByHopRecord.SLA_Hop_Day__c = ServiceRecord.SLA_Closed_By_BU_Day__c;
            slaByHopAddList.add(slaByHopRecord); 
           
        }

        //Update duplicate SLA by Hop
        if(ServiceRecord.Closed_By_BU__c != null && mapSLAByHop.containsKey(ServiceRecord.Closed_By_BU__c)){
           SLA_By_Hop__c slaByHopRecord = mapSLAByHop.get(ServiceRecord.Closed_By_BU__c);
           //Remove duplicate existing SLA by Hop 
           for(integer i = 0; i < slaByHopAddList.size(); i++){
               if(slaByHopAddList.get(i).name == ServiceRecord.Closed_By_BU__c){
                   slaByHopAddList.remove(i);
               }
           }    
           //Sum SLA 
           double slaClosed = ServiceRecord.SLA_Closed_By_BU_Day__c != null? ServiceRecord.SLA_Closed_By_BU_Day__c: 0;
           if(slaByHopRecord.SLA_Hop_Day__c != null){
               slaByHopRecord.SLA_Hop_Day__c = slaByHopRecord.SLA_Hop_Day__c + slaClosed;
           }else{
               slaByHopRecord.SLA_Hop_Day__c =  ServiceRecord.SLA_Closed_By_BU_Day__c;
           }       
           
           mapSLAByHop.put(ServiceRecord.Closed_By_BU__c,slaByHopRecord);
           slaByHopAddList.add(slaByHopRecord);

        }
       
        //Update existing SLA by Hop 'Register'
        if(ServiceRecord.Closed_By_BU__c == 'REGISTER' && existingRegister.id != null &&
         ServiceRecord.SLA_Closed_By_BU_Day__c != null){           
            existingRegister.Hop__c = String.valueOf(hopNumber);           
            existingRegister.SLA_Hop_Day__c = ServiceRecord.SLA_Closed_By_BU_Day__c;            
            slaByHopAddList.add(existingRegister);
          
        } else if(existingRegister.id != null){
           slaByHopAddList.add(existingRegister);
        }

        return slaByHopAddList;
    }

    public SLA_By_Hop__c deleteSLAByHop(list<SLA_By_Hop__c> oldSlaByHop, Case caseRecord, list<SLA_Per_Owner__c> oldSLAPerOwner){
        list<SLA_By_Hop__c> slaByHopDeleteList = new list<SLA_By_Hop__c>();
        SLA_By_Hop__c tempRegister = New SLA_By_Hop__c();

        list<SLA_Per_Owner__c> SLAPerOwnerUpdateList = new list<SLA_Per_Owner__c>();
        
        Boolean isUpdateRegister = false;

        for(SLA_By_Hop__c slabyHop : oldSlaByHop){
            //Not select SLA by Hop 'Register' to delete
            if(slabyHop.Name == 'REGISTER'){
                tempRegister =  slabyHop;

                //Reset SLA by Hop 'Register'
                if(tempRegister.Hop__c != 'N/A'){
                    tempRegister.Hop__c = 'N/A';
                    tempRegister.SLA_Hop_Day__c = null;
                    isUpdateRegister = true;                   
                }
            }else {
                slaByHopDeleteList.add(slabyHop);
            }
        }

        //Delete all existing SLA by Hop and move all 'work duration per owner' to Register
        if(slaByHopDeleteList.size() > 0){

            //If existing SLA by Hop don't have 'Register', create new 'Regiter'
            if(tempRegister.id == null){
                tempRegister.Name = 'REGISTER';
                tempRegister.Case__c = caseRecord.id;
                tempRegister.Hop__c = 'N/A';
                insert tempRegister;
            }

            //Update all existing 'work duration per owner' to 'Register'
            //if(oldSLAPerOwner != null){            
            if(oldSLAPerOwner != null && oldSLAPerOwner.size() > 0 ){
                for(SLA_Per_Owner__c workDuration : oldSLAPerOwner){
                    workDuration.Hop_Team__c = tempRegister.id;
                    SLAPerOwnerUpdateList.add(workDuration);
                }
            } 
            //}          
            if(SLAPerOwnerUpdateList.size() > 0){
                update SLAPerOwnerUpdateList;
            }

            //Delete all existing SLA by Hop, exclude 'Register'
            delete slaByHopDeleteList;

        }

        return tempRegister;

    }

    //This method call from workduration trigger only
    public void calculateAgingHop(list<SLA_Per_Owner__c> durationPerOwnerList){
        List<SLA_By_Hop__c> slaHopList = New List<SLA_By_Hop__c>();
        //mapping 'sla by hop' Name + 'sla by hop' case__c wirt 'sla by hop' ID
        Map<String,ID> mapHopName = New Map<String,ID>(); 
        List<Case> caseRegister = New List<Case>();
        Map<ID,String> mapRegister = New Map<ID,String>(); //mapping case ID with case crestor name
        set<ID> setCaseID = new set<ID>();

        List<SLA_By_Hop__c> hopList = new list<SLA_By_Hop__c>();
        List<SLA_By_Hop__c> addNewHopList = new list<SLA_By_Hop__c>();
        list<SLA_Per_Owner__c> updateDurationList = New list<SLA_Per_Owner__c>();

        Map<String,String> mappingBUName = new Map<String,String>();
        List<Mapping_Service_BU_Name__c> mappingBUList = New List<Mapping_Service_BU_Name__c>();
        mappingBUList = [Select Name, Owner_Team__c, BU_Name__c from Mapping_Service_BU_Name__c];

        if(mappingBUList.size() > 0){
            for(Mapping_Service_BU_Name__c bu: mappingBUList ){

                String keyMapTeam = EncodingUtil.urlEncode(bu.Owner_Team__c, 'UTF-8'); 
                keyMapTeam = keyMapTeam.replaceAll('%C2%A0', '+'); //ลบอักขระพิเศษที่มองไม่เห็นด้วยตาเปล่า 
                keyMapTeam = EncodingUtil.urlDecode(keyMapTeam, 'UTF-8');
                keyMapTeam = keyMapTeam.replaceAll('/', '');
                keyMapTeam = keyMapTeam.replaceAll( '\\s+', ''); //Remove all space

                String keyMapBuName = EncodingUtil.urlEncode(bu.BU_Name__c, 'UTF-8'); 
                keyMapBuName = keyMapBuName.replaceAll('%C2%A0', '+'); //ลบอักขระพิเศษที่มองไม่เห็นด้วยตาเปล่า 
                keyMapBuName = EncodingUtil.urlDecode(keyMapBuName, 'UTF-8');                
                keyMapBuName = keyMapBuName.replaceAll('/', '');                
                keyMapBuName = keyMapBuName.replaceAll( '\\s+', ''); //Remove all space

                mappingBUName.put(keyMapTeam , keyMapBuName);
            }
        }

        if(durationPerOwnerList.size() > 0){
            for(SLA_Per_Owner__c slaowner : durationPerOwnerList){
                setCaseID.add(slaowner.case__c);
            }
            slaHopList = [Select ID, Name, Case__c from SLA_By_Hop__c where Case__c in: setCaseID];
            caseRegister = [Select ID, Created_Name__c from Case where ID in: setCaseID];
        }
       
        if(slaHopList.size() > 0){
            for(SLA_By_Hop__c hop: slaHopList){

                String keyMap = EncodingUtil.urlEncode(hop.Name, 'UTF-8'); 
                keyMap = keyMap.replaceAll('%C2%A0', '+'); //ลบอักขระพิเศษที่มองไม่เห็นด้วยตาเปล่า 
                keyMap = EncodingUtil.urlDecode(keyMap, 'UTF-8'); 
                keyMap = keyMap.replaceAll('/', '');
                keyMap = keyMap.replaceAll( '\\s+', ''); //Remove all space
                mapHopName.put(keyMap+hop.case__c, hop.ID);  //key in this map is Name + Case ID               

            }
        }

        if(caseRegister.size() > 0){
            for(Case ca: caseRegister){
                 mapRegister.put(ca.id, ca.Created_Name__c);
            }
        }


        for(SLA_Per_Owner__c slaOwner : durationPerOwnerList){
            String keyMapOwnerTeam;
            if(slaOwner.Owner_Team__c == null){
                keyMapOwnerTeam = EncodingUtil.urlEncode('Default value_Not match any thing', 'UTF-8');
            }else{
                keyMapOwnerTeam = EncodingUtil.urlEncode(slaOwner.Owner_Team__c, 'UTF-8');
            }             
            keyMapOwnerTeam = keyMapOwnerTeam.replaceAll('%C2%A0', '+'); //ลบอักขระพิเศษที่มองไม่เห็นด้วยตาเปล่า 
            keyMapOwnerTeam = EncodingUtil.urlDecode(keyMapOwnerTeam, 'UTF-8');            
            keyMapOwnerTeam = keyMapOwnerTeam.replaceAll('/', '');
            keyMapOwnerTeam = keyMapOwnerTeam.replaceAll( '\\s+', ''); //Remove all space
           
            if(slaOwner.Name == mapRegister.get(slaOwner.case__c)){
                
                    if(mapHopName.containsKey('REGISTER'+slaOwner.case__c)){
                        slaOwner.Hop_Team__c = mapHopName.get('REGISTER'+ slaOwner.case__c);
                    }else{
                        SLA_By_Hop__c register = new SLA_By_Hop__c();
                        register.Name = 'REGISTER';
                        register.Case__c = slaOwner.case__c;
                        register.Hop__c = 'N/A';
                        addNewHopList.add(register);
                        updateDurationList.add(slaOwner);
                    }
            }else if(mapHopName.containsKey(keyMapOwnerTeam + slaOwner.case__c)){
                slaOwner.Hop_Team__c = mapHopName.get(keyMapOwnerTeam + slaOwner.case__c);
            }else if(mapHopName.containsKey(mappingBUName.get(keyMapOwnerTeam) + slaOwner.case__c)){
                slaOwner.Hop_Team__c = mapHopName.get(mappingBUName.get(keyMapOwnerTeam) + slaOwner.case__c);
            }else if(slaOwner.Is_Branch__c == true){
                    if(mapHopName.containsKey('BRANCH'+ slaOwner.case__c)){
                        slaOwner.Hop_Team__c = mapHopName.get('BRANCH'+ slaOwner.case__c);
                    }else{
                        SLA_By_Hop__c other_SLA = new SLA_By_Hop__c();
                        other_SLA.Name = 'BRANCH';
                        other_SLA.Case__c = slaOwner.case__c;
                        other_SLA.Hop__c = 'N/A';
                        addNewHopList.add(other_SLA);
                        updateDurationList.add(slaOwner);
                    } 
            }else if(mapHopName.containsKey('OTHER'+ slaOwner.case__c)){
                        slaOwner.Hop_Team__c = mapHopName.get('OTHER'+ slaOwner.case__c);
                    }else{
                        SLA_By_Hop__c other_SLA = new SLA_By_Hop__c();
                        other_SLA.Name = 'OTHER';
                        other_SLA.Case__c = slaOwner.case__c;
                        other_SLA.Hop__c = 'N/A';
                        addNewHopList.add(other_SLA);
                        updateDurationList.add(slaOwner);
                    }

        }

        if(addNewHopList.size() > 0){
            insert addNewHopList;
        }
        if(updateDurationList.size() > 0){
            for(integer i =0 ; i < updateDurationList.size(); i++ ){
                updateDurationList[0].Hop_Team__c = addNewHopList[0].id;
            }
        }
    }


    public set<ID> setListCaseID(List<Case> caseList){
        set<ID> setCaseID = New set<ID>();
        if(caseList.size() > 0){
            for(case ca : caseList){
                setCaseID.add(ca.id);
            }
        }
        return setCaseID;
     }

    public Map<ID,List<SLA_By_Hop__c>> queryOldSLAByHop(set<ID> setCaseID){

        Map<ID,List<SLA_By_Hop__c>> mapSLAbyHopList = new Map<ID,List<SLA_By_Hop__c>>();

        list<SLA_By_Hop__c> oldSlaByHop = [Select ID, Name, Case__c, Hop__c, SLA_Hop_Day__c from SLA_By_Hop__c where case__c in: setCaseID];
        if(oldSlaByHop.size() > 0 ){
            for(SLA_By_Hop__c slaHop : oldSlaByHop){
                if(mapSLAbyHopList.containsKey(slaHop.Case__c)){
                    mapSLAbyHopList.get(slaHop.Case__c).add(slaHop);
                }else{
                    mapSLAbyHopList.put(slaHop.Case__c,new List<SLA_By_Hop__c>());
                    mapSLAbyHopList.get(slaHop.Case__c).add(slaHop);
                } 
            }
        }
        return mapSLAbyHopList;
    }

    public Map<ID,List<SLA_Per_Owner__c>> queryOldWorkDuration(set<ID> setCaseID){

        Map<ID,List<SLA_Per_Owner__c>> mapSLAPerOwnerList = new Map<ID,List<SLA_Per_Owner__c>>();

        list<SLA_Per_Owner__c> oldSLAPerOwner = [Select ID, Name, Owner_Team__c, Case__c, Hop_Team__c from SLA_Per_Owner__c where Case__c in: setCaseID];
        if(oldSLAPerOwner.size() > 0){
            for(SLA_Per_Owner__c slaOwner : oldSLAPerOwner){
                if(mapSLAPerOwnerList.containsKey(slaOwner.Case__c) ){
                    mapSLAPerOwnerList.get(slaOwner.Case__c).add(slaOwner);
                }else{
                    mapSLAPerOwnerList.put(slaOwner.Case__c,new List<SLA_Per_Owner__c>());
                    mapSLAPerOwnerList.get(slaOwner.Case__c).add(slaOwner);
                } 
            } 
        }
        return mapSLAPerOwnerList;

    }
}
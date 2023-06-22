public class EditSLLGroupController{
    
    @AuraEnabled
    public static String editSllG(String recordId, String selectedName, String selectedPrimCus, String selectedPAMId, String selectedRemark) {
        
        //get id requester
        Id userId = Userinfo.getUserId();
        // SELECT Record Type Name กับ isActive ของ record ที่ต้องการแก้ไข
        SLL_Group__c recGroup = [SELECT Id, RecordType.Name, Is_Active__c, Approver1__c  FROM SLL_Group__c WHERE id =: recordId limit 1];
        // SLL_Group__c recGroup = [SELECT Id, RecordType.Name, Is_Active__c, Approver1__c, Approver2__c  FROM SLL_Group__c WHERE id =: recordId limit 1];
        // SELECT Manager คนที่ 1 และ Manager คนที่ 2  ของ PAM
        User PAM = [SELECT id, Name, ManagerId, Manager.IsActive FROM User WHERE id =: selectedPAMId limit 1];
        // User PAM = [SELECT id, Name, ManagerId, Manager.IsActive, Manager.ManagerId, Manager.Manager.IsActive FROM User WHERE id =: selectedPAMId limit 1];
    
        Boolean acApprover1 = PAM.Manager.IsActive;
        // Boolean acApprover2 = PAM.Manager.Manager.IsActive;
        String nameApprover1 = PAM.ManagerId;
        // String nameApprover2 = PAM.Manager.ManagerId;
        datetime myDate = datetime.now();
        String msg = null;

        List<SLL_Group_Approval_History__c> groupAppHistLst = new List<SLL_Group_Approval_History__c>();

        //Check Approver1 & Approver2 Active(true) หรือเปล่า
        if(acApprover1) {
        // if(acApprover1 && acApprover2) {
            msg = 'active';

            recGroup.Id = recordId;
            //filter RecordType กับ IsActive
            if (recGroup.RecordType.Name == 'Available' && recGroup.Is_Active__c == true) {
                recGroup.SLL_Group_Name_To_Be__c = selectedName;
                recGroup.Primary_Customer_To_Be__c = selectedPrimCus;
                recGroup.PAM_To_Be__c = selectedPAMId;
                recGroup.Remark_To_Be__c = selectedRemark;
                recGroup.Approval_Status__c = 'Pending Approval - Update';
                recGroup.Requester__c = userId;
                recGroup.Request_Date__c = myDate;
            } else if (recGroup.RecordType.Name == 'Draft' && recGroup.Is_Active__c == false) {
                //SELECT Approval Status Pending ที่ต้องการแก้ไขของ SLL Group Approval History 
                groupAppHistLst = [SELECT Id, Approval_Status_Pending__c FROM SLL_Group_Approval_History__c WHERE SLL_Group_Name__c =: recordId];
                //loop แก้ไข Approval Status Pending = 'Pending' loop แล้วเก็บไว้ใน groupAppHistLst
                for(SLL_Group_Approval_History__c groupHistory : groupAppHistLst) {
                    groupHistory.Approval_Status_Pending__c = 'Pending';
                }
                recGroup.Name = selectedName;
                recGroup.Primary_Customer__c = selectedPrimCus;
                recGroup.PAM__c = selectedPAMId;
                recGroup.Remark__c = selectedRemark;
                recGroup.Approval_Status__c = 'Pending Approval - Active';
                recGroup.Requester__c = userId;
                recGroup.Request_Date__c = myDate;
                recGroup.Approver1__c = nameApprover1;
                // recGroup.Approver2__c = nameApprover2;
            }
            //Save point ตามชื่อ Save Database ก่อนที่จะทำการ update Database
            Savepoint sp = Database.setSavepoint();

            try{
                update recGroup;
                System.debug(recGroup);
                if(groupAppHistLst.size() > 0) update groupAppHistLst;
                
                Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
                req.setObjectId(recGroup.Id);
                // req.setComments('Get user Id Submitter.');
                req.setSubmitterId(Userinfo.getUserId());
                //คำสั่ง Approval process ให้เริ่มทำงาน
                Approval.ProcessResult result = Approval.process(req);
                System.debug('Approval result : ' + result);

            } catch (Exception e) {
                //ให้กลับไปยังจุดที่ Save Database ไว้ก่อนที่จะ update Database เพราะ error
                Database.rollback(sp);
                System.debug('Exception caught');
                System.debug(e.getMessage());
                throw new AuraHandledException(e.getMessage());
            }
        } else {
            msg = 'inactive';
        }
       return msg;
    } 
}
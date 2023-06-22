global class FXOrderReportScheduler implements Schedulable{
    global void execute(SchedulableContext sc){ 
    	//query FX_Order_Report_Schedule__c custom setting
    	List<FX_Order_Report_Schedule__c> fxOrderList = [SELECT Email_List__c
    															,User_Role_List__c
    															,Report_API_Name__c 
    													FROM FX_Order_Report_Schedule__c 
    													LIMIT 20];

    	for (FX_Order_Report_Schedule__c fxOrder : fxOrderList) {
    		//Send Remaining FX Order Report
	        String filename = fxOrder.Report_API_Name__c;
	        List<String> emailOpsList = new List<String>();

	        if (fxOrder.Email_List__c != null && fxOrder.Email_List__c.length() > 0) {
	        	  String emailStr = fxOrder.Email_List__c;
			      List<String> emailList = emailStr.split(';');

			      for (String email:emailList) {
			        	emailOpsList.add(email);
			      }
	        }

	        if (fxOrder.User_Role_List__c != null && fxOrder.User_Role_List__c.length() > 0) {
	        	  String roleStr = fxOrder.User_Role_List__c;
			      List<String> roleList = roleStr.split(';');
			      String roleCrtieriaStr = '(\''+String.join(roleList,'\',\'')+'\')';
			      String query = 'SELECT Email,UserRole.DeveloperName  FROM User WHERE IsActive = true and UserRoleId in (SELECT Id FROM UserRole where DeveloperName in '+roleCrtieriaStr+')';
			      List<User> userList = Database.query(query);
			      for (User user:userList) {
			        	emailOpsList.add(user.Email);
			      }



			       //Notify Role Not found
			       ReportExportToEmailUtil.getRoleNotFoundForReportEmail(roleList,userList,filename);
			       //Notify Role Not found
	        }

	      

	        String body = 'Please see in the attachment.';

	        ReportExportToEmailUtil.exportFuture(filename
									        	,body
									        	,ReportExportToEmailUtil.CSV_TYPE
									        	,filename
									        	,emailOpsList);
	        //Send Remaining FX Order Report
    	}
    	
    }
}
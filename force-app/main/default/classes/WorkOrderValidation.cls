public class WorkOrderValidation {
    
    public static void checkValidate(List<Work_Order__c> workOrderList)
    {
        for(Work_Order__c newWorkOrder : workOrderList){ 
            System.debug('Remark:'+newWorkOrder.Fulfillment_Remarks__c);
            if(newWorkOrder.Fulfillment_Remarks__c  != null){
                String commentText = newWorkOrder.Fulfillment_Remarks__c.replace(' ', '');   
                commentText = commentText.replace('-', '');
                commentText = commentText.replace('\r\n', ' ');
                commentText = commentText.replace('\n', ' ');
                commentText = commentText.replace('\r', ' ');
                System.debug('commentText:'+commentText);
                if(Pattern.matches('(.*[0-9]{16}.*)*', commentText)){
                    //Cannot input credit card number
                    newWorkOrder.Fulfillment_Remarks__c.addError(Label.WorkOrder_Error_CreditCard);
                }
            } 
        }
    }
}
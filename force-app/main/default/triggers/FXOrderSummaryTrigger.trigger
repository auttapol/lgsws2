trigger FXOrderSummaryTrigger on FX_Order_Summary__c (after insert,after update , before update, before insert) {

    if( trigger.isBefore && trigger.isUpdate )
    {
        FXOrderSummaryTriggerHandle.handleBeforeUpdate(trigger.new , trigger.oldMap);
    }

    if( trigger.isAfter && trigger.isUpdate )
    {
        FXOrderSummaryTriggerHandle.handleAfterUpdate(trigger.new , trigger.oldMap);
    }


    List<FX_Order_Streaming__e> newsEventList = new List<FX_Order_Streaming__e>();    
    
    for(FX_Order_Summary__c FOrSum : trigger.new){


        //===================== Check for filled Action ====================

        if( trigger.isAfter && ( trigger.isUpdate || trigger.isInsert  ) )
        {

            //================ Add Event Streaming =================

            FX_Order_Streaming__e forderStr = new FX_Order_Streaming__e();
            forderStr.Buy_Sell__c = forsum.Buy_Sell__c;
            forderStr.Currency__c  = forsum.FXS_Currency__c;
            forderStr.Currency_Pair__c  = forsum.FXS_CurrencyPair__c;
            forderStr.Exchange_Rate__c  = forsum.FXS_CustomerRate__c;
            forderStr.FX_Order_Summary_ID__c  = forsum.id;
            forderStr.Status__c  = forsum.FXS_Status__c;
            forderStr.Total_Allocate_Amount__c   = forsum.FXS_TotalAllocateAmount__c;
            forderStr.Total_Request_Amount__c   = forsum.FXS_TotalRequestAmount__c;
            newsEventList.add(forderStr);
        }

    }

    //system.debug(newsEventList);

    if( newsEventList.size() > 0 )
    {
        // Call method to publish events.
        List<Database.SaveResult> results = EventBus.publish(newsEventList);
        // Inspect publishing result for each event
        for (Database.SaveResult sr : results) {
            if (sr.isSuccess()) {
                System.debug('Successfully published event.');
            } else {
                for(Database.Error err : sr.getErrors()) {
                    System.debug('Error returned: ' +
                                err.getStatusCode() +
                                ' - ' +
                                err.getMessage());
                }
            }       
        } 
    }

}
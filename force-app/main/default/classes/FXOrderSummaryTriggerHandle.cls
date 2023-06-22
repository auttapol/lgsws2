public with sharing class FXOrderSummaryTriggerHandle {
	
	public static String FULLY_COMPLETE_STATUS = 'Fully Completed';
	public static String PARTAIL_COMPLETE_STATUS = 'Partially Completed';
	public static String NEW_STATUS = 'New';
    public static String CANCEL_STATUS = 'Cancelled';

	public static void handleBeforeUpdate(List<FX_Order_Summary__c> newList , MAP<ID,FX_Order_Summary__c> oldMap )
    {
    	//============== Update Status After Trader fill ===========================
        validateFXOrderExpiration(newList,oldMap);
    }

    public static void handleAfterUpdate(List<FX_Order_Summary__c> newList , MAP<ID,FX_Order_Summary__c> oldMap )
    {

    }

    private static void validateFXOrderExpiration(List<FX_Order_Summary__c> newList , MAP<ID,FX_Order_Summary__c> oldMap)
    {
        Map<String,FX_Order_Summary__c> changedFillAmountFXSMap = new Map<String,FX_Order_Summary__c>();
        Map<String,List<FX_Order__c>> changedFillAmountFXOMap = new Map<String,List<FX_Order__c>>();

        for( FX_Order_Summary__c newFXS : newList )
        {
            FX_Order_Summary__c oldFXS = oldMap.get(newFXS.id);

            //Add FX Order Summary to verify only when TotalAllocateAmount Changes
            if( newFXS.FXS_TotalAllocateAmount__c != oldFXS.FXS_TotalAllocateAmount__c && 
                ( newFXS.FXS_Status__c == FXOrderSummaryTriggerHandle.NEW_STATUS || newFXS.FXS_Status__c == FXOrderSummaryTriggerHandle.PARTAIL_COMPLETE_STATUS ) )
            {
                changedFillAmountFXSMap.put( newFXS.FXS_Order_Key_Before__c , newFXS);
            }
        }

        if( changedFillAmountFXSMap.size() > 0 )
        {


            List<FX_Order__c> fxoList = [SELECT id,FXO_OrderStatus__c,FXO_FXOrderSummary__c,FXO_FillAmount__c,
                    FXO_RequestAmount__c,FXO_Order_Key__c,
                    FXO_Expiration_Date__c,FXO_GTC__c
                    FROM FX_Order__c
                    WHERE FXO_Order_Key__c in: changedFillAmountFXSMap.keySet()
                    AND ( FXO_OrderStatus__c =: FXOrderTriggerHandler.SUBMIT_STATUS 
                        OR FXO_OrderStatus__c =: FXOrderTriggerHandler.INPROGRESS_STATUS  )
                    ];


            for( FX_Order__c fxo : fxoList )
            {
                 //String realKey = FXOrderTriggerHandler.getRealKeyForFXO(fxo);
                 //if( !changedFillAmountFXOMap.containsKey( realKey ) )
                 //{
                 //   changedFillAmountFXOMap.put( realKey ,  new List<FX_Order__c>() );
                 //}

                 //changedFillAmountFXOMap.get( realKey ).add(fxo);
                 String orderKey = fxo.FXO_Order_Key__c;
                  if( !changedFillAmountFXOMap.containsKey( orderKey ) )
                 {
                    changedFillAmountFXOMap.put( orderKey ,  new List<FX_Order__c>() );
                 }

                 changedFillAmountFXOMap.get( orderKey ).add(fxo);
            }


            Map<String,FX_Order_Summary__c> invalidFXSList = new Map<String,FX_Order_Summary__c>();
            List<FX_Order__c> expiredOrder = new List<FX_Order__c>();

            for( String orderSumKey : changedFillAmountFXSMap.keySet() )
            {
                Boolean isValidFXS = true;

                List<FX_Order__c> ol = changedFillAmountFXOMap.get(orderSumKey);

                //Loop to check all order that not expired
                if( ol != null )
                {
                    for( FX_Order__c o : ol )
                    {
                        if( o.FXO_Expiration_Date__c < System.Now() )
                        {
                            isValidFXS = false;
                            expiredOrder.add(o);
                        }
                    }
                }
                else 
                {
                    isValidFXS = false;
                }

                if( !isValidFXS )
                {
                    
                    FX_Order_Summary__c invalidFXS = changedFillAmountFXSMap.get(orderSumKey);
                    invalidFXSList.put( invalidFXS.FXS_Order_Key__c , changedFillAmountFXSMap.get(orderSumKey) );
                }
            }

            //recalculate FXS

            List<Id> expiredOrderIds = new List<Id>();
            if( expiredOrder.size() > 0 )
            {
                for( FX_Order__c o : expiredOrder )
                {
                    if( o.FXO_Expiration_Date__c < System.Now() )
                    {
                        expiredOrderIds.add(o.Id);
                        //o.FXO_OrderStatus__c = FXOrderTriggerHandler.EXPIRED_STATUS;

                    }
                }
            }

            //system.debug(expiredOrderIds);

            //if( expiredOrderIds.size() > 0 )
            //{
            //    FXOrderSummaryTriggerHandle.updateOrderStatusToCancel(expiredOrderIds);
            //}

            //Throw error for invalid Order
            for( FX_Order_Summary__c fxsError : invalidFXSList.values() )
            {
                fxsError.addError(Label.FX_Order_Summary_Invalid_Order);
            }
        }
    }

    //@future
    //public static void updateOrderStatusToCancel(List<Id> expiredOrderIds)
    //{   
    //    List<FX_Order__c> expiredOrderList = [ SELECT Id,FXO_OrderStatus__c FROM FX_Order__c WHERE Id in :expiredOrderIds ];

    //    for(FX_Order__c expiredFXO : expiredOrderList )
    //    {
    //        expiredFXO.FXO_OrderStatus__c = FXOrderTriggerHandler.EXPIRED_STATUS;
    //    }
    //    update expiredOrderList;

    //    system.debug('update haha' + expiredOrderList);
    //     // Perform some operations
    //}

    
    
}
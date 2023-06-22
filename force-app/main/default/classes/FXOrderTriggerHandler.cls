public class FXOrderTriggerHandler {
    
    public static String SUBMIT_STATUS = 'Submitted';
    public static String INPROGRESS_STATUS = 'InProgress';
    public static String DONE_STATUS = 'Done';
    public static String CANCEL_STATUS = 'Cancelled';
    public static String NOT_ALLOCATED_STATUS = 'Not Allocated';
    public static String EXPIRED_STATUS = 'Expired';
    public static String ACKNOWLEDGE_STATUS = 'Acknowledge';
    public static String NEW_STATUS = 'New';

    public static void handleBeforeInsert(List<FX_Order__c> fxorderList)
    {

        // ========= Force all new order status set to new if not import flag set
        for( FX_Order__c o : fxorderList )
        {

            
            if( o.FXO_From_Import_Flag__c != true )
            {
                //========== manual set other status and request amount
                o.FXO_OrderStatus__c = NEW_STATUS;
            }
            
        }    


    }

    public static void handleBeforeUpdate(List<FX_Order__c> fxorderList , MAP<ID,FX_Order__c> odlFxorderMap )
    {
        Id fxOrderRecordTypeId = Schema.Sobjecttype.FX_Order__c.getRecordTypeInfosByName().get('FX Order').getRecordTypeId();
        Id fxOrderCompleteRecordTypeId = Schema.Sobjecttype.FX_Order__c.getRecordTypeInfosByName().get('FX Order (Completed)').getRecordTypeId();

        for( FX_Order__c o : fxorderList )
        {
            if( o.FXO_OrderStatus__c == 'Cancelled' )
            {
                o.RecordTypeId = fxOrderCompleteRecordTypeId;
            }
        }
    }


    public static void handleAfterInsert(List<FX_Order__c> fxorderList , MAP<ID,FX_Order__c> odlFxorderMap )
    {
       
        verifyOrderAndUpdateFXOrderSummary(fxorderList,odlFxorderMap);

        // ========= Update Original Order iuf order clone from the order
        for( FX_Order__c o : fxorderList )
        {

            List<Id> originalFXOList = new List<Id>();
            Map<Id,FX_Order__c> orderOriginIdFXOItemMap = new Map<Id,FX_Order__c>();
            if( o.FX_Order_Clone_Reference__c != null )
            {
                originalFXOList.add(o.FX_Order_Clone_Reference__c );
                orderOriginIdFXOItemMap.put(o.FX_Order_Clone_Reference__c,o);
            }

            if( originalFXOList.size() > 0 )
            {
                List<FX_Order__c> updatedFXOList = [SELECT id,FXO_Is_Order_Cloned__c FROM FX_Order__c
                                    WHERE id in :originalFXOList
                                ];

                for( FX_Order__c fxo : updatedFXOList )
                {
                    //========== manual set other status and request amount
                    fxo.FXO_Is_Order_Cloned__c = true;
                    if( orderOriginIdFXOItemMap.containsKey( fxo.id  ) )
                    {
                        fxo.FX_Order_Clone_Item__c = orderOriginIdFXOItemMap.get( fxo.id ).id;
                    }
                }

                update updatedFXOList;
            }

            
        }    

    }

    public static void handleAfterUpdate(List<FX_Order__c> fxorderList , MAP<ID,FX_Order__c> odlFxorderMap )
    {
        
        verifyOrderAndUpdateFXOrderSummary(fxorderList,odlFxorderMap);   
    }

    public static void verifyOrderAndUpdateFXOrderSummary(List<FX_Order__c> fxorderList , MAP<ID,FX_Order__c> odlFxorderMap )
    {
        //============ Update FX Order Summary form submitted order ====================
        List<FX_Order__c> submittedOrder = new List<FX_Order__c>();
        //List<FX_Order__c> expiredOrder = new List<FX_Order__c>();

        for( FX_Order__c o : fxorderList )
        {
            if( o.FXO_OrderStatus__c == SUBMIT_STATUS )
            {
                submittedOrder.add(o);
            }
            else if(o.FXO_OrderStatus__c == CANCEL_STATUS)
            {
                submittedOrder.add(o);
            }
            else if(o.FXO_OrderStatus__c == EXPIRED_STATUS)
            {
                submittedOrder.add(o);
            }

        }

        //========= Update submitted order ===========
        if( submittedOrder.size() > 0 )
        {
            updateToFXOrderSummary(submittedOrder , odlFxorderMap );
        }
    }

    public static void updateToFXOrderSummary(List<FX_Order__c> fxorderList , MAP<ID,FX_Order__c> odlFxorderMap )
    {
         Map<String,List<FX_Order__C>> keywithOrdersMap = new Map<String,List<FX_Order__C>>();

         Set<String> currencySet = new Set<String>();
         Set<Decimal> crateSet = new Set<Decimal>();

         for(FX_Order__c Forder : fxorderList)
         {
                          
            String realKey = getRealKeyForFXO(Forder);

            if( realKey != '' )
            {
                if(keywithOrdersMap.containskey( realKey ) )
                {
                    keywithOrdersMap.get( realKey ).add(Forder);
                }
                else
                {
                    List<FX_Order__C> newforderlist =new List<FX_ORder__C>();
                    newforderlist.add(Forder);
                    keywithOrdersMap.put(realKey,newforderlist);
                }
            }
         }

        
         List<String> changeOrderKey = new List<String>();
         if( odlFxorderMap != null )
         {
             
             for( FX_Order__c oldOrder : odlFxorderMap.values() )
             {
                String realKey = getRealKeyForFXO(oldOrder);
                if( realKey != '' && realKey != null )
                {
                    changeOrderKey.add( realKey );
                }
             }
         }

         List<FX_Order_Summary__c> ordersumList = [SELECT ID,NAME,FXS_CustomerRate__c,FXS_Currency__C,FXS_Order_Key__c,
                                                    FXS_TotalRequestAmount__c,FXS_TotalOrdersNumber__c,FXS_NoOfActiveOrders__c,
                                                    FXS_CurrencyPair__c,Buy_Sell__c,FXS_Status__c
                                                    from FX_Order_Summary__c
                                                    WHERE ( FXS_Order_Key__c in: keywithOrdersMap.keyset() 
                                                    OR FXS_Order_Key__c in: changeOrderKey )
                                                  ];

         Map<String,FX_Order_Summary__c> FOrsumMap = new Map<String,FX_Order_Summary__c>();

         
         for(FX_Order_Summary__c ForSum : ordersumList){
            FOrsumMap.put( ForSum.FXS_Order_Key__c ,ForSum);
         }


          //Map<String,List<FX_Order__C>> keywithNewOrdersMap = new Map<String,List<FX_Order__C>>();

          List<FX_Order__C> orderUpdateOrderSum = new List<FX_Order__C>();

          Set<String> orderKeySet = new Set<String>();

          if(  keywithOrdersMap.keySet().size() > 0 )
          {
                orderKeySet.addAll( keywithOrdersMap.keySet() );
          }

          if( changeOrderKey.size() > 0 )
          {
                orderKeySet.addAll( changeOrderKey );
          }

          if( orderKeySet.size() > 0 )
          {
                List<FX_Order_Summary__c> fxsList = recalculateFXS( orderKeySet , FOrsumMap  );
               
                Map<Id,String> fxsErrorIdMap = tryPartailUpsert(fxsList);
                List<FX_Order_Summary__c>  errorFXSList = getErrorFXSfromId(fxsErrorIdMap.keySet() ,fxsList);
                
                // Start retry 3 times
                if( errorFXSList.size() > 0 )
                {
                    Integer tryCount = 1;

                   while ( tryCount < 3 && errorFXSList.size() > 0 ) 
                   {
                        system.debug( 'Retry(' + tryCount + ') for upsert fx order summary.' );

                        fxsErrorIdMap = tryPartailUpsert(errorFXSList);
                        errorFXSList = getErrorFXSfromId(fxsErrorIdMap.keySet() ,fxsList);

                        tryCount++;                              
                   }
                }

                // Now add error
                if( errorFXSList.size() > 0 )
                {
                    Set<String> orderKeyerror = new Set<String>();

                    Map<String,String> fxsOrderKeyErrorMap = new Map<String,String>();
                    for( FX_Order_Summary__c errorFXS : errorFXSList )
                    {
                        orderKeyerror.add( errorFXS.FXS_Order_Key__c );
                        fxsOrderKeyErrorMap.put( errorFXS.FXS_Order_Key__c , fxsErrorIdMap.get( errorFXS.id ) );
                        
                    }

                    for(FX_Order__c fxo : fxorderList)
                    {
                        if( orderKeyerror.contains( fxo.FXO_Order_Key__c ) )
                        {
                            fxo.addError( fxsOrderKeyErrorMap.get( fxo.FXO_Order_Key__c ) );
                        }
                    }
                    
                }

                //try
                //{
                //    upsert osList FXS_Order_Key__c;    
                //} 
                //catch(Exception e) 
                //{
                //    //System.debug(e.getMessage());

                //    if( e.getMessage().contains( 'duplicate value found: FXS_Order_Key__c duplicates value on record' ) )
                //    {
                //        Integer tryCount = 1;
                //        Boolean isUpsertError = true;
                //        while ( tryCount < 3 && isUpsertError == true ) 
                //        {
                //            system.debug( 'Retry(' + tryCount + ') for upsert fx order summary.' );
                //            Boolean isSuccess = retryUpsert(osList);
                //            if( isSuccess )
                //            {
                //                isUpsertError = false;
                //            }
                //            else 
                //            {
                //                isUpsertError = true;    
                //            }
                //            tryCount++;  
                            
                //        }

                //        if( isUpsertError == true )
                //        {
                //            fxorderList[0].addError(new myException(Label.FXO_Submit_Fail_Traffic_Text));
                //        }
                //    }
                //    else 
                //    {
                //        fxorderList[0].addError(new myException( e.getMessage() ));
                          
                //    }
                    
                //}
          }
    }

    public class MyException extends Exception {}

    public static List<FX_Order_Summary__c> getErrorFXSfromId(Set<ID> fxsErrorIdList , List<FX_Order_Summary__c> fxsList )
    {
        List<FX_Order_Summary__c>  errorFXSList = new List<FX_Order_Summary__c>();

        for( FX_Order_Summary__c fxs : fxsList )
        {
            if( fxsErrorIdList.contains(fxs.id) )
            {
                errorFXSList.add(fxs);
            }
        }

        return errorFXSList;

    }

    public static Map<Id,String> tryPartailUpsert( List<FX_Order_Summary__c> fxsList)
    {
        Database.UpsertResult[] results = Database.upsert(fxsList, FX_Order_Summary__c.FXS_Order_Key__c,false);

        Map<Id,String> failedResult = new Map<Id,String>();

        for(Integer index = 0, size = results.size(); index < size; index++) {
            if(results[index].isSuccess()) {
                // Do nothing
            }
            else 
            {
                String error = '';
                for(  Database.Error dbErr : results[index].getErrors() )
                {
                    error = dbErr.getMessage() + ' ';
                }
                failedResult.put( results[index].getId() , error );
            }
        }

        return failedResult;
    }

    public static boolean retryUpsert( List<FX_Order_Summary__c> fxsList )
    {
        try
        {
            upsert fxsList FXS_Order_Key__c; 
            return true;   
        } 
        catch(Exception e) 
        {
            return false;
        }
    }

    public static List<FX_Order_Summary__c> recalculateFXS( Set<String> orderKeySet ,Map<String,FX_Order_Summary__c> FXSMap )
    {
        Map<String,FX_Order_Summary__c> FXSUpdatedMap = new Map<String,FX_Order_Summary__c>();
        Set<String> orderNewStatus = new set<String>();
        Set<String> orderPartialStatus = new set<String>();

         // Generate New FX order by fx order item in trigger
         for( string orderKey : orderKeySet )
         {
            FX_Order_Summary__c FXSItem;
            
            if( !FXSMap.containsKey( orderKey ) )
            {
                FXSItem = new FX_Order_Summary__c();
                FXSItem.FXS_Status__c = FXOrderSummaryTriggerHandle.NEW_STATUS;
                FXSItem.FXS_Order_Key__c = orderKey;
            }
            else 
            {
                FXSItem = FXSMap.get( orderKey );
            }

            FXSItem.FXS_TotalRequestAmount__c = 0;
            FXSItem.FXS_TotalOrdersNumber__c  = 0;
            FXSItem.FXS_NoOfActiveOrders__c = 0;

            FXSUpdatedMap.put(orderKey, FXSItem); 

            if( FXSItem.FXS_Status__c == FXOrderSummaryTriggerHandle.NEW_STATUS ) 
            {
                orderNewStatus.add(orderKey);
            }
            
            if( FXSItem.FXS_Status__c == FXOrderSummaryTriggerHandle.PARTAIL_COMPLETE_STATUS ) 
            {
                orderPartialStatus.add(orderKey);   
            }
         }


        List<FX_Order__C> orderList = [ SELECT id,FXO_OrderStatus__c,FXO_CustomerRate__c,FXO_RequestAmount__c,
            FXO_CurrencyPair__c,FXO_BuySell__c,FXO_Order_Key__c,FXO_Currency__c,FXO_FXOrderSummary__c,FXO_InterbankRate__c 
            FROM FX_Order__C 
            WHERE ( FXO_FXOrderSummary__c in: orderPartialStatus 
                AND FXO_OrderStatus__c =: FXOrderTriggerHandler.INPROGRESS_STATUS )
            OR ( FXO_Order_Key__c in: orderNewStatus 
                AND FXO_OrderStatus__c =: FXOrderTriggerHandler.SUBMIT_STATUS )
            
        ];

        for( FX_Order__C o : orderList )
        {
            String realKey = getRealKeyForFXO(o);
            FX_Order_Summary__c os = FXSUpdatedMap.get( realKey );

            os.FXS_CustomerRate__c = o.FXO_InterbankRate__c;
            os.FXS_Currency__c = o.FXO_Currency__c ;
            os.FXS_TotalRequestAmount__c = os.FXS_TotalRequestAmount__c + o.FXO_RequestAmount__c;
            os.FXS_TotalOrdersNumber__c  = os.FXS_TotalOrdersNumber__c  + 1;
            os.FXS_NoOfActiveOrders__c = os.FXS_NoOfActiveOrders__c + 1;
            os.FXS_CurrencyPair__c = o.FXO_CurrencyPair__c;
            os.Buy_Sell__c = o.FXO_BuySell__c;
            os.FXS_Order_Key_Before__c = o.FXO_Order_Key__c;

        }

        List<FX_Order_Summary__c> osList = new List<FX_Order_Summary__c>();
        for( FX_Order_Summary__c os : FXSUpdatedMap.values() )
        {
            osList.add(os);
        }

        return osList;
    }

    public static String getRealKeyForFXO(FX_Order__c fxo)
    {
        String realKey = '';

        if( fxo.FXO_OrderStatus__c == SUBMIT_STATUS  )
        {
           realKey = fxo.FXO_Order_Key__c ;
        }
        else if( fxo.FXO_OrderStatus__c == INPROGRESS_STATUS || fxo.FXO_OrderStatus__c == DONE_STATUS  )
        {
            realKey = fxo.FXO_FXOrderSummary__c;
        }

        return realKey;
    }

   
 
}
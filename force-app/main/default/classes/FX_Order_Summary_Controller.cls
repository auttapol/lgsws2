public without sharing class FX_Order_Summary_Controller {

    private static Integer itemPerPage{
        get{
            if(itemPerPage == null){
                FX_Blotter_Setting__mdt itemPage = [select id,FX_Dashboard_Item_Page__c
                from FX_Blotter_Setting__mdt 
                where DeveloperName = 'Fx_Order_Setting'];
                itemPerPage = integer.valueOf(itemPage.FX_Dashboard_Item_Page__c);
            }
            return itemPerPage;
        }
        set;
    }

    private static User currentUserInfo{
        get{
            if( currentUserInfo == null )
            {
                currentUserInfo = [SELECT Id, Username, Segment__c ,Reporting_Segment__c, Profile.name
                    FROM User 
                    WHERE Id =: UserInfo.getUserId()
                    LIMIT 1];
            }

            return currentUserInfo;
        }
        set;
    }

    private static FX_Blotter_Profile_Manager__mdt fxBlotterProfile{
        get{
            if(fxBlotterProfile == null){
                try
                {
                    fxBlotterProfile = [select id,Profile_Name__c,
                        FX_Dashboard_Allow_Edit__c, FX_Dashboard_Allow_Read__c, FX_Order_Allow_Allocate__c
                    from FX_Blotter_Profile_Manager__mdt 
                    where Profile_Name__c = : currentUserInfo.Profile.name ];
                }
                catch (Exception e)
                {
                    fxBlotterProfile = null;
                }
            }
            return fxBlotterProfile;
        }
        set;
    }

    public Class OrderSummaryWrapper
    {
        @AuraEnabled
        public List<FX_Order_Summary__c> orderBuyList {get;set;}
        @AuraEnabled
        public List<FX_Order_Summary__c> orderSellList {get;set;}
    }
  
    @AuraEnabled
    public static Integer getItemPerPage()
    {
        return itemPerPage;
    }

    @AuraEnabled
    public static Map<String, integer> getFXSItemAmount(String searchKey)
    {
        Map<String, integer> result = new Map<String, integer>();
        
        String newSearchText = '%' + searchKey + '%';

        try
        {

            integer orderBuyItem = 
                    [SELECT 
                        count()
                        FROM FX_Order_Summary__c
                        WHERE FXS_Currency__c LIKE :newSearchText
                        AND Buy_Sell__c = 'buy'
                        AND FXS_Status__c =: FXOrderSummaryTriggerHandle.NEW_STATUS 
                        AND FXS_TotalRequestAmount__c > 0
                        ];

            integer orderSellItem = 
                    [SELECT 
                        count()
                        FROM FX_Order_Summary__c
                        WHERE FXS_Currency__c LIKE :newSearchText
                        AND Buy_Sell__c = 'sell'
                        AND FXS_Status__c =: FXOrderSummaryTriggerHandle.NEW_STATUS 
                        AND FXS_TotalRequestAmount__c > 0
                        ];
            result.put('orderBuyItem', orderBuyItem);
            result.put('orderSellItem', orderSellItem);
            result.put('itemPerPage', itemPerPage);
        }
        catch (Exception e)
        {
            throw new AuraHandledException('System Exception: ' + e.getMessage() + '(' + e.getLineNumber() +')' );
        }

        return result;
    }


    @AuraEnabled
    public static OrderSummaryWrapper getFXSOrder(String searchKey, Integer Buypage, Integer Sellpage ) {

        OrderSummaryWrapper osw = new OrderSummaryWrapper();

        String newSearchText = '%' + searchKey + '%';
        Integer BuypageNo = (integer.valueof(Buypage) - 1) * itemPerPage;
        Integer SellpageNo = (integer.valueof(Sellpage) - 1) * itemPerPage;

        try
        {
            osw.orderBuyList = 
                    [SELECT 
                        Id,FXS_Currency__c, FXS_CurrencyPair__c, FXS_CustomerRate__c, Buy_Sell__c ,FXS_TotalRequestAmount__c,
                        FXS_TotalAllocateAmount__c,Total_Request_Amount_Million_Unit__c,FXS_Order_Key__c,
                        LastModifiedDate, LastModifiedBy.Name
                        FROM FX_Order_Summary__c
                        WHERE FXS_Currency__c LIKE :newSearchText
                        AND Buy_Sell__c = 'buy'
                        AND FXS_Status__c =: FXOrderSummaryTriggerHandle.NEW_STATUS 
                        AND FXS_TotalRequestAmount__c > 0
                        ORDER BY SortingCurrency__c , FXS_CurrencyPair__c , FXS_CustomerRate__c
                        LIMIT :itemPerPage
                        OFFSET :BuypageNo
                        ];

            osw.orderSellList = 
                    [SELECT 
                        Id,FXS_Currency__c, FXS_CurrencyPair__c, FXS_CustomerRate__c, Buy_Sell__c ,FXS_TotalRequestAmount__c,
                        FXS_TotalAllocateAmount__c,Total_Request_Amount_Million_Unit__c,FXS_Order_Key__c,
                        LastModifiedDate, LastModifiedBy.Name
                        FROM FX_Order_Summary__c
                        WHERE FXS_Currency__c LIKE :newSearchText
                        AND Buy_Sell__c = 'sell'
                        AND FXS_Status__c =: FXOrderSummaryTriggerHandle.NEW_STATUS 
                        AND FXS_TotalRequestAmount__c > 0
                        ORDER BY SortingCurrency__c , FXS_CurrencyPair__c , FXS_CustomerRate__c DESC
                        LIMIT :itemPerPage
                        OFFSET :SellpageNo
                        ];
        }
        catch (Exception e)
        {
            throw new AuraHandledException('System Exception: ' + e.getMessage() + '(' + e.getLineNumber() +')' );
        }

        return osw;
    }


	@AuraEnabled
    public static List<FX_Order_Summary__c> getbuyOrder() {
        List<FX_Order_Summary__c> order = 
                [SELECT 
                	Id,FXS_Currency__c, FXS_CurrencyPair__c, FXS_CustomerRate__c, Buy_Sell__c ,FXS_TotalRequestAmount__c,
                    FXS_TotalAllocateAmount__c,Total_Request_Amount_Million_Unit__c,FXS_Order_Key__c,
                    LastModifiedDate, LastModifiedBy.Name
                	FROM FX_Order_Summary__c
                	WHERE Buy_Sell__c = 'buy'
                    AND FXS_Status__c =: FXOrderSummaryTriggerHandle.NEW_STATUS 
                    AND FXS_TotalRequestAmount__c > 0
                    ORDER BY SortingCurrency__c , FXS_CurrencyPair__c , FXS_CustomerRate__c 
                	];
        return order;
    }

    @AuraEnabled
    public static List<FX_Order_Summary__c> getSellOrder() {
        List<FX_Order_Summary__c> order = 
                [SELECT 
                	Id,FXS_Currency__c, FXS_CurrencyPair__c, FXS_CustomerRate__c, Buy_Sell__c ,FXS_TotalRequestAmount__c,
                    FXS_TotalAllocateAmount__c,Total_Request_Amount_Million_Unit__c,FXS_Order_Key__c,
                    LastModifiedDate, LastModifiedBy.Name
                	FROM FX_Order_Summary__c
                	WHERE Buy_Sell__c = 'sell'
                    AND FXS_Status__c =: FXOrderSummaryTriggerHandle.NEW_STATUS 
                    AND FXS_TotalRequestAmount__c > 0
                    ORDER BY SortingCurrency__c , FXS_CurrencyPair__c , FXS_CustomerRate__c desc
                	];
        return order;
    }

    @AuraEnabled
    public static List<FX_Order__c> getSubmittedOrderByFXS(Id FXSId) {

        String orderKey = '';
        String orderStatus = '';

        try {
            FX_Order_Summary__c fxs = 
                [SELECT 
                    Id , FXS_Order_Key__c , FXS_Status__c
                    //,FXS_Currency__c, FXS_CurrencyPair__c, FXS_CustomerRate__c, Buy_Sell__c ,FXS_TotalRequestAmount__c
                    FROM FX_Order_Summary__c
                    WHERE id = :FXSId
                    ];

            orderKey = fxs.FXS_Order_Key__c;
            orderStatus = fxs.FXS_Status__c;
            
        } catch(Exception e) {
            System.debug(e.getMessage());
        }
        
        List<FX_Order__c> orderList = new  List<FX_Order__c>();
        if( orderStatus == FXOrderSummaryTriggerHandle.NEW_STATUS )
        {

           orderList = [SELECT id,Name,FXO_Customer__c,FXO_Customer__r.name,FXO_BuySell__c,
                            OwnerId,Owner.Name,FXO_GTC__c,FXO_Expiration_Date__c,FXO_OrderStatus__c,
                            FXO_RequestAmount__c,FXO_FillAmount__c,FXO_RemainingAmount__c,
                            FXO_Currency__c,FXO_CurrencyPair__c,FXO_CustomerRate__c,FXO_InterbankRate__c,
                            Owner_s_Segment__c, Owner_s_Segment_stamp__c , FXO_Cancelled_Remaining_Amount_By_Stamp__c,
                            FXO_Bypass_InterbankRate__c,FXO_Remark__c,FXO_Is_Order_Cloned__c,
                            LastModifiedDate, LastModifiedBy.Name
                            FROM FX_Order__c
                            WHERE FXO_Order_Key__c = :orderKey
                            AND FXO_FXOrderSummary__c = null
                            AND FXO_OrderStatus__c =: FXOrderTriggerHandler.SUBMIT_STATUS
                        ];
        }
        else if( orderStatus == FXOrderSummaryTriggerHandle.PARTAIL_COMPLETE_STATUS )
        {
            orderList = [SELECT id,Name,FXO_Customer__c,FXO_Customer__r.name,FXO_BuySell__c,
                            OwnerId,Owner.Name,FXO_GTC__c,FXO_Expiration_Date__c,FXO_OrderStatus__c,
                            FXO_RequestAmount__c,FXO_FillAmount__c,FXO_RemainingAmount__c,
                            FXO_Currency__c,FXO_CurrencyPair__c,FXO_CustomerRate__c,FXO_InterbankRate__c,
                            Owner_s_Segment__c, Owner_s_Segment_stamp__c , FXO_Cancelled_Remaining_Amount_By_Stamp__c,
                            FXO_Bypass_InterbankRate__c,FXO_Remark__c,FXO_Is_Order_Cloned__c,
                            LastModifiedDate, LastModifiedBy.Name
                            FROM FX_Order__c
                            WHERE FXO_FXOrderSummary__c = :FXSId
                            // AND FXO_OrderStatus__c =: FXOrderTriggerHandler.INPROGRESS_STATUS
                        ];
        }
        else if( orderStatus == FXOrderSummaryTriggerHandle.FULLY_COMPLETE_STATUS )
        {
            orderList = [SELECT id,Name,FXO_Customer__c,FXO_Customer__r.name,FXO_BuySell__c,
                            OwnerId,Owner.Name,FXO_GTC__c,FXO_Expiration_Date__c,FXO_OrderStatus__c,
                            FXO_RequestAmount__c,FXO_FillAmount__c,FXO_RemainingAmount__c,
                            FXO_Currency__c,FXO_CurrencyPair__c,FXO_CustomerRate__c,FXO_InterbankRate__c,
                            Owner_s_Segment__c, Owner_s_Segment_stamp__c , FXO_Cancelled_Remaining_Amount_By_Stamp__c,
                            FXO_Bypass_InterbankRate__c,FXO_Remark__c,FXO_Is_Order_Cloned__c,
                            LastModifiedDate, LastModifiedBy.Name
                            FROM FX_Order__c
                            WHERE FXO_FXOrderSummary__c = :FXSId
                            //  AND ( FXO_OrderStatus__c =: FXOrderTriggerHandler.DONE_STATUS
                            //     OR FXO_OrderStatus__c =: FXOrderTriggerHandler.NOT_ALLOCATED_STATUS
                            //     OR FXO_OrderStatus__c =:  FXOrderTriggerHandler.ACKNOWLEDGE_STATUS )
                        ];
        }
        else if( orderStatus == FXOrderSummaryTriggerHandle.CANCEL_STATUS )
        {
            // Now let try to show all order status in cancel status 
            orderList = [SELECT id,Name,FXO_Customer__c,FXO_Customer__r.name,FXO_BuySell__c,
                            OwnerId,Owner.Name,FXO_GTC__c,FXO_Expiration_Date__c,FXO_OrderStatus__c,
                            FXO_RequestAmount__c,FXO_FillAmount__c,FXO_RemainingAmount__c,
                            FXO_Currency__c,FXO_CurrencyPair__c,FXO_CustomerRate__c,FXO_InterbankRate__c,
                            Owner_s_Segment__c, Owner_s_Segment_stamp__c , FXO_Cancelled_Remaining_Amount_By_Stamp__c,
                            FXO_Bypass_InterbankRate__c,FXO_Remark__c,FXO_Is_Order_Cloned__c,
                            LastModifiedDate, LastModifiedBy.Name
                            FROM FX_Order__c
                            WHERE FXO_FXOrderSummary__c = :FXSId
                            // AND FXO_OrderStatus__c =: FXOrderTriggerHandler.CANCEL_STATUS
                        ];
        }

        return orderList;
    }

    @AuraEnabled
    public static FX_Order__c getFXO(Id fxoId)
    {
        FX_Order__c fxo = 
                [SELECT id, Name, FXO_Customer__c,
                        FXO_BuySell__c, FXO_Currency__c, FXO_CurrencyPair__c, FXO_CustomerRate__c, FXO_RequestAmount__c, FXO_RemainingAmount__c,
                        FXO_Bypass_InterbankRate__c, FXO_InterbankRate__c, FXO_OrderStatus__c, FXO_Expiration_Date__c, FXO_GTC__c, FXO_Remark__c,
                        FXO_Is_Order_Cloned__c
                FROM FX_Order__c 
                WHERE id=:fxoId 
                ];

        return fxo;
    }

    @AuraEnabled
    public static FX_Order_Summary__c getFXS(Id FXSId) 
    {
        FX_Order_Summary__c order = 
                [SELECT 
                    Id,FXS_TotalRequestAmount__c,FXS_TotalAllocateAmount__c,Total_Request_Amount_Million_Unit__c,
                    FXS_Status__c,FXS_Order_Key__c,FXS_Order_Key_Before__c,
                    FXS_CurrencyPair__c, FXS_CustomerRate__c
                    FROM FX_Order_Summary__c
                    WHERE id=:FXSId
                    ];
        return order;
    }

    @AuraEnabled
    public static FX_Order_Summary__c adjustOrderSummary( FX_Order_Summary__c newFXS ){
        FX_Order_Summary__c actualFXS = getFXS(newFXS.id);
        String errorMessage = '';

        try
        {
            if( actualFXS.FXS_Status__c == FXOrderSummaryTriggerHandle.NEW_STATUS )
            {
                actualFXS.FXS_Order_Key__c = newFXS.id;
                actualFXS.FXS_TotalAllocateAmount__c = newFXS.FXS_TotalAllocateAmount__c;
                actualFXS.OwnerId = UserInfo.getUserId();

                if( newFXS.FXS_TotalAllocateAmount__c == actualFXS.FXS_TotalRequestAmount__c )
                {
                    actualFXS.FXS_Status__c = FXOrderSummaryTriggerHandle.FULLY_COMPLETE_STATUS;
                    updateToFullyCompleted(actualFXS);
                }
                else if ( newFXS.FXS_TotalAllocateAmount__c < actualFXS.FXS_TotalRequestAmount__c )
                {
                    actualFXS.FXS_Status__c = FXOrderSummaryTriggerHandle.PARTAIL_COMPLETE_STATUS;
                    updateToPartiallyCompleted(actualFXS);
                }            
                update actualFXS;    
                
            }
            else if( actualFXS.FXS_Status__c == FXOrderSummaryTriggerHandle.PARTAIL_COMPLETE_STATUS )
            {
                actualFXS.FXS_TotalAllocateAmount__c = newFXS.FXS_TotalAllocateAmount__c;
                actualFXS.OwnerId = UserInfo.getUserId();

                if( newFXS.FXS_TotalAllocateAmount__c == actualFXS.FXS_TotalRequestAmount__c )
                {
                    actualFXS.FXS_Status__c = FXOrderSummaryTriggerHandle.FULLY_COMPLETE_STATUS;

                    updateToFullyCompleted(actualFXS);
                }
                else if ( newFXS.FXS_TotalAllocateAmount__c < actualFXS.FXS_TotalRequestAmount__c )
                {
                    //Do nothing in this case, adjust only value from partail to partail

                    //actualFXS.FXS_Status__c = FXOrderSummaryTriggerHandle.PARTAIL_COMPLETE_STATUS;

                    
                }
                update actualFXS;
                
            }
            else 
            {
                errorMessage = Label.FXS_Invalid_Staus_not_New;
                //throw new AuraHandledException('Order Summary Status you fill not in "New".');
            }
            
        }
        catch (Exception e)
        {
            throw new AuraHandledException('System Exception: ' + e.getMessage() + '(' + e.getLineNumber() +')' );
        }
       
        if( errorMessage != '' )
        {
            throw new AuraHandledException(errorMessage);
        }

        return actualFXS;
    }

    @AuraEnabled
    public static FX_Order_Summary__c updateOrderSummary( FX_Order_Summary__c newFXS )
    {
        String errorMessage = '';
        
        // Get actual Order Summary Value to compare amount
        FX_Order_Summary__c actualFXS = getFXS(newFXS.id);

        try
        {
            if( actualFXS.FXS_Status__c == FXOrderSummaryTriggerHandle.NEW_STATUS )
            {
                if( newFXS.FXS_TotalAllocateAmount__c <= actualFXS.FXS_TotalRequestAmount__c )
                {
                    //================ Set FX Order Summary Status base on Total fill amount ===========
                    if( newFXS.FXS_TotalAllocateAmount__c == actualFXS.FXS_TotalRequestAmount__c )
                    {
                        // Fully complete when allocate = total
                        actualFXS.FXS_Status__c = FXOrderSummaryTriggerHandle.FULLY_COMPLETE_STATUS;
                    }
                    else if ( newFXS.FXS_TotalAllocateAmount__c < actualFXS.FXS_TotalRequestAmount__c )
                    {
                        // Partail complete when allocate < total
                        actualFXS.FXS_Status__c = FXOrderSummaryTriggerHandle.PARTAIL_COMPLETE_STATUS;
                    }

                    actualFXS.FXS_Order_Key__c = newFXS.id;
                    actualFXS.FXS_TotalAllocateAmount__c = newFXS.FXS_TotalAllocateAmount__c;
                    actualFXS.OwnerId = UserInfo.getUserId();
                    update actualFXS;

                    Id fxOrderCompleteRecordTypeId = Schema.Sobjecttype.FX_Order__c.getRecordTypeInfosByName().get('FX Order (Completed)').getRecordTypeId();
                    //=============== Update FX Order unser FX Order Summary ==================
                    List<FX_Order__c> fxoList = [SELECT id,FXO_OrderStatus__c,FXO_FXOrderSummary__c,FXO_FillAmount__c,
                                FXO_RequestAmount__c,FXO_Order_Key__c
                                //FXO_Expiration_Date__c,FXO_GTC__c
                                FROM FX_Order__c
                                WHERE FXO_Order_Key__c =: actualFXS.FXS_Order_Key_Before__c
                                AND FXO_OrderStatus__c =: FXOrderTriggerHandler.SUBMIT_STATUS 
                                ];
                    for( FX_Order__c fxo : fxoList )
                    {
                        if( actualFXS.FXS_Status__c == FXOrderSummaryTriggerHandle.FULLY_COMPLETE_STATUS ){
                            fxo.FXO_OrderStatus__c = FXOrderTriggerHandler.DONE_STATUS;
                            fxo.FXO_FillAmount__c = fxo.FXO_RequestAmount__c;
                        } 
                        else if(actualFXS.FXS_Status__c == FXOrderSummaryTriggerHandle.PARTAIL_COMPLETE_STATUS)
                        {
                            fxo.FXO_OrderStatus__c = FXOrderTriggerHandler.INPROGRESS_STATUS;
                        }
                        fxo.RecordTypeId = fxOrderCompleteRecordTypeId;
                        fxo.FXO_FXOrderSummary__c = actualFXS.id;
                        fxo.FXO_FilledTradedBy__c = UserInfo.getName() + ',' +  Datetime.now().format();
                        fxo.FXO_Filled_Trade_Date_Time__c =  Datetime.now();
                    }
                    update fxoList;
                }
                else 
                {
                    errorMessage = Label.FX_Dashboard_Fill_Invalid_Text;
                    //throw new AuraHandledException('Invalid Fill Amount.');
                }
            }
            else 
            {
                errorMessage = Label.FXS_Invalid_Staus_not_New;
                //throw new AuraHandledException('Order Summary Status you fill not in "New".');
            } 

        }
        catch (Exception e)
        {
            throw new AuraHandledException('System Exception: ' + e.getMessage() + '(' + e.getLineNumber() +')' );
        }

        if( errorMessage != '' )
        {
            throw new AuraHandledException(errorMessage);
        }
        else 
        {
            return actualFXS;    
        }
        
    }

    public static void updateToFullyCompleted(FX_Order_Summary__c actualFXS){
        Id fxOrderCompleteRecordTypeId = Schema.Sobjecttype.FX_Order__c.getRecordTypeInfosByName().get('FX Order (Completed)').getRecordTypeId();
        //=============== Update FX Order unser FX Order Summary ==================
        List<FX_Order__c> fxoList = [SELECT id,FXO_OrderStatus__c,FXO_FXOrderSummary__c,FXO_FillAmount__c,
                    FXO_RequestAmount__c,FXO_Order_Key__c
                    //FXO_Expiration_Date__c,FXO_GTC__c
                    FROM FX_Order__c
                    WHERE FXO_Order_Key__c =: actualFXS.FXS_Order_Key_Before__c
                    // SUBMIT_STATUS OR INPROGRESS_STATUS
                    AND (FXO_OrderStatus__c =: FXOrderTriggerHandler.SUBMIT_STATUS OR FXO_OrderStatus__c =: FXOrderTriggerHandler.INPROGRESS_STATUS)
                    ];
        for( FX_Order__c fxo : fxoList )
        {
            fxo.FXO_OrderStatus__c = FXOrderTriggerHandler.DONE_STATUS;
            fxo.FXO_FillAmount__c = fxo.FXO_RequestAmount__c;

            fxo.RecordTypeId = fxOrderCompleteRecordTypeId;
            fxo.FXO_FXOrderSummary__c = actualFXS.id;
            fxo.FXO_FilledTradedBy__c = UserInfo.getName() + ',' +  Datetime.now().format();
            fxo.FXO_Filled_Trade_Date_Time__c =  Datetime.now();
        }
        update fxoList;
    }

    public static void updateToPartiallyCompleted(FX_Order_Summary__c actualFXS){
        Id fxOrderCompleteRecordTypeId = Schema.Sobjecttype.FX_Order__c.getRecordTypeInfosByName().get('FX Order (Completed)').getRecordTypeId();
        //=============== Update FX Order unser FX Order Summary ==================
        List<FX_Order__c> fxoList = [SELECT id,FXO_OrderStatus__c,FXO_FXOrderSummary__c,FXO_FillAmount__c,
                    FXO_RequestAmount__c,FXO_Order_Key__c
                    //FXO_Expiration_Date__c,FXO_GTC__c
                    FROM FX_Order__c
                    WHERE FXO_Order_Key__c =: actualFXS.FXS_Order_Key_Before__c
                    AND (FXO_OrderStatus__c =: FXOrderTriggerHandler.SUBMIT_STATUS OR FXO_OrderStatus__c =: FXOrderTriggerHandler.INPROGRESS_STATUS)
                    ];
                    
        for( FX_Order__c fxo : fxoList )
        {
            fxo.FXO_OrderStatus__c = FXOrderTriggerHandler.INPROGRESS_STATUS;

            fxo.RecordTypeId = fxOrderCompleteRecordTypeId;
            fxo.FXO_FXOrderSummary__c = actualFXS.id;
            fxo.FXO_FilledTradedBy__c = UserInfo.getName() + ', ' +  Datetime.now().format();
            fxo.FXO_Filled_Trade_Date_Time__c =  Datetime.now();
        }
        update fxoList;
    }

    @AuraEnabled
    public static User getUserData(){
        return currentUserInfo;
    }

    public Class OrderWrapper
    {
        @AuraEnabled
        public List<FX_Order__c> orderList {get;set;}
        @AuraEnabled
        public FX_Order_Summary__c fxs {get;set;}
    }

    @AuraEnabled
    public static OrderWrapper spreadOrder( List<FX_Order__c> orderList , FX_Order_Summary__c newfxs )
    {
        String errorMessage = '';
        try
        {
            FX_Order_Summary__c actualFXS = getFXS(newfxs.id);

            if(validateFXS_SpreadOrder(actualFXS, newfxs)){
                // ============ After fill -> update Order summary status to Fully Complete
                actualFXS.FXS_Status__c = FXOrderSummaryTriggerHandle.FULLY_COMPLETE_STATUS;
                update actualFXS;
            
                List<Id> fxOrderIdList = new List<Id>();
                // ============ After fill -> update each order to done and stamp filled by trader
                for(FX_Order__c fxo : orderList )
                {
                    fxo.FXO_PartiallyAllocatedby__c = UserInfo.getName() + ',' +  Datetime.now().format();
                    fxo.FXO_Partially_Allocated_Date_Time__c = Datetime.now();

                    if( fxo.FXO_FillAmount__c > 0 )
                    {
                        fxo.FXO_OrderStatus__c = FXOrderTriggerHandler.DONE_STATUS;
                    }
                    else 
                    {
                        fxo.FXO_OrderStatus__c = FXOrderTriggerHandler.NOT_ALLOCATED_STATUS;   
                    }

                    fxOrderIdList.add(fxo.id);
                }

                update orderList;
                
                // requery orderList to update Formulafield
                orderList = [SELECT id,Name,FXO_Customer__c,FXO_Customer__r.name,FXO_BuySell__c,FXO_OrderStatus__c,
                                    OwnerId,Owner.Name,FXO_GTC__c,FXO_Expiration_Date__c,
                                    FXO_RequestAmount__c,FXO_FillAmount__c,FXO_RemainingAmount__c,
                                    FXO_Currency__c,FXO_CurrencyPair__c,FXO_CustomerRate__c,FXO_InterbankRate__c,
                                    Owner_s_Segment__c, Owner_s_Segment_stamp__c 
                                    FROM FX_Order__c
                                    WHERE id in :fxOrderIdList
                                ];

                OrderWrapper ow = new OrderWrapper();
                ow.orderList = orderList;
                ow.fxs = actualFXS;

                return ow;
            }
            else 
            {
                errorMessage = Label.FXS_TotalAllocateAmount_has_been_updated ;
            }
        }
        catch (Exception e)
        {
            throw new AuraHandledException('System Exception: ' + e.getMessage() + '(' + e.getLineNumber() +')' );
        }
        
        if( errorMessage != '' )
        {
            throw new AuraHandledException( errorMessage );
        }

        return null;    

    }
    
    @AuraEnabled
    public static FX_Blotter_Profile_Manager__mdt getBlotterProfile(){
        return fxBlotterProfile;
    }

    @AuraEnabled
    public static String getSessionId()
    {
        return UserInfo.getSessionId();
    }

    @AuraEnabled
    public static FX_Order__c stampCancelRemain( FX_Order__c FXOrderItem ){

        FXOrderItem.FXO_Cancelled_Remaining_Amount_By_Stamp__c = UserInfo.getName() + ',' +  Datetime.now().format();
        FXOrderItem.FXO_Cancelled_Remaining_Amount_Date_Time__c = Datetime.now();
        update FXOrderItem;

        return FXOrderItem;
    }

    @AuraEnabled
    public static String cancelOrderSummaryFromPartialAndFull(FX_Order_Summary__c newFXS){
        String errorMessage = '';
        try
        {
            FX_Order_Summary__c actualFXS = getFXS(newFXS.id);
            //System.debug('actualFXS ' + actualFXS);
            if( actualFXS.FXS_Status__c == FXOrderSummaryTriggerHandle.FULLY_COMPLETE_STATUS ||
             actualFXS.FXS_Status__c == FXOrderSummaryTriggerHandle.PARTAIL_COMPLETE_STATUS )
            {
                actualFXS.FXS_Status__c = FXOrderSummaryTriggerHandle.CANCEL_STATUS;
                actualFXS.FXS_Order_Key__c = newFXS.id;
                
                 update actualFXS;

                //=============== Update FX Order unser FX Order Summary ==================
                List<FX_Order__c> fxoList = [SELECT id, FXO_OrderStatus__c, FXO_FXOrderSummary__c,
                            FXO_FillAmount__c, FXO_RequestAmount__c,
                            FXO_Order_Key__c, FXO_Cancelled_Order_By_Stamp__c
                            FROM FX_Order__c
                            //WHERE FXO_Order_Key__c =: actualFXS.FXS_Order_Key_Before__c
                            WHERE FXO_FXOrderSummary__c =: actualFXS.id
                            AND (FXO_OrderStatus__c =: FXOrderTriggerHandler.DONE_STATUS OR FXO_OrderStatus__c =: FXOrderTriggerHandler.INPROGRESS_STATUS)
                            ];
                for( FX_Order__c fxo : fxoList )
                {
                    fxo.FXO_OrderStatus__c = FXOrderTriggerHandler.CANCEL_STATUS;
                    fxo.FXO_FillAmount__c = 0;
                    fxo.FXO_Cancelled_Order_By_Stamp__c = UserInfo.getName() + ',' +  Datetime.now().format();
                }
                 update fxoList;
            }
            else 
            {
                errorMessage = Label.FXS_Cancel_Summary_error_text;
                //throw new AuraHandledException('Order Summary Status you fill not in "New".');
            } 

            if( errorMessage != '' )
            {
                throw new AuraHandledException(errorMessage);
            }

            return 'SUCCESS';
        }
        catch (Exception e)
        {
            throw new AuraHandledException('System Exception: ' + e.getMessage() + '(' + e.getLineNumber() +')' );
        }
    }

    @AuraEnabled
    public static Boolean validateAndUpdateFXS(FX_Order_Summary__c newFXS)
    {
        String errorMessage = '';
        FX_Order_Summary__c actualFXS = getFXS(newFXS.id);
        //system.debug(actualFXS);

        Boolean isValidFXS = true;

        
        List<FX_Order__c> fxoList = [SELECT id,FXO_OrderStatus__c,FXO_FXOrderSummary__c,FXO_FillAmount__c,
            FXO_RequestAmount__c,FXO_Order_Key__c,
            FXO_Expiration_Date__c,FXO_GTC__c
            FROM FX_Order__c
            WHERE (FXO_Order_Key__c =: actualFXS.FXS_Order_Key__c
                AND FXO_OrderStatus__c =: FXOrderTriggerHandler.SUBMIT_STATUS )
            OR (FXO_FXOrderSummary__c =: actualFXS.Id
                AND FXO_OrderStatus__c =: FXOrderTriggerHandler.INPROGRESS_STATUS )
        ];

        if(actualFXS.FXS_TotalRequestAmount__c == newFXS.FXS_TotalRequestAmount__c){
            for( FX_Order__c o : fxoList )
            {
                if( o.FXO_Expiration_Date__c < System.Now() )
                {
                    isValidFXS = false;
                    o.FXO_OrderStatus__c = FXOrderTriggerHandler.EXPIRED_STATUS;

                    // errorMessage = Label.FX_Order_Summary_Invalid_Order;
                    //break;
                }
            }

            update fxoList;
        }
        else
        {
            //Case FXS was updated total request amount
            errorMessage = Label.FXS_TotaRequestAmount_has_been_updated;
        }
        
        if( errorMessage != ''){
            throw new AuraHandledException(errorMessage);
        }

        return isValidFXS;
    }

    public static Set<String> getAllField(String objectName)
    {
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Map<String, Schema.SObjectField> fieldMap = schemaMap.get(objectName).getDescribe().fields.getMap();

        return fieldMap.keySet();
    }

    @AuraEnabled
    public static String createFXOrder( FX_Order__c FXOrderItem )
    {
        
        try{
            insert FXOrderItem;
            
            if (FXOrderItem != null)
            {
                return FXOrderItem.id;
            } else {
                throw new AuraHandledException('FX Order cannot create record.');
            }
        }
        catch (Exception e)
        {
            throw new AuraHandledException('System Exception: ' + e.getMessage() + '(' + e.getLineNumber() +')' );
        }

    }

    public static boolean isOwnerOrSegment(FX_Order__c fxo)
    {
        // If user is Owner, allow to do Something
        if( currentUserInfo.Id == fxo.OwnerId )
        {
            return true;
        }
        // If User is same segment , allow to do Something
        if( currentUserInfo.Reporting_Segment__c == fxo.Owner_s_Segment__c )
        {
            return true;
        }

        return false;
    }


    @AuraEnabled
    public static Boolean validateFXSTotalRequestAmount(FX_Order_Summary__c newFXS)
    {
        FX_Order_Summary__c actualFXS = getFXS(newFXS.id);

        if(actualFXS.FXS_TotalRequestAmount__c == newFXS.FXS_TotalRequestAmount__c){
            return true;
        } else {
            return false;
        }
    }

    public static Boolean validateFXS_SpreadOrder(FX_Order_Summary__c actualFXS, FX_Order_Summary__c newFXS)
    {
        if(actualFXS.FXS_Status__c == FXOrderSummaryTriggerHandle.PARTAIL_COMPLETE_STATUS && 
            actualFXS.FXS_TotalAllocateAmount__c == newfxs.FXS_TotalAllocateAmount__c)
        {
            return true;
        } 
        else 
        {
            return false;
        }
    }
}
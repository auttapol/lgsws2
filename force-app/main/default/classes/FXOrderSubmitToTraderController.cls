public with sharing class FXOrderSubmitToTraderController {
	private ApexPages.StandardSetController standardController;
	public List<FX_Order__c> FXOrderSelected {get;set;}

	public FXOrderSubmitToTraderController(ApexPages.StandardSetController standardController)
    {
        this.standardController = standardController;

        string orderId = apexpages.currentpage().getparameters().get('Id');

        if( orderId != null && orderId != '' )
        {
            FXOrderSelected = [ 
                SELECT  id,Name,FXO_Submitted_Date_Time__c,FXO_Customer__c, OwnerId, Owner_s_Segment__c, 
                        FXO_BuySell__c,FXO_CurrencyPair__c,FXO_CustomerRate__c,FXO_RequestAmount__c,
                        FXO_OrderStatus__c,FXO_Expiration_Date__c,FXO_GTC__c,FXO_Submitted_By__c,
                        FXO_InterbankRate__c,FXO_FillAmount__c 
                FROM FX_Order__c 
                WHERE id=:orderId 
            ];

            this.standardController = new ApexPages.StandardSetController(FXOrderSelected);
        }
        else 
        {
            FXOrderSelected = (List<FX_Order__c>) standardController.getSelected();    
        }
       

        List<FX_Order__c> fxorderValid = new List<FX_Order__c>();
        List<String> invalidOrderName = new List<String>();


        for( FX_Order__c o : FXOrderSelected )
        {

            if( isOrderAvailabeltoSubmit(o) )
            {
                fxorderValid.add(o);
            }
            else 
            {
                //fxorderInvalid.add(o);   
                invalidOrderName.add(o.name);
            }

        }

        FXOrderSelected = fxorderValid;

        if( invalidOrderName.size() > 0 )
        {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,
                Label.FXO_Invalid_order_Submit + String.join(invalidOrderName, ', ') ));
        }

    }

    public PageReference submitToTrader()
    {       
        boolean isAllOrderValid = true;
        List<String> invalidOrderName = new List<String>();
        List<Id> validOrderId = new List<Id>();

        Set<Id> FXOIdSet = new Set<Id>();
        for( FX_Order__c o : FXOrderSelected )
        {
            FXOIdSet.add(o.id);
        }

        List<FX_Order__c> FXOrderRecent = [ 
            SELECT  id,Name,FXO_Submitted_Date_Time__c,FXO_Customer__c, OwnerId, Owner_s_Segment__c, 
                    FXO_BuySell__c,FXO_CurrencyPair__c,FXO_CustomerRate__c,FXO_RequestAmount__c,
                    FXO_OrderStatus__c,FXO_Expiration_Date__c,FXO_GTC__c,FXO_Submitted_By__c,
                    FXO_InterbankRate__c,FXO_FillAmount__c 
            FROM FX_Order__c 
            WHERE id in :FXOIdSet 
        ];

        // Update recently FXO data before verify
        // update here cause redirect problem
        //this.standardController = new ApexPages.StandardSetController(FXOrderRecent);


        for( FX_Order__c o : FXOrderRecent )
        {
            
            if( isOrderAvailabeltoSubmit(o) )
            {
                //o = setSubmitToTrader(o);
                validOrderId.add(o.id);
            }
            else 
            {
                isAllOrderValid= false;
                invalidOrderName.add( o.name );
            }
            
        }

        if( isAllOrderValid == true )
        {
            // Update status for standard set controller items
            for( FX_Order__c o : FXOrderSelected )
            {
                o = setSubmitToTrader(o);
            }

    	    return this.standardController.save();     
        }
        else 
        {
            FXOrderSelected = [ 
                SELECT  id,Name,FXO_Submitted_Date_Time__c,FXO_Customer__c, OwnerId, Owner_s_Segment__c, 
                        FXO_BuySell__c,FXO_CurrencyPair__c,FXO_CustomerRate__c,FXO_RequestAmount__c,
                        FXO_OrderStatus__c,FXO_Expiration_Date__c,FXO_GTC__c,FXO_Submitted_By__c,
                        FXO_InterbankRate__c,FXO_FillAmount__c 
                FROM FX_Order__c 
                WHERE id in :validOrderId 
            ];


            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,
                Label.FXO_Invalid_order_Submit + String.join(invalidOrderName, ', ') ));

            this.standardController.setSelected(FXOrderSelected);

            PageReference submitToTraderPage = ApexPages.currentPage();     
            return submitToTraderPage;
        }
    }

    public static boolean isOrderAvailabeltoSubmit(FX_Order__c o)
    {
        //if( o.FXO_OrderStatus__c == FXOrderTriggerHandler.NEW_STATUS 
        //&& !isOrderExpired(o) && FX_Order_Summary_Controller.isOwnerOrSegment(o) )
        //fix support BAU#8218(INC0076529)
        if( o.FXO_OrderStatus__c == FXOrderTriggerHandler.NEW_STATUS && !isOrderExpired(o) )
        {
            return true;
        }
        else 
        {
            return false;    
        }
    }

    public static Boolean isOrderExpired(FX_Order__c o)
    {
        Boolean isExpired = false;
        if( o.FXO_Expiration_Date__c != null )
        {
            if( o.FXO_Expiration_Date__c < System.now() )
            {
                isExpired = true;
            }
        }

        return isExpired;
    }

    public static FX_Order__c setSubmitToTrader(FX_Order__c fxo)
    {
        fxo.FXO_OrderStatus__c = FXOrderTriggerHandler.SUBMIT_STATUS;
        fxo.FXO_Submitted_By__c =  UserInfo.getName() + ', ' +  Datetime.now().format();
        fxo.FXO_Submitted_Date_Time__c = System.Now();
        return fxo;
    }

    public PageReference cancel()
    {       
    	return standardController.cancel();    
    }


    @AuraEnabled
    public static void submitFromQuickAction(FX_Order__c fxo)
    {   
        String errorMessage = '';
        try 
        {            
            FX_Order__c o = [ SELECT id,Name,FXO_Submitted_Date_Time__c,FXO_Customer__c, OwnerId, Owner_s_Segment__c, 
                        FXO_BuySell__c,FXO_CurrencyPair__c,FXO_CustomerRate__c,FXO_RequestAmount__c,
                        FXO_OrderStatus__c,FXO_Expiration_Date__c,FXO_GTC__c
                        FROM FX_Order__c WHERE id=:fxo.Id ];

            if( isOrderAvailabeltoSubmit(o) )
            {
                o = setSubmitToTrader(o);
                update o;
            }
            else 
            {
                errorMessage = Label.FX_Order_Submit_To_Trader_Message_Validate;
            }
            
        } 
        catch(Exception e) 
        {
            // System.debug(e.getMessage());
            throw new AuraHandledException('System Exception: ' + e.getMessage() + '(' + e.getLineNumber() +')' );
        }

        if( errorMessage != '' )
        {
            throw new AuraHandledException( errorMessage );
        }
    }

    @AuraEnabled
    public static FX_Order__c getFXO(Id fxoId)
    {
        FX_Order__c fxo = [ SELECT id,Name,FXO_Submitted_Date_Time__c,FXO_Customer__c, OwnerId, Owner_s_Segment__c, 
                                FXO_BuySell__c,FXO_CurrencyPair__c,FXO_CustomerRate__c,FXO_RequestAmount__c,
                                FXO_OrderStatus__c,FXO_Expiration_Date__c,FXO_GTC__c,FXO_Submitted_By__c,
                                FXO_InterbankRate__c
                FROM FX_Order__c WHERE id=:fxoId ];

        if(isOrderAvailabeltoSubmit(fxo)){
            return fxo;    
        }
        
        return null;
    }


}
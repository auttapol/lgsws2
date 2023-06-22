public with sharing class FXOrderCancelController {
	private ApexPages.StandardSetController standardController;

    private static User currentUserInfo{
        get{
            if( currentUserInfo == null )
            {
                currentUserInfo = [SELECT Id, Username, Segment__c, Reporting_Segment__c, Profile.name
                    FROM User 
                    WHERE Id =: UserInfo.getUserId()
                    LIMIT 1];
            }

            return currentUserInfo;
        }
        set;
    }

    public List<FX_Order__c> FXOrderSelected {get;set;}

	public FXOrderCancelController(ApexPages.StandardSetController standardController)
    {
        this.standardController = standardController;

        FXOrderSelected = (List<FX_Order__c>) standardController.getSelected();

        List<FX_Order__c> fxorderValid = new List<FX_Order__c>();

        List<String> invalidOrderName = new List<String>();

        // User currentuser = [Select Id, Segment__c,Reporting_Segment__c from User where Id =: userinfo.getuserId()];

        for( FX_Order__c o : FXOrderSelected )
        {

            //** BAU 00007686 - Cannot cancel order event in the same segment **//
            // (Delete Old segment varify code)
            // By Teerasarn Panapattanakun 
            // I&I Consultant
            
            // If FX Order is "New" or "Submitted" Status, And Same team or Owner Alllow to Cancel
            if( isOrderAvailabeltoCancel(o))
            {
                fxorderValid.add(o);
            }
            else 
            {
                invalidOrderName.add(o.name);
            }
        }

        FXOrderSelected = fxorderValid;

        if( invalidOrderName.size() > 0 )
        {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,
                Label.FXO_Invalid_order_Cancel + String.join(invalidOrderName, ', ') ));
        }
        
    }


    public PageReference cancelOrderConfirm()
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
            SELECT id, Name, FXO_Customer__c, OwnerId, Owner_s_Segment__c, FXO_InterbankRate__c, FXO_FillAmount__c, 
                    FXO_BuySell__c, FXO_CurrencyPair__c, FXO_CustomerRate__c, FXO_RequestAmount__c,
                    FXO_OrderStatus__c, FXO_Expiration_Date__c, FXO_GTC__c,
                    FXO_Cancelled_Order_By_Stamp__c,FXO_Cancelled_Order_Date_Time__c
            FROM FX_Order__c 
            WHERE id in :FXOIdSet 
        ];
        
        // Update recently FXO data before verify
        // this.standardController = new ApexPages.StandardSetController(FXOrderRecent);

    	for( FX_Order__c o : FXOrderRecent )
    	{
    		// o.FXO_OrderStatus__c = FXOrderTriggerHandler.CANCEL_STATUS;
            // o.FXO_Cancelled_Order_By_Stamp__c =  UserInfo.getName() + ', ' +  Datetime.now().format();
            // o.FXO_Cancelled_Order_Date_Time__c = Datetime.now();
            if(isOrderAvailabeltoCancel(o))
            {
                // o = setCancelFXOrder(o);
                validOrderId.add(o.id);
            }
            else
            {
                isAllOrderValid = false;
                invalidOrderName.add( o.name );
            }
            
    	}

        if( isAllOrderValid == true )
        {
            // Update status for standard set controller items
            for( FX_Order__c o : FXOrderSelected )
            {
                o = setCancelFXOrder(o);
            }
    	    return standardController.save();     
        }
        else
        {
            FXOrderSelected = [
                SELECT id, Name, FXO_Customer__c, OwnerId, Owner_s_Segment__c, FXO_InterbankRate__c, FXO_FillAmount__c, 
                        FXO_BuySell__c, FXO_CurrencyPair__c, FXO_CustomerRate__c, FXO_RequestAmount__c,
                        FXO_OrderStatus__c, FXO_Expiration_Date__c, FXO_GTC__c, 
                        FXO_Cancelled_Order_By_Stamp__c,FXO_Cancelled_Order_Date_Time__c
                FROM FX_Order__c 
                WHERE id in :validOrderId 
            ];
            
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,
                Label.FXO_Invalid_order_Cancel + String.join(invalidOrderName, ', ') ));

            this.standardController.setSelected(FXOrderSelected);

            PageReference FXOrdercCancelPage = ApexPages.currentPage();
            // PageReference FXOrdercCancelPage = Page.FXOrderCancel;
            return FXOrdercCancelPage;
        }
    }

    public PageReference cancel()
    {       
    	return standardController.cancel();    
    }

    @AuraEnabled
    public static User getUserData()
    {
        return currentUserInfo;
    }

    public static boolean isOrderAvailabeltoCancel(FX_Order__c o)
    {
        //if( (o.FXO_OrderStatus__c == FXOrderTriggerHandler.NEW_STATUS || o.FXO_OrderStatus__c == FXOrderTriggerHandler.SUBMIT_STATUS) 
        //    && FX_Order_Summary_Controller.isOwnerOrSegment(o) )
        //fix support BAU#8218(INC0076529)
        if( (o.FXO_OrderStatus__c == FXOrderTriggerHandler.NEW_STATUS || o.FXO_OrderStatus__c == FXOrderTriggerHandler.SUBMIT_STATUS) )
        {
            return true;
        }
        else 
        {
            return false;    
        }
    }

    public static FX_Order__c setCancelFXOrder(FX_Order__c fxo)
    {
        // if( fxo.FXO_OrderStatus__c == FXOrderTriggerHandler.NEW_STATUS || fxo.FXO_OrderStatus__c == FXOrderTriggerHandler.SUBMIT_STATUS )
        // {
            
        // }  
        fxo.FXO_OrderStatus__c = FXOrderTriggerHandler.CANCEL_STATUS;
        fxo.FXO_Cancelled_Order_By_Stamp__c =  UserInfo.getName() + ', ' +  Datetime.now().format();
        fxo.FXO_Cancelled_Order_Date_Time__c = System.Now();
        return fxo;
    }


    @AuraEnabled
    public static void cancelFromQuickAction(FX_Order__c fxo)
    {   
        String errorMessage = '';
        try 
        {
            FX_Order__c o = [ SELECT id, Name, FXO_Customer__c, OwnerId, Owner_s_Segment__c,
                                FXO_BuySell__c, FXO_CurrencyPair__c, FXO_CustomerRate__c, FXO_RequestAmount__c,
                                FXO_OrderStatus__c, FXO_Expiration_Date__c, FXO_GTC__c, 
                                FXO_Cancelled_Order_By_Stamp__c,FXO_Cancelled_Order_Date_Time__c
                        FROM FX_Order__c WHERE id=:fxo.Id ];

            if(isOrderAvailabeltoCancel(o))
            {
                o = setCancelFXOrder(o);
                update o; 
            }
            else
            {
                errorMessage = Label.FX_Order_Cancel_Validate_Message;
            }
            
        } 
        catch(Exception e) 
        {
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
        
        FX_Order__c fxo = [ SELECT id, Name, FXO_Customer__c, OwnerId, Owner_s_Segment__c,
                                FXO_BuySell__c, FXO_CurrencyPair__c, FXO_CustomerRate__c, FXO_RequestAmount__c,
                                FXO_OrderStatus__c, FXO_Expiration_Date__c, FXO_GTC__c, 
                                FXO_Cancelled_Order_By_Stamp__c,FXO_Cancelled_Order_Date_Time__c
                FROM FX_Order__c WHERE id=:fxoId ];
        
        // If FX Order belong owner or segment
        //if(FX_Order_Summary_Controller.isOwnerOrSegment(fxo))
        //{
        //    return fxo;
        //}
        //return null;
        
        //fix support BAU#8218(INC0076529)
        return fxo;
    }
}
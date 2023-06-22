public with sharing class FXOrderAcknowledgeController {

	private ApexPages.StandardSetController standardController;
    
    public List<FX_Order__c> FXOrderSelected {get;set;}

	public FXOrderAcknowledgeController(ApexPages.StandardSetController standardController)
    {
        this.standardController = standardController;

        FXOrderSelected = (List<FX_Order__c>) standardController.getSelected();

        List<FX_Order__c> fxorderValid = new List<FX_Order__c>();
        //List<FX_Order__c> fxorderInvalid = List<FX_Order__c>();

        List<String> invalidOrderName = new List<String>();


        for( FX_Order__c o : FXOrderSelected )
        {
            if(isOrderAvailabeltoAcknowledge(o))
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
                Label.FXO_Invalid_order_Acknowledge + String.join(invalidOrderName, ', ') ));
        }
    }

    public PageReference AcknowledgeFXOrder()
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
            SELECT  id, Name, FXO_Customer__c, FXO_InterbankRate__c, FXO_FillAmount__c, OwnerId, Owner_s_Segment__c,
                    FXO_BuySell__c, FXO_CurrencyPair__c, FXO_CustomerRate__c, FXO_RequestAmount__c,
                    FXO_OrderStatus__c, FXO_Expiration_Date__c, FXO_GTC__c, 
                    FXO_AcknowledgedDealby__c,FXO_Acknowledged_Date_Time__c
            FROM FX_Order__c 
            WHERE id in :FXOIdSet 
        ];
        
        // Update recently FXO data before verify
        // this.standardController = new ApexPages.StandardSetController(FXOrderRecent);

    	for( FX_Order__c o : FXOrderRecent )
    	{
            // o.FXO_OrderStatus__c = FXOrderTriggerHandler.ACKNOWLEDGE_STATUS;
            // o.FXO_AcknowledgedDealby__c = UserInfo.getName() + ',' +  Datetime.now().format();
            // o.FXO_Acknowledged_Date_Time__c = Datetime.now();
            
            if(isOrderAvailabeltoAcknowledge(o))
            {
                // o = setAcknowledgeFXOrder(o);
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
            for( FX_Order__c o : FXOrderSelected )
            {
                o = setAcknowledgeFXOrder(o);
            }
    	    return standardController.save();     
        }
        else
        {
            FXOrderSelected = [
                SELECT  id, Name, FXO_Customer__c, FXO_InterbankRate__c, FXO_FillAmount__c, OwnerId, Owner_s_Segment__c,
                        FXO_BuySell__c, FXO_CurrencyPair__c, FXO_CustomerRate__c, FXO_RequestAmount__c,
                        FXO_OrderStatus__c, FXO_Expiration_Date__c, FXO_GTC__c, 
                        FXO_AcknowledgedDealby__c,FXO_Acknowledged_Date_Time__c
                FROM FX_Order__c 
                WHERE id in :validOrderId 
            ];
            
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,
                Label.FXO_Invalid_order_Acknowledge + String.join(invalidOrderName, ', ') ));

            this.standardController.setSelected(FXOrderSelected);

            PageReference FXOrdercAcknowledgePage = ApexPages.currentPage();
            return FXOrdercAcknowledgePage;
        }         
    }

    public PageReference cancel()
    {       
        return standardController.cancel();    
    }

    public static boolean isOrderAvailabeltoAcknowledge(FX_Order__c o)
    {
        //if( o.FXO_OrderStatus__c == FXOrderTriggerHandler.DONE_STATUS && FX_Order_Summary_Controller.isOwnerOrSegment(o))
        //fix support BAU#8218(INC0076529)
        if( o.FXO_OrderStatus__c == FXOrderTriggerHandler.DONE_STATUS )
        {
            return true;    
        }
        else
        {
            return false;
        }
    }
    
    public static FX_Order__c setAcknowledgeFXOrder(FX_Order__c fxo)
    {
        fxo.FXO_OrderStatus__c = FXOrderTriggerHandler.ACKNOWLEDGE_STATUS;
        fxo.FXO_AcknowledgedDealby__c =  UserInfo.getName() + ', ' +  Datetime.now().format();
        fxo.FXO_Acknowledged_Date_Time__c = System.Now();
        return fxo;
    }

    @AuraEnabled
    public static void acknowledgeFromQuickAction(FX_Order__c fxo)
    {   
        String errorMessage = '';
        try 
        {
            FX_Order__c o = [ SELECT id, Name, FXO_Customer__c, OwnerId, Owner_s_Segment__c,
                                FXO_BuySell__c, FXO_CurrencyPair__c, FXO_CustomerRate__c, FXO_RequestAmount__c,
                                FXO_OrderStatus__c, FXO_Expiration_Date__c, FXO_GTC__c, 
                                FXO_AcknowledgedDealby__c,FXO_Acknowledged_Date_Time__c
                        FROM FX_Order__c WHERE id=:fxo.Id ];

            if( isOrderAvailabeltoAcknowledge(o) ){
                o = setAcknowledgeFXOrder(o);
                update o;
            }
            else
            {
                errorMessage = Label.FX_Order_Acknowledge_Validate_Message;
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
                                FXO_AcknowledgedDealby__c,FXO_Acknowledged_Date_Time__c
                FROM FX_Order__c WHERE id=:fxoId ];
                
        if( isOrderAvailabeltoAcknowledge(fxo) ){
            return fxo;
        }
        return null;
    }
}
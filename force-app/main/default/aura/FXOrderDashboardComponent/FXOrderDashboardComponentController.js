({
	onCometdLoaded : function(component, event, helper) {

		var cometd = new org.cometd.CometD();
		component.set('v.cometd', cometd);
		if (component.get('v.sessionId') != null)
		{
		    helper.connectCometd(component);
		}

	},

	onInit : function(component, event, helper) {

		component.set('v.cometdSubscriptions', []);
		component.set('v.notifications', []);
		// Disconnect CometD when leaving page
		window.addEventListener('unload', function(event) {
			helper.disconnectCometd(component);
		});
		// Retrieve session id
		var action = component.get('c.getSessionId');
		action.setCallback(this, function(response) {
			if (component.isValid() && response.getState() === 'SUCCESS') {

			component.set('v.sessionId', response.getReturnValue());
			if (component.get('v.cometd') != null)
				helper.connectCometd(component);
				helper.setSelectorOption(component, '', '1', '1');
			}
			else
			{
				console.error(response);
			}
		});
		$A.enqueueAction(action);

		helper.displayToast(component, 'success',  $A.get("$Label.c.FX_Dashboard_Init_Text") );

		helper.generateFXS(component ,helper, '' , 1 , 1);
		
		action = component.get('c.getBlotterProfile');
		action.setCallback(this, function(response) {
			if(component.isValid() && response.getState() === 'SUCCESS'){
				component.set('v.blotterProfile', response.getReturnValue());
				// console.log('blotter profile ' + response.getReturnValue());
			}else{
				console.error(response);
			}
		});
		$A.enqueueAction(action);


		// var action1 = component.get("c.getBlotterProfile");
		// action1.setCallback(this, function (response) {
		// 	var state = response.getState();
		// 	if (component.isValid() && state === "SUCCESS") {
		// 		getBlotterProfile = response.getReturnValue();
		// 		component.set('v.blotterProfile', getBlotterProfile);
		// 		// show users allow can update fill amount
		// 		var isFillUpdate = getBlotterProfile.FX_Dashboard_Allow_Edit__c;
		// 		component.set("v.userAdjustFillAmount", isFillUpdate);
		// 		console.log('oops '+isFillUpdate);
		// 	} else {
		// 		console.error(response);
		// 	}
		// });

		// $A.enqueueAction(action1);



		// Use to test disconnected
		//  console.log('disconnect start');
		// setTimeout(function () {
	//    	console.log('disconnected');
	//    	helper.disconnectCometd(component);
	//   }, 5000);

	},

	handleKeyUpSearch: function (component, event , helper) {

		var queryTerm = component.find('searchCurrencyCurrent').get('v.value');
		var searchCurrencyChk = component.get('v.searchCurrency');

		var Buypage = component.find('BuypageSelector').get('v.value');
		var Sellpage = component.find('SellpageSelector').get('v.value');
        var searchKey = "";
		
		
		if(queryTerm != searchCurrencyChk){
			// console.log('Key Change', queryTerm, '\n', searchCurrencyChk);
			component.set("v.searchCurrency", queryTerm);
			Buypage = 1;
			Selection = 1;
		}

		if(queryTerm != undefined){
			if ( queryTerm.length > 2) 
			{
				searchKey = queryTerm;
			}
			else
			{
				searchKey = "";
			}
		}

		helper.generateFXS(component , helper, searchKey , Buypage, Sellpage);
		helper.setSelectorOption(component, searchKey, Buypage, Sellpage);
		
	},

	ClearNoti: function(component, event){

		var id = event.currentTarget.id;
		var updatedComponent = component.get("v.updatedComponent");
		var updatedComponentFag = component.get("v.updatedComponentFag");
		
		if(updatedComponent.includes(id))
		{
			// console.log("Clear " + id + updatedComponentFag[id]);
			var subComponents = component.getElement().querySelectorAll("#" + id );
			var targetComponant;

			if( subComponents.length > 0 )
			{
				targetComponant = subComponents[0];

				$A.util.removeClass(targetComponant, 'blink-plus');
				$A.util.removeClass(targetComponant, 'blink-subb');
				var index = updatedComponent.indexOf(id);
				if(index != -1) 
				{
					updatedComponent.splice(index, 1);
				}
				delete updatedComponentFag[id];

			}

			// if(updatedComponentFag[id] == "PLUS")
			// 	{ 
			// 		$A.util.removeClass(targetComponant, 'blink-plus');
			// 	}
			// }
			// else
			// { 
			// 	$A.util.removeClass(targetComponant, 'blink-subb')
			// }
			
			// var index = updatedComponent.indexOf(id);
			// if(index != -1) 
			// {
			// 	updatedComponent.splice(index, 1);
			// }


		}else{
			// console.log("Not in UpdatedList");
		}

	},

	navToRecDetail : function(component, event){
		// console.log(event.currentTarget);
		var id =  event.currentTarget.id;

		var navEvt = $A.get("e.force:navigateToSObject");

        navEvt.setParams({
            "recordId": id
        });
        navEvt.fire();

	},

	fillOrder: function(component, event , helper){

		var ctarget = event.currentTarget;
    	var idx = ctarget.dataset.value;
    	var type = ctarget.dataset.type;

    	var attributeOrderName = '';
    	if( type == 'buy' )
    	{
    		attributeOrderName = 'v.oscBuyList';
    	}
    	else
    	{
    		attributeOrderName = 'v.oscSellList';
    	}

		var fxsitem = component.get(attributeOrderName)[idx];
		
		//Multiply 1 M to request amount
	    if( fxsitem.FXS_TotalAllocateAmount__c == '' || fxsitem.FXS_TotalAllocateAmount__c == null )
	    {
			fxsitem.FXS_TotalAllocateAmount__c = 0;
	    }
		
		var fillNumber = 0;
	    if(typeof fxsitem.FXS_TotalAllocateAmount__c != 'number')
	    {
			var TotalAllocate = Number(fxsitem.FXS_TotalAllocateAmount__c.replace(/[^0-9\.]+/g,""));
			TotalAllocate = Math.floor((TotalAllocate * 100).toFixed(2)) / 100 * Math.pow(10, 6);
			
			if(fxsitem.FXS_TotalRequestAmount__c < TotalAllocate){
				TotalAllocate = fxsitem.FXS_TotalRequestAmount__c;
			}
			
			fillNumber = TotalAllocate;
	    }
	    else
	    {
			fillNumber = fxsitem.FXS_TotalAllocateAmount__c;
	    }
		
		if(fillNumber == fxsitem.FXS_TotalRequestAmount__c && fxsitem.FXS_TotalAllocateAmount__c != null){
			fillNumber = fxsitem.FXS_TotalRequestAmount__c;
			fxsitem.FXS_TotalAllocateAmount__c = fxsitem.FXS_TotalRequestAmount__c;
		} 
		else 
		{
			fxsitem.FXS_TotalAllocateAmount__c = fillNumber;
		}
		
		component.set("v.confirmFXSItem", fxsitem);
		

		if( fillNumber <= fxsitem.FXS_TotalRequestAmount__c &&  fxsitem.FXS_TotalAllocateAmount__c != 0 )
    	{
    	   if( fillNumber == fxsitem.FXS_TotalRequestAmount__c )
	       {
	       		component.set("v.confirmDialogText", $A.get("$Label.c.FX_Dashboard_Full_Fill_Confirm_Text") );
	       }
	       else
	       {
	       		component.set("v.confirmDialogText", $A.get("$Label.c.FX_Dashboard_Partial_Fill_Confirm_Text") );
	       }
	    //    component.set("v.confirmDialogShow", true);
    	}
    	else
    	{
    		helper.displayToast(component,"Warning", $A.get("$Label.c.FX_Dashboard_Fill_Invalid_Text") );
    	}

	},

	confirmFill : function(component, event , helper){
		var configrmFXSItem = component.get("v.confirmFXSItem");

		var action = component.get('c.validateFXSTotalRequestAmount');
		action.setParams({
			"newFXS": configrmFXSItem
		});

		action.setCallback(this, function(response) {
			if (component.isValid() && response.getState() === 'SUCCESS') {
				if(response.getReturnValue() == true) {
					
					helper.fillOrderAction(component, event , helper);

				} else {
					// reset total allocate amount
					configrmFXSItem.FXS_TotalAllocateAmount__c = "";
					component.set("v.confirmFXSItem", configrmFXSItem);
					
					// Close and reset modal
					component.set("v.confirmDialogShow", false);
					component.set("v.fillamountDialogShow", false);

					helper.displayToast(component, "Error", $A.get("$Label.c.FXS_TotaRequestAmount_has_been_updated") );
				}
			}
			else
			{
				console.error(response);
			}
		});
		$A.enqueueAction(action);



	},

	

	changeFillAmount : function(component, event, helper) {

		var target = event.getSource(); 	
		var M = 1000000;
		var floatDigit = 2 ;
    	var idx =  event.currentTarget.parentNode.dataset.idx;
    	var type =  event.currentTarget.parentNode.dataset.type;
    	var fxsOrderKey = event.currentTarget.parentNode.dataset.key;

    	var orderItem;
    	// if( type == "buy" )
    	// {
    	// 	orderItem = component.get('v.oscBuyList')[idx];
    	// }
    	// else
    	// {
    	// 	orderItem = component.get('v.oscSellList')[idx];
		// }    	 
		
		// orderitem will already set when open modal
		orderItem = component.get('v.confirmFXSItem');

		var requestAmount = orderItem.FXS_TotalRequestAmount__c; 
    	var fillAmountText = target.get("v.value");
		
    	if( fillAmountText == '')
    	{
    		fillAmountText = 0;
		}
		
		var fillAmount = Number(fillAmountText);
		// Fix Bug IE if fillAmount type is Number but output is "NaN"
		if(isNaN(fillAmount)){
			fillAmount = 0;
			fillAmountText = 0;
			target.set("v.value", "");
		}

		var precision = Math.pow(10, floatDigit);
		var requestAmountRoundup = (Math.ceil((requestAmount/M) * precision) / precision);
		
		if( decimalPlaces(fillAmountText) > 2 )
		{
			fillAmountText = Number(fillAmountText.replace(/[^0-9\.]+/g,""));
			fillAmount = truncateTo2Digit(fillAmountText);
			target.set("v.value", fillAmount.toString());
		}
		
    	if( fillAmount > requestAmountRoundup)
    	{
    		helper.displayToast(component, 'Warning', $A.get("$Label.c.FX_Dashboard_Over_Fill_Text") );
    		target.set("v.value", "");
    	}
    	else if( fillAmount < 0  )
    	{
    		helper.displayToast(component, 'Warning', $A.get("$Label.c.FX_Dashboard_Negative_Fill_Text") );
    		target.set("v.value", "");
    	}


    	var fillValueStorage = component.get("v.fillValueStorage");

    	fillValueStorage[fxsOrderKey] = target.get("v.value");

    	// console.log(fillValueStorage);
    	component.set("v.fillValueStorage" , fillValueStorage );

    	function decimalPlaces(num) {
		  var match = (''+num).match(/(?:\.(\d+))?(?:[eE]([+-]?\d+))?$/);

		  if (!match) { return 0; }
		  return Math.max(
		       0,
		       // Number of digits right of decimal point.
		       (match[1] ? match[1].length : 0)
		       // Adjust for scientific notation.
		       - (match[2] ? +match[2] : 0));
		}
		
		function truncateTo2Digit(number) {

		    var with2Decimals = number.toString().match(/^-?\d+(?:\.\d{0,2})?/)[0];

		    return with2Decimals;
		}

	},

	saveFill: function (component, event, helper) {
		var fxsitem = component.get("v.confirmFXSItem");
		var blotterProfile = component.get("v.blotterProfile");

		// change Total Allocate Amount
		var floatDigit = 2;
		var Million = 1000000;
		var precision = Math.pow(10, floatDigit);
		var getShortFillAmount = fxsitem.FXS_TotalAllocateAmount__c;		
		var roundUp_shortFXS_TotalRequestAmount__c = (Math.ceil((fxsitem.FXS_TotalRequestAmount__c / Million) * precision) / precision);
		
		if (getShortFillAmount == roundUp_shortFXS_TotalRequestAmount__c) {
			fxsitem.FXS_TotalAllocateAmount__c = fxsitem.FXS_TotalRequestAmount__c;
		} else {
			fxsitem.FXS_TotalAllocateAmount__c = getShortFillAmount * Million;
		}

		
		if (blotterProfile.FX_Dashboard_Allow_Edit__c) {
			var inputAmount = component.find('inputAmount');
			// console.log(inputAmount.get("v.value"));
			if (inputAmount.get("v.value") === 0 || isNaN(inputAmount.get("v.value"))) {

			
				helper.displayToast(component, 'Warning', $A.get("$Label.c.FXS_Fill_Amount_Message_Invalid_Input") + " " + fxsitem.FXS_TotalAllocateAmount__c );
			} else {
				
				if (fxsitem.FXS_TotalAllocateAmount__c == fxsitem.FXS_TotalRequestAmount__c) {
					component.set("v.confirmDialogText", $A.get("$Label.c.FX_Dashboard_Full_Fill_Confirm_Text"));
				} else {
					component.set("v.confirmDialogText", $A.get("$Label.c.FX_Dashboard_Partial_Fill_Confirm_Text"));
				}
				component.set("v.fillamountDialogShow", true);
			} 
		}
		else 
		{
			// Not Allow Update Fill Amount
		}
	},
	
	openModalFillAmount: function (component, event, helper) {		
		// Reset to defualt fill amount
		component.set("v.fillamountDialogShow", false);

		var ctarget = event.currentTarget;
    	var idx = ctarget.dataset.value;
    	var type = ctarget.dataset.type;

    	var attributeOrderName = '';
    	if( type == 'buy' )
    	{
    		attributeOrderName = 'v.oscBuyList';
    	}
    	else
    	{
    		attributeOrderName = 'v.oscSellList';
    	}

		var fxsitem = component.get(attributeOrderName)[idx];
		component.set("v.confirmFXSItem", fxsitem);
		component.set("v.confirmDialogShow", true);

	},

	cancelFill : function(component, event , helper){
		var fxsitem = component.get("v.confirmFXSItem");
		fxsitem.FXS_TotalAllocateAmount__c = "";
		component.set("v.confirmFXSItem", fxsitem);
		
		component.set("v.confirmDialogShow", false);
		component.set("v.fillamountDialogShow", false);
		
	},

	backFill: function (component, event, helper) {
		
		var fxsitem = component.get("v.confirmFXSItem");
		fxsitem.FXS_TotalAllocateAmount__c = "";
		component.set("v.confirmFXSItem", fxsitem);

		component.set("v.confirmDialogShow", true);
		component.set("v.fillamountDialogShow", false);
	},
	 refreshBrowser: function  (component, event, helper) {
	    location.reload();
	  },

	  closeDisconnectedDialog: function  (component, event, helper){
	    component.set("v.showDiscon", false);
	  },


})
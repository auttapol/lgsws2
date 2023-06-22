({
  connectCometd: function (component) {

    var helper = this;
    // Configure CometD
    var cometdUrl = window.location.protocol + '//' + window.location.hostname + '/cometd/39.0/';
    var cometd = component.get('v.cometd');
    cometd.configure({
      url: cometdUrl,
      requestHeaders: {
        Authorization: 'OAuth ' + component.get('v.sessionId')
      },
      appendMessageTypeToURL: false
    });
    cometd.websocketEnabled = false;

    // Establish CometD connection
    console.log('Connecting to CometD: ' + cometdUrl);

    cometd.handshake(function (handshakeReply) {
        if (handshakeReply.successful) {
          console.log('Connected to CometD.');
          // Subscribe to platform event
          var newSubscription = cometd.subscribe('/event/FX_Order_Streaming__e',
            function (platformEvent) {
              helper.onReceiveNotification(component, platformEvent);
            }
          );
          // Save subscription for later
          var subscriptions = component.get('v.cometdSubscriptions');
          subscriptions.push(newSubscription);
          component.set('v.cometdSubscriptions', subscriptions);

          // component.set('v.eventConStatus', true);

        } 
        else
        {
          console.error('Failed to connected to CometD.');
        }
    });

     //=============== Connection status and reconnected process(Not implemented yet) ==================
     var _connected = false;

     function checkConnection(response) {

        var lastConnectionStatus = _connected;

        var isConnectionFailed = false;

        if( response.successful == false )
        {
            if( response.failure != null )
            {
              if( response.failure.httpCode != 200 )
              {
                isConnectionFailed = true;
              }

            }
            
            if( response.error != null )
            {
                isConnectionFailed = true;
            }
        }

        if ( cometd.isDisconnected() == true || isConnectionFailed ) 
        {
            _connected = false;
            component.set('v.eventConStatus', false);
            component.set('v.showDiscon', true);
        }
        else
        {
            _connected = true;
            component.set('v.eventConStatus', true);
            component.set('v.showDiscon', false);

            //refresh dashboard
            if( lastConnectionStatus == false )
            {
              helper.generateFXS(component ,helper, '' , 1 , 1);            
            }
        }

        //        var currentdate = new Date(); 
        // var datetime = "Last Sync: " + currentdate.getDate() + "/"
        //         + (currentdate.getMonth()+1)  + "/" 
        //         + currentdate.getFullYear() + " @ "  
        //         + currentdate.getHours() + ":"  
        //         + currentdate.getMinutes() + ":" 
        //         + currentdate.getSeconds();
        //     console.log('check connection:',datetime);

        // For reconnect
        // var wasConnected = _connected;
        // _connected = message.successful;
        // if (!wasConnected && _connected) {
        //     // Reconnected
        // } else if (wasConnected && !_connected) {
        //     // Disconnected
        // }
    }
    var subscription = cometd.addListener('/meta/connect', checkConnection );

// console.log('disconnect next 20 sec s');
// var interval2 = window.setInterval(
//         $A.getCallback(function() {
//           console.log('disconnect next 20 sec');
//           cometd.disconnect();
//         }), 20000
//       );

    var interval = window.setInterval(
        $A.getCallback(function() {

          var lastConnectionStatus = _connected;
          
          if( !cometd.isDisconnected() )
          {

              cometd.remoteCall('/event/FX_Order_Streaming__e', null , 5000, function(response) {

                var isConnectionFailed = false;

                if( response.successful == false )
                {
                    if( response.failure != null )
                    {
                      if( response.failure.httpCode != 200 )
                      {
                        isConnectionFailed = true;
                      }

                    }
                    
                    if( response.error != null )
                    {
                        isConnectionFailed = true;
                    }
                }

                    if ( isConnectionFailed ) 
                    {
                        _connected = false;
                        component.set('v.eventConStatus', false);
                        component.set('v.showDiscon', true);
                    }
                    else
                    {
                        _connected = true;
                        component.set('v.eventConStatus', true);
                        component.set('v.showDiscon', false);

                        if( lastConnectionStatus == false )
                        {
                          helper.generateFXS(component ,helper, '' , 1 , 1);            
                        }
                    }

              });

          }
          else
          {
              _connected = false;
              component.set('v.eventConStatus', false);
              component.set('v.showDiscon', true);
          }


          

        }), 5000
    );   

    cometd.addListener('/meta/disconnect', function(message) {

      //  var currentdate = new Date(); 
      //   var datetime = "Last Sync: " + currentdate.getDate() + "/"
      //           + (currentdate.getMonth()+1)  + "/" 
      //           + currentdate.getFullYear() + " @ "  
      //           + currentdate.getHours() + ":"  
      //           + currentdate.getMinutes() + ":" 
      //           + currentdate.getSeconds();
      //       console.log(datetime);

      component.set('v.eventConStatus', false);
      component.set('v.showDiscon', true);
      _connected = false;

        // if (message.successful) {
        //     _connected = false;
        // }
    });

  },

  disconnectCometd: function (component) {
    var cometd = component.get('v.cometd');
    // Unsuscribe all CometD subscriptions
    cometd.batch(function () {
      var subscriptions = component.get('v.cometdSubscriptions');
      subscriptions.forEach(function (subscription) {
        cometd.unsubscribe(subscription);
      });
    });
    component.set('v.cometdSubscriptions', []);
    // Disconnect CometD
    cometd.disconnect();
    console.log('CometD disconnected.');

    // component.set('v.eventConStatus', false);
  },

  format: function (string) {
    var outerArguments = arguments;
    return string.replace(/\{(\d+)\}/g, function () {
      return outerArguments[parseInt(arguments[1]) + 1];
    });
  },

  onReceiveNotification: function (component, platformEvent) {

    var helper = this;
    var keyChange = "";

    var noticeMessage = this.format($A.get("$Label.c.FX_Dashboard_Update_Notification"), platformEvent.data.payload.Currency_Pair__c, platformEvent.data.payload.Exchange_Rate__c);

    helper.displayToast(component, 'info', noticeMessage);

    // ============== 
    // console.log('obj: ',platformEvent.data.payload);
    var oscSFId = platformEvent.data.payload.FX_Order_Summary_ID__c;



    var items = [];

    var updatedComponent = component.get("v.updatedComponent");
    var updatedComponentFag = component.get("v.updatedComponentFag");
    var actionPromise = new Promise(function (resolve, reject) {

      var componentName = '';
      var controllerName = '';

      if (platformEvent.data.payload.Buy_Sell__c == 'Buy') {
        componentName = 'v.oscBuyList';
        controllerName = 'c.getbuyOrder';
      } else {
        componentName = 'v.oscSellList';
        controllerName = 'c.getSellOrder';
      }

      var action = component.get(controllerName);
      action.setCallback(this, function (response) {
        var state = response.getState();
        if (state === "SUCCESS") {

          var oldValue = helper.getOldVal(component, oscSFId, componentName);
          var newValue = platformEvent.data.payload.Total_Request_Amount__c;
          keyChange = helper.getValUpdateStatus(oldValue, newValue);
          
          if (!(updatedComponent.includes(oscSFId))) {
            updatedComponent.push(oscSFId);
          }
          
          updatedComponentFag[oscSFId] = keyChange;

          var updatedList = helper.generateStyle(response.getReturnValue(),component);

          // Round up Total Request amount Million Unit
          for (var i in updatedList) {
            updatedList[i].Total_Request_Amount_Million_Unit__c = helper.calculatDivideMillion(updatedList[i]);
          }

          component.set(componentName, updatedList);
          resolve();
        } else if (state === "ERROR") {
          var errors = response.getError();
          if (errors) {
            if (errors[0] && errors[0].message) {
              reject(Error("Error message: " + errors[0].message));
            }
          } else {
            reject(Error("Unknown error"));
          }

        }
      });
      $A.enqueueAction(action);

    });


    actionPromise.then(
      function () {
        for (var j = 0; j < updatedComponent.length; j++) {
          var id = updatedComponent[j];

          var subComponents = component.getElement().querySelectorAll("#" + id);
          var targetComponant;

          if (subComponents.length > 0) targetComponant = subComponents[0];

          // $A.util.addClass(targetComponant, 'blink-plus');

          if( id in updatedComponentFag ){
            if( updatedComponentFag[id] === "PLUS"){
              // console.log("ADD PLUS");
              $A.util.addClass(targetComponant, 'blink-plus');
            }
            else if(updatedComponentFag[id] === "SUBB"){
              // console.log("ADD SUBB");
              $A.util.addClass(targetComponant, 'blink-subb')
            } 
          }

          else{
            $A.util.addClass(targetComponant, 'blink-plus');
          }
        }
      },
      function (error) {
        //alert('Failure : ' + error.message);
        console.log(error.message);
      }
    );
  },

  displayToast: function (component, type, message) {
    var toastEvent = $A.get('e.force:showToast');
    toastEvent.setParams({
      type: type,
      message: message
    });
    toastEvent.fire();
  },

  generateFXS: function (component, helper, searchKey, Buypage, Sellpage) {

    var action = component.get("c.getFXSOrder");
    action.setParams({
      "searchKey": searchKey,
      "Buypage": Buypage,
      "Sellpage": Sellpage,
    });

    component.set("v.issearching", true);

    component.set('v.BuyOptionSelectedValue', Buypage);
    component.set('v.SellOptionSelectedValue', Sellpage);

    action.setCallback(this, function (response) {

      // Add console log for SF investigation
      // console.log('FXS response',response.getReturnValue());

      var state = response.getState();
      if (state === "SUCCESS") {
        var Million = 1000000;
        var buylist = helper.generateStyle(response.getReturnValue().orderBuyList,component);
        var selllist = helper.generateStyle(response.getReturnValue().orderSellList,component);

        for (var i in buylist) {
          buylist[i].Total_Request_Amount_Million_Unit__c = helper.calculatDivideMillion(buylist[i]);
        }

        for (var i in selllist) {
          selllist[i].Total_Request_Amount_Million_Unit__c = helper.calculatDivideMillion(selllist[i]);
        }

        component.set("v.oscBuyList", buylist);
        component.set("v.oscSellList", selllist);

      } else {
        var error = response.getError();
        var errorTextList = [];

        for (var i = 0; i < error.length; i++) {
          console.log(error[i]);
          errorTextList.push(error[i].message);
        }

        this.displayToast(component, "Error", "Search failed: " + errorTextList.join("<br />"))
      }
      component.set("v.issearching", false);

    });
    $A.enqueueAction(action);
  },

  calculatDivideMillion: function (order) {
    return Math.ceil((order.FXS_TotalRequestAmount__c / Math.pow(10, 6) * 100).toFixed(2)) / 100;
  },

  generateStyle: function (orderList,component) {

    var fillValueStorage = component.get("v.fillValueStorage");

    // console.log('storage: ',fillValueStorage);
    // console.log('orderList: ',orderList);

    for (var i = 0; i < orderList.length; i++) {
      if (i < orderList.length - 1) {
        // Check if next currency is not same
        if (orderList[i].FXS_CurrencyPair__c != orderList[i + 1].FXS_CurrencyPair__c) {
          orderList[i]["hasBorder"] = true;
        } else {
          orderList[i]["hasBorder"] = false;
        }
      }
        
      //Check FXS_TotalRequestAmount__c if < 100k ADD RED TEXT STYLE
      if(orderList[i].Total_Request_Amount_Million_Unit__c < 0.1){
        orderList[i]["redAleart"] = true;
      }else{
        orderList[i]["redAleart"] = false;
      }
      
      var orderKey = orderList[i].FXS_Order_Key__c;
      
      if( fillValueStorage[orderKey] != null && fillValueStorage[orderKey] != '' )
      {
         orderList[i].FXS_TotalAllocateAmount__c = fillValueStorage[orderKey];
      }
    }


    return orderList;
  },

  fillOrderAction: function (component, event, helper) {

    var fxsitem = component.get("v.confirmFXSItem");
    var actionPromise = new Promise(function (resolve, reject) {
      var action = component.get("c.validateAndUpdateFXS");
      action.setParams({
        "newFXS": fxsitem
      });

      action.setCallback(this, function (response) {
        var state = response.getState();
        if (state === "SUCCESS") {
          if (response.getReturnValue()) {
            resolve();
          } else {
            reject(Error($A.get("$Label.c.FX_Order_Summary_Invalid_Order")));
          }
        } else {
          reject(Error($A.get("$Label.c.FX_Order_Summary_Invalid_Order")));
        }
      });

      component.set("v.processSave", true);
      $A.enqueueAction(action);

    });

    actionPromise.then(
      function () {

        if (typeof fxsitem.FXS_TotalAllocateAmount__c != 'number') {
          // console.log('INDIA');
          fillNumber = Number(fxsitem.FXS_TotalAllocateAmount__c.replace(/[^0-9\.]+/g, ""));
        } else {
          fillNumber = fxsitem.FXS_TotalAllocateAmount__c;
        }
        var action = component.get("c.updateOrderSummary");


        action.setParams({
          "newFXS": fxsitem
        });

        action.setCallback(this, function (response) {
          var state = response.getState();
          if (state === "SUCCESS") {

            helper.displayToast(component, "Success", $A.get("$Label.c.FX_Dashboard_Fill_Success_Notification"));
          } else {
            var error = response.getError();
            var errorTextList = [];

            for (var i = 0; i < error.length; i++) {
              console.log(error[i]);
              errorTextList.push(error[i].message);
            }

            helper.displayToast(component, "Error", $A.get("$Label.c.FX_Dashboard_Fill_Fail_Notification") + errorTextList.join("<br />"))
          }

          component.set("v.confirmFXSItem", "");
          component.set("v.confirmDialogShow", false);
          component.set("v.processSave", false);

        });

        $A.enqueueAction(action);

      },
      function (error) {
        helper.displayToast(component, "Error", error.message);
        component.set("v.processSave", false);
        // $A.get("e.force:closeQuickAction").fire()
        // $A.get('e.force:refreshView').fire();
      }
    );
  },

  setSelectorOption: function (component, searchKey, Buypage, Sellpage) {
    var action = component.get("c.getFXSItemAmount");
    action.setParams({
      "searchKey": searchKey,
    });

    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        var ItemPerPage = response.getReturnValue().itemPerPage;
        var oscBuyItem = response.getReturnValue().orderBuyItem;
        var oscSellItem = response.getReturnValue().orderSellItem;

        var BuyPageNum = Math.ceil(oscBuyItem / ItemPerPage);
        var SellPageNum = Math.ceil(oscSellItem / ItemPerPage);

        if (BuyPageNum == 0) {
          BuyPageNum = 1;
        }

        if (SellPageNum == 0) {
          SellPageNum = 1;
        }

        var BuyPageItems = [];
        var SellPageItems = [];

        for (let index = 1; index <= BuyPageNum; index++) {
          if (index == Buypage) BuyPageItems.push({
            label: index,
            value: index,
            selected: true
          });
          else BuyPageItems.push({
            label: index,
            value: index
          });
        }

        for (let index = 1; index <= SellPageNum; index++) {
          if (index == Sellpage) SellPageItems.push({
            label: index,
            value: index,
            selected: true
          });
          else SellPageItems.push({
            label: index,
            value: index
          });
        }

        // console.log(BuyPageItems);
        // console.log(SellPageItems);

        component.set('v.BuyPageItems', BuyPageItems);
        component.set('v.BuyOptionTotalValue', BuyPageNum);
        component.set('v.BuyOptionSelectedValue', Buypage);

        component.set('v.SellPageItems', SellPageItems);
        component.set('v.SellOptionTotalValue', SellPageNum);
        component.set('v.SellOptionSelectedValue', Sellpage);
      } else {
        var error = response.getError();
        var errorTextList = [];

        for (var i = 0; i < error.length; i++) {
          console.log(error[i]);
          errorTextList.push(error[i].message);
        }

        this.displayToast(component, "Error", "Search failed: " + errorTextList.join("<br />"))
      }

    });
    $A.enqueueAction(action);
  },
  
  //----------------------- Mr.Tay's Code FOR CR -----------------------
  getOldVal : function(component, id, componentName){
    var oscList = component.get(componentName);
    var oldValue = 0;

    // ARROW SIGN (=>) NOT SUPPORTED BY ES5 ON IE
    // var index = oscList.map((o) => o.Id).indexOf(id);
    
    for (var i in oscList) {
      if (oscList[i].Id == id) {
        oldValue = oscList[i].FXS_TotalRequestAmount__c;
      }
    }
    return oldValue;
  },

  getValUpdateStatus : function(oldValue, newValue){
    if(oldValue > newValue){
      return "SUBB";
    } 
    else if(oldValue < newValue){
      return "PLUS";
    } 
    return "NOCH";
  },

})
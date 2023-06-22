    			var ObjId;
    			var Title;
                function NavigateTo(ObjId,Title) {
                    this.ObjId=ObjId;
                    this.Title=Title;
                       	if ((typeof sforce.one != 'undefined') && (sforce.one != null) ) {
						
								sforce.one.navigateToURL('/' + ObjId);
							
                        }
      					else if (sforce.console.isInConsole() ) {
                            //First find the ID of the primary tab to put the new subtab in
                    		sforce.console.getEnclosingPrimaryTabId(openSubtab);
                            
          				}
                    	else{
                            //window.location.href = ObjId;
                            window.open('/' + ObjId);
                            
                        }
                    
                }

				
				
                var openSubtab = function openSubtab(result) {
                //Now that we have the primary tab ID, we can open a new subtab in it
                var primaryTabId = result.id;
 
                sforce.console.openSubtab(primaryTabId , ObjId, true,Title, null, openSuccess, 'salesforceSubtab');
  				
                    
                };
				
                var openSuccess = function openSuccess(result) {
                //Report whether we succeeded in opening the subtab
                    /*if (result.success == true) {
                    alert('subtab successfully opened');
                } else {
                    alert('subtab cannot be opened');
                }  */

                };

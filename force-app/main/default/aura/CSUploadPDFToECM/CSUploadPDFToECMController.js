({
	doInit: function (component, event, helper) {
		
		helper.getEclient(component, event, helper);
		helper.getTimeOut(component, event, helper);
		helper.getCurrentUser(component, event, helper);

	},
	handleFilesChange : function (component, event) 
	{
		var uploadedFiles = event.getParam("files"); 
		component.set("v.fileName",uploadedFiles[0].name);	
		component.set("v.fileObj",uploadedFiles[0]);
		
	},

	onFileUploaded:function(component,event,helper){
		var pdfFile = component.get("v.fileObj");
		var filesize = 3000000;
		var currentUser = component.get("v.currentUser");
		var eclient = component.get("v.eClientObj");
		if(pdfFile != null)
		{
			if (pdfFile.size > 0 && pdfFile.size <= filesize) 
			{
				var fr = new FileReader();
        
				fr.onload = function() {
					var fileContents = fr.result;
					var base64Mark = 'base64,';
					var dataStart = fileContents.indexOf(base64Mark) + base64Mark.length;

					fileContents = fileContents.substring(dataStart);
					
					if(pdfFile.name.length <= 80)
					{
						if(/[' !"#$%&()*+,/:;<=>?@^{}`|[\]\\~']/.test(pdfFile.name) == false)
						{
							if(/.pdf/.test(pdfFile.name) == true)
							{	
								if(currentUser.Profile.Name == 'TMB CM Product Specialist Profile' || currentUser.Profile.Name == 'TMB CRM Admin Profile' ||
								currentUser.Profile.Name == 'TMB CM Product Manager Profile' || currentUser.Profile.Name == 'System Administrator' ||
								currentUser.Id == eclient.CS_Sales_Owner__r.ManagerId )
								{
									helper.upload(component, pdfFile, fileContents,helper);
								}						
								else
								{
									helper.displayToast(component, "Error", $A.get("$Label.c.ECM_Permission_Error_Msg"));
								}
							}
							else
							{
								helper.displayToast(component, "Error", $A.get("$Label.c.ECM_SelectFile_OnlyPDF_Error_Msg"));
							}
						}
						else
						{
							helper.displayToast(component, "Error", $A.get("$Label.c.ECM_SelectFile_SpecialCharacter_Error_Msg"));
						}
						
					}
					else
					{
						helper.displayToast(component, "Error", $A.get("$Label.c.ECM_SelectFile_LongName_Error_Msg"));
					}				
				};

				fr.readAsDataURL(pdfFile);
			}
			else
			{
				helper.displayToast(component, "Error", $A.get("$Label.c.ECM_SelectFile_LargeFile_Error_Msg"));
			}
		}
		else
		{
			helper.displayToast(component, "Error", $A.get("$Label.c.ECM_SelectFile_Error_Msg"));
		}
		component.set("v.fileName",'');
		component.set("v.fileObj",null);
	},

	viewPDF : function(component, event, helper) {
		
		var eclient = component.get("v.eClientObj")
		
		if(eclient != null)
		{
			if(eclient.ECM_Repository__r != null)
			{
				var url = "/apex/CSViewECMFile?ecId=" + eclient.Id;

				var urlEvent = $A.get("e.force:navigateToURL");
				urlEvent.setParams({
					"url": url
				});

				urlEvent.fire();
			}
			else
			{
				helper.displayToast(component, "Error", $A.get("$Label.c.ECM_View_Error_Msg"));
			}
		}
		else
		{
			helper.displayToast(component, "Error", $A.get("$Label.c.ECM_View_Error_Msg"));
		}
  },
	

})
({
    setTabDetail : function(component, event, helper) {
        var workspaceAPI = component.find("workspace");

        workspaceAPI.getEnclosingTabId().then(function(tabId) {
            var focusedTabId = tabId;
            workspaceAPI.setTabLabel({
                tabId: focusedTabId,
                label: "Auto Loan Information"
            });

            workspaceAPI.setTabIcon({
                tabId: focusedTabId,
                icon: "standard:campaign_members",
                iconAlt: "campaign_members"
            });
        })
        .catch(function(error) {
            console.log(error);
        });
    },

    prepareField : function(component, event, helper) {
        var productNum = component.get('v.productNumber');
        var firstSectionFields = [
            {
                field_name : 'RTL_Campaign_Product_'+productNum+'__c',
                read_only : true         
            },
            // {
            //     field_name : '',
            //     read_only : true         
            // },
            {
                field_name : 'RTL_AL_BlueBook__c',
                read_only : false         
            },
            // {
            //     field_name : '',
            //     read_only : true         
            // },
            {
                field_name : 'RTL_AL_car_type__c',
                read_only : true         
            },
            {
                field_name : 'RTL_AL_wanted_amount__c',
                read_only : false         
            },
            {
                field_name : 'RTL_AL_car_brand__c',
                read_only : true         
            },
            {
                field_name : 'RTL_AL_max_set_up_amount__c',
                read_only : false         
            },
            {
                field_name : 'RTL_AL_car_group__c',
                read_only : true         
            },
            {
                field_name : 'RTL_AL_normal_price__c',
                read_only : false         
            },
            {
                field_name : 'RTL_AL_car_subtype__c',
                read_only : true         
            },     
            {
                field_name : 'RTL_AL_DownPercent__c',
                read_only : false         
            },
            {
                field_name : 'RTL_AL_car_year__c',
                read_only : true         
            },
            {
                field_name : 'RTL_AL_DownAmt__c',
                read_only : false         
            },
            {
                field_name : 'RTL_AL_car_gear__c',
                read_only : true         
            },
            {
                field_name : 'RTL_AL_installment_amount__c',
                read_only : false         
            },
            {
                field_name : 'RTL_AL_car_plate_no__c',
                read_only : false         
            },
            {
                field_name : 'RTL_AL_installment_periods__c',
                read_only : false         
            },
            {
                field_name : 'RTL_AL_Province_Car_Plate_No__c',
                read_only : false         
            },
            {
                field_name : 'RTL_AL_PayPerMonth__c',
                read_only : false         
            },


            //LGSWS2
            {
                field_name : 'RTL_AL_Car_Status__c',
                read_only : false         
            },
            {
                field_name : 'RTL_AL_Leasing_Condition__c',
                read_only : false         
            },
            {
                field_name : 'RTL_Partner_Branch__c',
                read_only : false         
            },
            {
                field_name : 'RTL_Partner_Employee__c',
                read_only : false         
            },
            {
                field_name : 'WS_Response_Detail__c',
                read_only : true         
            },
            {
                field_name : 'RTL_Contact_Method__c',
                read_only : true         
            },
            {
                field_name : 'LGS_VIN_No__c',
                read_only : true         
            },
            {
                field_name : 'Car_Reference_No__c',
                read_only : true         
            },
            {
                field_name : 'LGS_Assignment_Code__c',
                read_only : true         
            },
            {
                field_name : 'LGS_BrandShowroomCode__c',
                read_only : true         
            },
            {
                field_name : 'LGS_PartnerCode__c',
                read_only : true         
            },  
            {
                field_name : 'RTL_Partner_Branch_Code__c',
                read_only : true         
            },
            {
                field_name : 'LGS_BrandCode__c',
                read_only : true         
            },            
            {
                field_name : 'RTL_Partner_Employee_Code__c',
                read_only : true         
            }
            
        ];

        var secondSectionFields = [
            {
                field_name : 'RTL_AL_contact_channel__c',
                read_only : false         
            },
            {
                field_name : 'RTL_AL_available_time__c',
                read_only : false         
            },
            {
                field_name : 'RTL_Contact_Address__c',
                read_only : false         
            },
            // {
            //     field_name : '',
            //     read_only : true         
            // },
            {
                field_name : 'RTL_AL_ContactZipcode__c',
                read_only : true         
            },
            {
                field_name : 'RTL_AL_ContactProvince__c',
                read_only : true         
            },
            {
                field_name : 'RTL_AL_ContactDistrict__c',
                read_only : true         
            },
            {
                field_name : 'RTL_AL_ContactSubDistrict__c',
                read_only : true         
            }
        ];
        var thirdSectionFields = [
            {
                field_name : 'RTL_AL_Refer_No_'+productNum+'__c',
                read_only : true         
            },
            {
                field_name : 'RTL_AL_Req_No1_'+productNum+'__c',
                read_only : true         
            },
            {
                field_name : 'RTL_Reason_Lost__c',
                read_only : true         
            },
            {
                field_name : 'RTL_AL_Req_No2_'+productNum+'__c',
                read_only : true         
            },
            {
                field_name : 'Corebank_Emp_Name_'+productNum+'__c',
                read_only : true         
            },
            {
                field_name : 'Corebank_Emp_Phone_No_'+productNum+'__c',
                read_only : true         
            },
            {
                field_name : 'RTL_Hub_Code_'+productNum+'__c',
                read_only : true         
            },
            {
                field_name : 'RTL_Hub_Name_'+productNum+'__c',
                read_only : true         
            },
            //LGSWS2
            {
                field_name : 'HPAP_Status_Code_1__c',
                read_only : true         
            },
            {
                field_name : 'RTL_Status_1__c',
                read_only : true         
            },
            {
                field_name : 'Details_of_Status_1__c',
                read_only : true         
            },
            {
                field_name : 'HPAP_Reason_Code_1__c',
                read_only : true         
            },
            {
                field_name : 'HPAP_Reason_Description_1__c',
                read_only : true         
            },
            {
                field_name : 'RTL_Status_Approve_1__c',
                read_only : true         
            },
            {
                field_name : 'RTL_Refer_Date_1__c',
                read_only : true         
            },
            {
                field_name : 'RTL_Submit_Date_1__c',
                read_only : true         
            },
            {
                field_name : 'Corebank_Approved_Date_Time_1__c',
                read_only : true         
            },
            {
                field_name : 'RTL_Request_Hub_Code_1__c',
                read_only : true         
            },
            {
                field_name : 'RTL_Stage_Name_Date_Time_1__c',
                read_only : true         
            },
            {
                field_name : 'RTL_Request_Hub_Name_1__c',
                read_only : true         
            },
            {
                field_name : 'Corebank_Branch_Code_1__c',
                read_only : true         
            },
            {
                field_name : 'RTL_Product_Campaign_Code_1__c',
                read_only : true         
            },
            {
                field_name : 'Corebank_Branch_Name_1__c',
                read_only : true         
            },
            {
                field_name : 'RTL_Product_Campaign_Name_1__c',
                read_only : true         
            },
            {
                field_name : 'Corebank_Sales_Manager_Head_Id_1__c',
                read_only : true         
            },
            {
                field_name : 'RTL_Dealer_Code_1__c',
                read_only : true         
            },
            {
                field_name : 'Corebank_Sales_Manager_Head_1__c',
                read_only : true         
            },
            {
                field_name : 'RTL_Dealer_Name_1__c',
                read_only : true         
            }
        ];
        component.set('v.firstSectionFields',firstSectionFields);
        component.set('v.secondSectionFields',secondSectionFields);
        component.set('v.thirdSectionFields',thirdSectionFields);
        console.log('v.firstSectionFields',firstSectionFields);
        console.log('v.secondSectionFields',secondSectionFields);
        console.log('v.thirdSectionFields',thirdSectionFields);
        component.set('v.isLoading', false);
    },

    checkPermissionToEdit: function(component,event,helper)
    {
        var action = component.get('c.checkPermissionToEdit');
        action.setParams({
            "recordId" : component.get('v.campaignMemberId')
        });

        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                component.set("v.isShowEditBtn", result);
                if (result == true) {
                    $A.util.removeClass(component.find("toggle1"), "slds-hide")
                } else {
                    $A.util.removeClass(component.find("toggle2"), "slds-hide")
                }
            }
        });
        $A.enqueueAction(action);
    }
})
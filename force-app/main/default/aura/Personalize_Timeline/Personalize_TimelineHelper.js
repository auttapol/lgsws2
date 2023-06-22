({

    setTabTitleLabel: function (component, event, helper) {
        var workspaceAPI = component.find("workspace");
        //Set time out to wait util get focus tab id
        var subtabCount = 0;

        workspaceAPI.getTabInfo().then(function (response) {
            console.log('getTabInfo:', JSON.stringify(response));
            workspaceAPI.isSubtab({
                tabId: response.tabId
            }).then(function (isSubtab) {
                console.log('isSubtab:', isSubtab);
                if (isSubtab) {
                    if (response.pageReference.attributes.componentName == 'c__Personalize_Timeline') {
                        workspaceAPI.setTabLabel({
                            tabId: response.tabId,
                            label: 'Personalize timeline'
                        }).then(() => {
                            console.log('Set tab title.');
                        }).catch((err) => {
                            console.log('Cannot set tab title =>', err)
                        });
                        workspaceAPI.setTabIcon({
                            tabId: response.tabId,
                            icon: "standard:product",
                            iconAlt: component.get("v.mydata.name")
                        }).then(() => {
                            console.log('Set tab icon.');
                        }).catch((err) => {
                            console.log('Cannot set tab icon =>', err)
                        });
                    }
                }
            });
        })
            .catch(function (error) {
                console.log(error);
            });

        workspaceAPI.getFocusedTabInfo().then(function (response) {
            console.log('getFocusedTabInfo:', JSON.stringify(response));
            if (response.subtabs) {
                var firstTabId;
                response.subtabs.forEach((subtab, index) => {
                    if (subtab.pageReference.attributes.componentName == 'c__Personalize_Timeline') {
                        if (index == 0) {
                            firstTabId = subtab.tabId
                        }
                        console.log('firstTabId:', firstTabId);
                        subtabCount++;
                        if (subtabCount > 1) {
                            workspaceAPI.closeTab({ tabId: subtab.tabId });
                            workspaceAPI.focusTab({ tabId: firstTabId });
                        }
                    }
                })
            }

        })
            .catch(function (error) {
                console.log('ERROR set tab title => ', error);
            });
    },

    setRetryMessageObj: function (component) {
        const errMsg = component.get('v.warningMsg');
        const beforeLink = errMsg.toString().substring(0, errMsg.toString().indexOf('{fetchBtn}'));
        const afterLink = errMsg.toString().substring(errMsg.toString().indexOf('{/fetchBtn}') + 11, errMsg.toString().length);
        const clickHere = errMsg.toString().substring(errMsg.toString().indexOf('{fetchBtn}') + 10, errMsg.toString().indexOf('{/fetchBtn}'));
        const warningMsgObj = {
            beforeLink,
            afterLink,
            clickHere,
        }
        component.set('v.warningMsgObj', warningMsgObj);
        // const errMsgSplited = errMsg.toString().replace('{2}', '{1}').split('{1}');
        // const errMsgSplitedNewLine = errMsg.split('{2}');
        // const warningMsgObj = {
        //     beforeLink: errMsgSplited[0],
        //     clickHere: 'Click Here',
        //     afterLink: errMsgSplited[1],
        //     afterNewLine: errMsgSplitedNewLine[1]
        // };
    },
    getAccessPermission: function (component, event, helper) {
        var recordId = component.get('v.recordId');
        console.log('record id =>', recordId)
        var getAccessPermission = new Promise((reslove, reject) => {
            var getAccessPermissionAction = component.get('c.getDataAccessPermission');
            getAccessPermissionAction.setParams({
                "recordId": recordId
            });

            getAccessPermissionAction.setCallback(this, function (response) {
                console.log('get is owner state:', response.getState());
                if (component.isValid() && response.getState() === 'SUCCESS') {
                    if (response.getReturnValue() != null) {
                        const accessResponse = response.getReturnValue();
                        component.set('v.isLoading', false);
                        reslove(accessResponse);
                    }
                } else {
                    var errors = response.getError();
                    errors.forEach(error => {
                        console.log(error.message);
                        //helper.displayToast('error', error.message);
                    });
                    reject(console.log('Error while getting permission'));
                    component.set('v.isLoading', false);
                }
            });
            $A.enqueueAction(getAccessPermissionAction);
        });

        getAccessPermission.then((response) => {
            const isPermission = response;
            console.log('RESPONSE PERMISSION => ', isPermission);
            component.set('v.permission', isPermission);
            if (isPermission) {
                helper.getActivitesCount(component, event, helper);
                helper.getData(component, event, helper);
            }
        });
    },

    getActivitesCount: function (component, event, helper) {
        component.set('v.isLoading', true);
        const recordId = component.get('v.recordId');
        // Get activities count 
        const getActivityCount = new Promise((reslove, reject) => {
            const getActivityCountAction = component.get('c.getActivitiesCount');
            getActivityCountAction.setParams({
                "accountId": recordId,
            });
            getActivityCountAction.setCallback(this, function (response) {
                console.log('Get activities count state:', response.getState());
                if (component.isValid() && response.getState() === 'SUCCESS') {
                    if (response.getReturnValue() != null) {
                        this.setRetryMessageObj(component);
                        const countResponse = response.getReturnValue();
                        reslove(countResponse);
                    }
                } else {
                    // reject(Error('Error while getting oneapp'));
                    console.log('Get activities count err response', JSON.parse(JSON.stringify(response.getError())));
                }
            });
            $A.enqueueAction(getActivityCountAction);
        });

        getActivityCount.then((response) => {
            console.log('Activities count response => ', response);
            component.set('v.activitiesCount', response)
        });

        component.set('v.isLoading', false);
    },

    retryGetDataFromOneApp: function (component, event, helper) {
        component.set('v.isLoading', true);
        var recordId = component.get('v.recordId');
        const oneAppData = [];
        //Get one app data
        var retryGetOneAppData = new Promise((reslove, reject) => {
            const retryGetOneAppDataAction = component.get('c.getOneAppData');
            retryGetOneAppDataAction.setParams({
                "recordId": recordId
            });
            retryGetOneAppDataAction.setCallback(this, function (response) {
                console.log('get oneapp state:', response.getState());
                if (component.isValid() && response.getState() === 'SUCCESS') {
                    if (response.getReturnValue() != null) {
                        this.setRetryMessageObj(component);
                        const accessResponse = response.getReturnValue();
                        reslove(accessResponse);
                    }
                } else {
                    // reject(Error('Error while getting oneapp'));
                    console.log('Oneapp err response', JSON.parse(JSON.stringify(response.getError())));
                }
            });
            $A.enqueueAction(retryGetOneAppDataAction);
        });

        retryGetOneAppData.then((response) => {
            console.log('response one app => ', response)
            if (response.hasError) {
                component.set('v.oneAppErrMsg', response.errMsg)
            } else {
                component.set('v.oneAppErrMsg', '')
            }

            if (response && response.dataList) {
                response.dataList.forEach((oneapp) => {
                    const data = {
                        type: 'PERSONALIZE',
                        id: oneapp.id,
                        cardId: oneapp.cardId,
                        titleThVerify: oneapp.titleThVerify,
                        subTitleThVerify: oneapp.subTitleThVerify,
                        createdAt: oneapp.createDate,
                        expiryAt: oneapp.expiryDate,
                        displayCreateAt: this.oneAppDateFormatter(oneapp.createDate),
                        displayExpiredAt: this.oneAppDateFormatter(oneapp.expiryDate),
                        modifiedAt: oneapp.createDate,
                        isRead: oneapp.isRead,
                        salesforceType: oneapp.salesforceType,
                    };
                    oneAppData.push(data);
                });
            }

            var recentActivities = component.get('v.activities');
            recentActivities = JSON.parse(JSON.stringify(recentActivities));
            console.log('recentActivities', recentActivities)

            const commonObjList = [];
            let oneAppTempData = JSON.parse(JSON.stringify(component.get('v.oneAppTempData')));
            var loadmoreTimes = component.get('v.loadmoreTimes');
            const endDate = new Date();
            let activitiesCount = JSON.parse(JSON.stringify(component.get('v.activitiesCount')));
            const timelineDays = activitiesCount.timelineDays;
            activitiesCount.oneAppDataCount = oneAppData.length
            console.log('activitiesCount', activitiesCount);
            component.set('v.activitiesCount', activitiesCount);
            let totalActivitiesCount = activitiesCount.oneAppDataCount + activitiesCount.campaignMemberCount + activitiesCount.caseCount + activitiesCount.opportunityCount;
            console.log('totalActivitiesCount', totalActivitiesCount);
            component.set('v.totalActivitiesCount', totalActivitiesCount);

            oneAppData.forEach((oneApp) => {
                const startDate = helper.decreaseDays(new Date(), (loadmoreTimes * timelineDays));
                if (helper.isDateBetween(startDate, endDate, oneApp.modifiedAt)) {
                    commonObjList.push(oneApp);
                } else {
                    oneAppTempData.push(oneApp);
                }
            });
            component.set('v.oneAppTempData', oneAppTempData);

            var newCommonObjList = [];
            commonObjList.forEach((each) => {
                const findDuplicateId = recentActivities.find((recent) => {
                    return each.id == recent.id;
                });
                if (!findDuplicateId) {
                    newCommonObjList.push(each);
                }
            });

            newCommonObjList.forEach((newObj) => {
                recentActivities.push(newObj);
            });

            recentActivities.sort((a, b) => {
                return new Date(b.modifiedAt) - new Date(a.modifiedAt)
            });

            component.set('v.activities', recentActivities);
            component.set('v.isLoading', false);
        })
    },

    getData: function (component, event, helper) {
        component.set('v.isLoading', true);
        var recordId = component.get('v.recordId');
        var loadmoreTimes = component.get('v.loadmoreTimes');
        const oneAppData = [];
        //Get one app data
        var getOneAppData = new Promise((reslove, reject) => {
            const getOneAppDataAction = component.get('c.getOneAppData');
            getOneAppDataAction.setParams({
                "recordId": recordId
            });
            getOneAppDataAction.setCallback(this, function (response) {
                console.log('get oneapp state:', response.getState());
                if (component.isValid() && response.getState() === 'SUCCESS') {
                    if (response.getReturnValue() != null) {
                        this.setRetryMessageObj(component);
                        const accessResponse = response.getReturnValue();
                        reslove(accessResponse);
                    }
                } else {
                    // reject(Error('Error while getting oneapp'));
                    console.log('Oneapp err response', JSON.parse(JSON.stringify(response.getError())));
                }
            });
            $A.enqueueAction(getOneAppDataAction);
        });

        getOneAppData.then((response) => {
            console.log('response one app => ', response)
            if (response.hasError) {
                component.set('v.oneAppErrMsg', response.errMsg)
            }
            if (response && response.dataList) {
                response.dataList.forEach((oneapp) => {
                    const data = {
                        type: 'PERSONALIZE',
                        id: oneapp.id,
                        cardId: oneapp.cardId,
                        titleThVerify: oneapp.titleThVerify,
                        subTitleThVerify: oneapp.subTitleThVerify,
                        createdAt: oneapp.createDate,
                        expiryAt: oneapp.expiryDate,
                        displayCreateAt: this.oneAppDateFormatter(oneapp.createDate),
                        displayExpiredAt: this.oneAppDateFormatter(oneapp.expiryDate),
                        modifiedAt: oneapp.createDate,
                        isRead: oneapp.isRead,
                        salesforceType: oneapp.salesforceType,
                    };
                    oneAppData.push(data);
                });
            }
            component.set('v.oneAppTempData', oneAppData);
            console.log('oneAppTempData first init', oneAppData)
            let activitiesCount = JSON.parse(JSON.stringify(component.get('v.activitiesCount')));
            activitiesCount = Object.assign({ oneAppDataCount: response.dataList ? response.dataList.length : 0 }, activitiesCount);
            console.log('activitiesCount', activitiesCount);
            component.set('v.activitiesCount', activitiesCount);
            let totalActivitiesCount = activitiesCount.oneAppDataCount + activitiesCount.campaignMemberCount + activitiesCount.caseCount + activitiesCount.opportunityCount;
            console.log('totalActivitiesCount', totalActivitiesCount);
            component.set('v.totalActivitiesCount', totalActivitiesCount);
        });

        //Get new timeline filter options
        var filters = [], selectedFilters = {};
        var filterValue = [];
        var getTimelineFilterOptions = new Promise((reslove, reject) => {
            var getTimelineFilterOptionAction = component.get('c.getTimelineFilter');
            let filterResponse = [];
            getTimelineFilterOptionAction.setCallback(this, function (response) {
                console.log('get timeline filter options state:', response.getState());
                if (component.isValid() && response.getState() === 'SUCCESS') {
                    if (response.getReturnValue() != null) {
                        filterResponse = response.getReturnValue();
                        filters = filterResponse.map((each) => {
                            return {
                                label: each.filterName,
                                value: helper.concatSpaceWithUnderline(each.value).toUpperCase(),
                                sortNumber: each.sortNumber,
                                checked: each.isDefault,
                            }
                        });

                        //Assign selected filters
                        for (const each of filters) {
                            for (const key in each) {
                                const filterNames = filters.map((filter) => filter.value);
                                if (filterNames.includes(each[key]))
                                    Object.assign(selectedFilters, {
                                        [each[key]]: each.checked
                                    })
                                filterValue.push(each.value);
                            }
                        }
                        component.set('v.filterValue', filterValue);
                        reslove({
                            selectedFilters,
                            filters,
                        });
                    }
                } else {
                    console.log('Error while getting default filters')
                }
            });
            $A.enqueueAction(getTimelineFilterOptionAction);
        });

        getTimelineFilterOptions.then((response) => {
            const filters = response.filters;
            const selectedFilters = response.selectedFilters;
            component.set('v.filters', filters);
            component.set('v.selectedFilters', selectedFilters);
        }).then(() => {
            var action = component.get('c.getActivites');
            var activites = [];
            const queryOpportunnity = selectedFilters.OPPORTUNITY;
            const queryCase = selectedFilters.CASE;
            const queryCampaignMember = selectedFilters.CAMPAIGN_MEMBER;

            action.setParams({
                "accountId": recordId,
                "queryOpportunnity": true,
                "queryCase": true,
                "queryCampaignMember": true,
                "times": loadmoreTimes,
            });

            action.setCallback(this, function (response) {
                console.log('State:', response.getState());
                if (component.isValid() && response.getState() === 'SUCCESS') {
                    if (response.getReturnValue() != null) {
                        console.log('result:', response.getReturnValue());
                        activites = response.getReturnValue();
                        // const accessType = component.get('v.accessType');
                        const accessType = 'No access'
                        let commonObjList = helper.covertCommonActivityObjArray(activites, accessType);
                        const activitiesCount = JSON.parse(JSON.stringify(component.get('v.activitiesCount')));
                        const timelineDays = activitiesCount.timelineDays;

                        oneAppData.forEach((oneApp) => {
                            // commonObjList.push(oneApp);
                            const startDate = helper.decreaseDays(new Date(), (loadmoreTimes * timelineDays));
                            const endDate = new Date();
                            const oneAppDate = oneApp.modifiedAt;
                            if (helper.isDateBetween(startDate, endDate, oneAppDate)) {
                                commonObjList.push(oneApp);
                                let oneAppTempData = JSON.parse(JSON.stringify(component.get('v.oneAppTempData')));
                                let filteredOneAppTempData = oneAppTempData.filter((each) => each.id !== oneApp.id);
                                component.set('v.oneAppTempData', filteredOneAppTempData);
                            }
                        });
                        let oneAppTempData = JSON.parse(JSON.stringify(component.get('v.oneAppTempData')));
                        console.log('oneapp removed elemets', oneAppTempData)

                        commonObjList = commonObjList.sort((a, b) => {
                            return new Date(b.modifiedAt) - new Date(a.modifiedAt)
                        });

                        console.log('oneAppData', oneAppData)
                        console.log('commonObjList', commonObjList)
                        console.log('activities', commonObjList);
                        console.log('Activities', activites);
                        component.set('v.activities', commonObjList);
                    }
                }
            });

            $A.enqueueAction(action);
        }).then(() => {
            component.set('v.isLoading', false);
        });
    },

    loadmoreData: function (component, event, helper) {
        var recordId = component.get('v.recordId');
        var loadmoreTimes = component.get('v.loadmoreTimes');
        loadmoreTimes += 1;
        component.set('v.loadmoreTimes', loadmoreTimes);
        var action = component.get('c.getActivites');
        var activites = [];
        var selectedFilters = component.get('v.selectedFilters');
        selectedFilters = JSON.parse(JSON.stringify(selectedFilters));
        console.log('selectedFilters', selectedFilters)
        const queryOpportunnity = selectedFilters.OPPORTUNITY;
        const queryCase = selectedFilters.CASE;
        const queryCampaignMember = selectedFilters.CAMPAIGN_MEMBER;
        action.setParams({
            "accountId": recordId,
            "queryOpportunnity": true,
            "queryCase": true,
            "queryCampaignMember": true,
            "times": loadmoreTimes,
        });

        component.set('v.isLoading', true);
        console.log('loadmoreTimes', loadmoreTimes)
        action.setCallback(this, function (response) {
            console.log('State:', response.getState());
            if (component.isValid() && response.getState() === 'SUCCESS') {
                if (response.getReturnValue() != null) {
                    console.log('result:', response.getReturnValue());
                    activites = response.getReturnValue();
                    const commonObjList = helper.covertCommonActivityObjArray(activites);
                    var oneAppData = component.get('v.oneAppData');
                    oneAppData = JSON.parse(JSON.stringify(oneAppData));

                    var recentActivities = component.get('v.activities');
                    recentActivities = JSON.parse(JSON.stringify(recentActivities));
                    console.log('recentActivities', recentActivities)
                    var newCommonObjList = [];
                    commonObjList.forEach((each) => {
                        const findDuplicateId = recentActivities.find((recent) => {
                            return each.id == recent.id;
                        });
                        if (!findDuplicateId) {
                            newCommonObjList.push(each);
                        }
                    });
                    const activitiesCount = JSON.parse(JSON.stringify(component.get('v.activitiesCount')));
                    const timelineDays = activitiesCount.timelineDays;
                    let oneAppTempData = JSON.parse(JSON.stringify(component.get('v.oneAppTempData')));

                    console.log('oneAppTempData loadmore', oneAppTempData)
                    oneAppTempData.forEach((oneApp) => {
                        // // commonObjList.push(oneApp);
                        const startDate = helper.decreaseDays(new Date(), (loadmoreTimes * timelineDays));
                        const endDate = new Date();
                        const oneAppDate = oneApp.modifiedAt;
                        if (helper.isDateBetween(startDate, endDate, oneAppDate)) {
                            recentActivities.push(oneApp);
                            let newOneAppTempData = JSON.parse(JSON.stringify(component.get('v.oneAppTempData')));
                            let filteredOneAppTempData = newOneAppTempData.filter((each) => each.id !== oneApp.id);
                            component.set('v.oneAppTempData', filteredOneAppTempData);
                        }
                    });

                    newCommonObjList.forEach((newObj) => {
                        recentActivities.push(newObj);
                    });

                    recentActivities = recentActivities.sort((a, b) => {
                        return new Date(b.modifiedAt) - new Date(a.modifiedAt)
                    });

                    console.log('new activities', newCommonObjList);
                    component.set('v.activities', recentActivities);
                    component.set('v.isLoading', false);
                }
            }
        });
        $A.enqueueAction(action);
    },


    oneAppDateFormatter: function (date) {
        var today = new Date(date);
        var dd = String(today.getDate()).padStart(2, '0');
        var mm = String(today.getMonth() + 1).padStart(2, '0');
        var yyyy = today.getFullYear() + 543;
        today = dd + '/' + mm + '/' + yyyy;
        return today;
    },

    dateFormatterOrigin: function (date, showTime, splitBy) {
        var today = new Date(date);
        var dd = String(today.getDate()).padStart(2, '0');
        var mm = String(today.getMonth() + 1).padStart(2, '0');
        var yyyy = today.getFullYear() + 543;
        var hh = today.getHours();
        var MM = today.getMinutes();
        if (splitBy == undefined)
            splitBy = '/';
        if (showTime) {
            today = `${dd}${splitBy}${mm}${splitBy}${yyyy} ${this.getReplaceString('00', hh)}:${this.getReplaceString('00', MM)} น.`;
        } else {
            today = `${dd}${splitBy}${mm}${splitBy}${yyyy}`;
        }
        return today;
    },

    decreaseDays: function (date, days) {
        const newDate = new Date(date);
        newDate.setDate(newDate.getDate() - days);
        return newDate;
    },

    isDateBetween: function (fromDate, toDate, checkDate) {
        const from = new Date(fromDate);
        const to = new Date(toDate);
        const check = new Date(checkDate);
        return check > from && check < to;
    },

    concatSpaceWithUnderline: function (string) {
        return string.split(' ').join('_');
    },

    numberWithCommas: function (number) {
        return number.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
    },

    getReplaceString: function (format, str, position) {
        const newStr = str.toString()
        const replaceStr = format.substring(0, format.length - newStr.length);
        if (position === 'start') return newStr + replaceStr;
        return replaceStr + newStr;
    },


    covertCommonActivityObjArray: function (activites) {
        const commonObjList = [];
        activites.caseList.forEach((each) => {
            const caseObj = {
                type: 'CASE',
                id: each.Id ? each.Id : '-',
                subject: each.Subject ? each.Subject : '-',
                description: each.Description ? each.Description : '-',
                status: each.Status ? each.Status : '-',
                createdAt: each.CreatedDate ? each.CreatedDate : '-',
                modifiedAt: each.LastModifiedDate ? each.LastModifiedDate : '-',
                //TODO: Fomat date for case
                displayDateFormat: this.dateFormatterOrigin(each.LastModifiedDate, true, '/'),
                channel: each.Origin ? each.Origin : '-',
            }
            commonObjList.push(caseObj);
        });

        activites.opportunities.forEach((each) => {
            const oppObj = {
                type: 'OPPORTUNITY',
                id: each.Id ? each.Id : '-',
                name: each.Name ? each.Name : '-',
                productName: each.RTL_Product_Name__c ? each.RTL_Product_Name__r.Name : '-',
                stage: each.StageName ? each.StageName : '-',
                owner: each.Owner.Name ? each.Owner.Name : '-',
                amount: each.Amount ? this.numberWithCommas(each.Amount) : '-',
                createdAt: each.CreatedDate ? each.CreatedDate : '-',
                modifiedAt: each.LastModifiedDate ? each.LastModifiedDate : '-',
                channel: each.RTL_Oppt_Channel__c ? each.RTL_Oppt_Channel__c : '-',
            }
            commonObjList.push(oppObj);
        });

        activites.campaignMembers.forEach((each) => {
            const groups = [];
            // Group 1
            groups.push({
                RTL_Product_Group: each.RTL_Product_Group_1__c ? each.RTL_Product_Group_1__c : '-',
                RTL_Sub_Group: each.RTL_Sub_Group_1__c ? each.RTL_Sub_Group_1__c : '-',
                RTL_Campaign_Product: each.RTL_Campaign_Product_1__r ? each.RTL_Campaign_Product_1__r.Name : '-',
                RTL_OfferResult_Product: each.RTL_OfferResult_Product_1__c ? each.RTL_OfferResult_Product_1__c : '-'
            });
            //Group 2
            groups.push({
                RTL_Product_Group: each.RTL_Product_Group_2__c ? each.RTL_Product_Group_2__c : '-',
                RTL_Sub_Group: each.RTL_Sub_Group_2__c ? each.RTL_Sub_Group_2__c : '-',
                RTL_Campaign_Product: each.RTL_Campaign_Product_2__r ? each.RTL_Campaign_Product_2__r.Name : '-',
                RTL_OfferResult_Product: each.RTL_OfferResult_Product_2__c ? each.RTL_OfferResult_Product_2__c : '-'
            });
            //Group 3
            groups.push({
                RTL_Product_Group: each.RTL_Product_Group_3__c ? each.RTL_Product_Group_3__c : '-',
                RTL_Sub_Group: each.RTL_Sub_Group_3__c ? each.RTL_Sub_Group_3__c : '-',
                RTL_Campaign_Product: each.RTL_Campaign_Product_3__r ? each.RTL_Campaign_Product_3__r.Name : '-',
                RTL_OfferResult_Product: each.RTL_OfferResult_Product_3__c ? each.RTL_OfferResult_Product_3__c : '-'
            });
            //Group 4
            groups.push({
                RTL_Product_Group: each.RTL_Product_Group_4__c ? each.RTL_Product_Group_4__c : '-',
                RTL_Sub_Group: each.RTL_Sub_Group_4__c ? each.RTL_Sub_Group_4__c : '-',
                RTL_Campaign_Product: each.RTL_Campaign_Product_4__r ? each.RTL_Campaign_Product_4__r.Name : '-',
                RTL_OfferResult_Product: each.RTL_OfferResult_Product_4__c ? each.RTL_OfferResult_Product_4__c : '-'
            });
            //Group 5
            groups.push({
                RTL_Product_Group: each.RTL_Product_Group_5__c ? each.RTL_Product_Group_5__c : '-',
                RTL_Sub_Group: each.RTL_Sub_Group_5__c ? each.RTL_Sub_Group_5__c : '-',
                RTL_Campaign_Product: each.RTL_Campaign_Product_5__r ? each.RTL_Campaign_Product_5__r.Name : '-',
                RTL_OfferResult_Product: each.RTL_OfferResult_Product_5__c ? each.RTL_OfferResult_Product_5__c : '-'
            });

            const campaignM = {
                type: 'CAMPAIGN_MEMBER',
                id: each.Id ? each.Id : '-',
                name: each.Campaign.Name ? each.Campaign.Name : '-',
                startDate: each.Campaign.StartDate ? this.dateFormatterOrigin(each.Campaign.StartDate, false, '/') : '-',
                endDate: each.Campaign.EndDate ? this.dateFormatterOrigin(each.Campaign.EndDate, false, '/') : '-',
                channel: each.RTL_Campaign_Channel_formula__c ? each.RTL_Campaign_Channel_formula__c : '-',
                segmentation: each.RTL_Segmentation__c ? each.RTL_Segmentation__c : '-',
                productFeature: each.RTL_Product_Feature__c ? each.RTL_Product_Feature__c : '-',
                groups,
                modifiedAt: each.LastModifiedDate ? each.LastModifiedDate : '-',
            }
            commonObjList.push(campaignM);
        });
        return commonObjList;
    },

})
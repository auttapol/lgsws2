({
	onInit: function (component, event, helper) {
		helper.doInit(component, event, helper);
		helper.doWorkspaceAPI(component, event, helper);
	},
	handleAlertError: function (component, event, helper) {
		var error = component.get('v.error');
		component.set('v.error.state', Object.keys(error.messages)
			.reduce((l, i) =>
				// error.messages[i].isNoData != true &&
				(l ||
					error.messages[i].isError ||
					error.messages[i].isTimeout), false));
		if (Object.keys(error.messages).reduce((l, i) => l || error.messages[i].isError, false)) {
			helper.handleErrorMessage(component);
		}
		if (Object.keys(error.messages).reduce((l, i) => l || error.messages[i].isTimeout, false)) {
			helper.handleRetry(component);
		} else {
			component.set('v.error.herfLink', '');
		}
	},
	handleRefreshView: function (component, event, helper) {
		component.set('v.error.retry', '');
		var error = component.get('v.error');
		for (var productType in error.messages) {
			if (error.messages[productType].isTimeout) {
				if (productType == 'Leasing') {
					helper.callProduct(component, event, helper);
				} else if (productType == 'Guarantor') {
					helper.callProductGuarantor(component, event, helper);
				}
			}
		}
	},
	handleClickHref: function (component, event, helper) {
		event.preventDefault();
		var theme = component.get('v.theme');
		if (component.find(event.srcElement.name)) {
			if (theme == 'Theme3' || theme == 'Theme4u') {
				component.find(event.srcElement.name).getElement().scrollIntoView({
					block: 'start',
					behavior: "smooth"
				});
			} else {
				component.find('scrollerWrapper').scrollTo('custom', 0, component.find(event.srcElement.name).getElement().offsetTop);
			}
		}
	},
	waterMark: function (component, event, helper) {
		var watermark = component.find('watermark');
		if (watermark && watermark.isValid()) {
			component.set('v.waterMarkImage', watermark.get('v.watermarkHtml'));
		}
	},
})
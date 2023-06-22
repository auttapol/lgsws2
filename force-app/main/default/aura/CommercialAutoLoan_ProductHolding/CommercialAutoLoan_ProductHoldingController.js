({
	onInit: function (component, event, helper) {
		//validate dulplicate page
		helper.checkDulplicatePage(component, event, helper);
		helper.doWorkspaceAPI(component, event, helper);

		if (component.get('v.tmbCustId')) {
			helper.getAccessibleCusHold(component, event, helper);
		} else {
			component.set('v.error.message', $A.get('$Label.c.INT_No_Active_Product'));
			component.set('v.error.state', true);
		}
	},
	waterMark: function (component, event, helper) {
		var watermark = component.find('watermark');
		if (watermark && watermark.isValid()) {
			component.set('v.waterMarkImage', watermark.get('v.watermarkHtml'));
		}
	},
	handleEvent: function (component, event, helper) {
		var params = event.getParams();
		var isSuccess = params.isSuccess;
		var productEvent = component.find(params.productType);
		if (productEvent) {
			component.set(`v.error.messages.${params.productType}`, productEvent.getError());

			component.set('v.error.isError', Object.keys(component.get(`v.error.messages`)).some(key => component.get(`v.error.messages.${key}.isError`)));

			component.set('v.error.isTimeout', Object.keys(component.get(`v.error.messages`)).some(key => component.get(`v.error.messages.${key}.isTimeout`)));

			component.set('v.error.state',
				component.get('v.error.isError') || component.get('v.error.isTimeout') || !isSuccess
			);
		}
		// console.log(helper.parseObj(component.get('v.error')));
		$A.enqueueAction(component.get('c.displayMessage'));
	},
	displayMessage: function (component, event, helper) {
		component.set('v.error.herfLink', '');
		component.set('v.error.retry', '');
		component.set('v.error.message', '');

		var isError = component.get('v.error.isError');
		var isTimeout = component.get('v.error.isTimeout');

		if (isError && !isTimeout) {
			$A.enqueueAction(component.get('c.handleErrorMessage'));
		} else if (!isError && isTimeout) {
			$A.enqueueAction(component.get('c.handleRetryMessage'));
			$A.enqueueAction(component.get('c.handleRetry'));
		} else {
			$A.enqueueAction(component.get('c.handleRetryMessage'));
			$A.enqueueAction(component.get('c.handleRetry'));
			component.set('v.error.message', $A.get('$Label.c.Error_Persists_Contact'));
		}
	},
	handleClickHref: function (component, event, helper) {
		event.preventDefault();
		var theme = component.get('v.theme');
		if (theme == 'Theme3' || theme == 'Theme4u') {
			component.find(event.srcElement.name).getElement().scrollIntoView({
				block: 'start',
				behavior: "smooth"
			});
		} else {
			component.find('scrollerWrapper').scrollTo('custom', 0, component.find(event.srcElement.name).getElement().offsetTop);
		}
	},
	handleRefreshView: function (component, event, helper) {
		component.set('v.error.retry', '');
		var error = component.get('v.error');
		for (var productType in error.messages) {
			if (error.messages[productType].isTimeout && component.find(productType)) {
				component.find(productType).calloutService();
			}
		}
	},
	handleErrorMessage: function (component, event, helper) {
		if (Object.keys(component.get(`v.error.messages`))
			.reduce((l, key) => l || component.get(`v.error.messages.${key}.isError`), false)) {
			$A.createComponents(
				[
					["aura:html", {
						tag: "span",
						body: `${$A.get('$Label.c.ERR001_ProductHolding')}\n${$A.get('$Label.c.ERR001_DetailBelow')}\n`
					}],
				].concat(
					Object.keys(component.get(`v.error.messages`))
					.filter(productType => component.get(`v.error.messages.${productType}.isError`))
					.reduce((l, productType, index, arrays) => {
						l.push(["aura:html", {
							tag: "a",
							HTMLAttributes: {
								name: `${productType}Href`,
								class: 'erorrProduct',
								onclick: component.getReference('c.handleClickHref')
							},
							body: `${component.get(`v.error.messages.${productType}.type`)}${arrays.length - 1 > index ? ', ':''}`,
						}]);
						return l;
					}, [])
				),
				(cmp, status, errorMessage) => {
					if (status === "SUCCESS") {
						component.set('v.error.message', cmp);
					}
				});
		} else {
			component.set('v.error.message', $A.get('$Label.c.ERR001_ProductHolding'));
		}
	},
	handleRetryMessage: function (component, event, helper) {
		var error = component.get(`v.error`);
		var erorrMsg =
			Object.keys(component.get(`v.error.messages`)).reduce((acc, key) => acc || component.get(`v.error.messages.${key}.isTimeout`), false) &&
			Object.keys(component.get(`v.error.messages`)).reduce((acc, key) => acc || component.get(`v.error.messages.${key}.isError`), false) ?
			$A.get('$Label.c.ERR001_ProductHoldingV2') : $A.get('$Label.c.Auto_Loan_Product_holding_Request_Timeout');

		$A.createComponents(
			[
				["aura:html", {
					tag: "span",
					body: `${erorrMsg} `
				}],
			].concat(
				Object.keys(error.messages)
				.filter(f => error.messages[f].isTimeout)
				.reduce((l, productType, index, arrays) => {
					l.push(["aura:html", {
						tag: "a",
						HTMLAttributes: {
							name: `${productType}Href`,
							class: 'erorrProduct',
							onclick: component.getReference('c.handleClickHref')
						},
						body: `${error.messages[productType].type}${arrays.length - 1 > index ? ', ':''}`,
					}])
					return l;
				}, [])),
			function (cmp, status, errorMessage) {
				if (status === "SUCCESS") {
					component.set('v.error.herfLink', cmp);
				}
			});
	},
	handleRetry: function (component, event, helper) {
		var Product_Holding_Refresh = $A.get('$Label.c.Product_Holding_Refresh');
		var messageTimeoutLink = Product_Holding_Refresh.split('{0}');
		$A.createComponents(
			[
				["aura:html", {
					tag: "span",
					body: messageTimeoutLink[0]
				}],
				["aura:html", {
					tag: "a",
					HTMLAttributes: {
						name: 'refreshView',
						onclick: component.getReference('c.handleRefreshView')
					},
					body: $A.get("$Locale.language") == 'th' ? 'คลิกที่นี่' : 'Click Here',
				}],
				["aura:html", {
					tag: "span",
					body: messageTimeoutLink[1]
				}],
			],
			function (cmp, status, errorMessage) {
				if (status === "SUCCESS") {
					component.set('v.error.retry', cmp);
				}
			});

	}
})
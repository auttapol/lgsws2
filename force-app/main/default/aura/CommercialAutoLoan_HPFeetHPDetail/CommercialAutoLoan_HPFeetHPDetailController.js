({
    onInit: function (component, event, helper) {
        helper.doInit(component, event, helper);
    },
    waterMark: function (component, event, helper) {
        var watermark = component.find('watermark');
        if (watermark && watermark.isValid()) {
            component.set('v.waterMarkImage', watermark.get('v.watermarkHtml'));
        }
    },
    handleRefreshView: function (component, event, helper) {
        component.set('v.error.retry', '');
        var error = component.get('v.error');
        if (Object.keys(error.messages).reduce((l, i) => l || error.messages[i].isTimeout, false)) {
            helper.callProduct(component, event, helper);
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

})
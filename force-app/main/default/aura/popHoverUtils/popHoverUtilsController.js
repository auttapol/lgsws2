({
    onInit: function (component, event, helper) {
        component.set('v.uuid', helper.uuid());
        component.set('v.recordId', component.get('v.value'));
    },
    onSetRecordId: function (component, event, helper) {
        component.set('v.recordId', component.get('v.value'));
    },
    handleShowPopover: function (component, event, helper) {
        var overlayLib = component.find('overlayLib');
        var recordId = component.get('v.recordId');

        if (!component.get('v.isPopHover') && recordId) {
            $A.createComponent("c:popHover", {
                    recordId: component.get('v.recordId'),
                    onmouseleave: component.getReference('c.handleHidePopover'),
                    onentering: component.getReference('c.handleMouseentering'),
                    onclosing: component.getReference('c.handleHidePopover')
                },
                function (content, status) {
                    if (status === "SUCCESS") {
                        overlayLib.showCustomPopover({
                            body: content,
                            referenceSelector: `.pophover-${component.get('v.uuid')}`,
                            cssClass: "popoverclass",
                        }).then(function (overlay) {
                            component._overlay = overlay;
                            component._content = content;
                            component.set('v.isPopHover', true);
                        });
                    }
                }
            );
        }
    },
    handleMouseentering: function (component, event, helper) {
        component.set('v.isPopHover', !event.getParam('enter'));
    },
    handleHidePopover: function (component, event, helper) {
        var close = event.getParam ? event.getParam('close') : false;
        if (close) component.find('overlayLib').notifyClose();

        setTimeout(function () {
            var isClose = component.get('v.isPopHover') || close;
            if (isClose && component._overlay) {
                component._overlay.close();
                component.set('v.isPopHover', false);
            }
        }, 250);
    },
})
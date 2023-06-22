jQuery(document).ready(function ($) {
    var leadModal = $('#leadModal');

    var _css = {
        hide: {
            display: 'none'
        },
        show: {
            display: 'block'
        }
    };

    var hideModalForm = function () {
        leadModal.find('.modal-body .prodForm').css(_css.hide);
    };

    var showModalForm = function () {
        leadModal.find('.modal-body .prodForm').css(_css.show);
    };

    var hideModalMore = function () {
        leadModal.find('.modal-body .more').css(_css.hide);
    };

    var showModalMore = function () {
        leadModal.find('.modal-body .more').css(_css.show);
    };

    var hideCallback = function () {
        leadModal.find('.modal-body .callback').css(_css.hide);
    };

    var showModalCallback = function () {
        leadModal.find('.modal-body .callback').css(_css.show);
    };

    var hideModalButtonSubmit = function () {
        leadModal.find('.modal-footer button#moreProd').css(_css.hide);
    };

    var showModalButtonSubmit = function () {
        leadModal.find('.modal-footer button#moreProd').css(_css.show);
    };

    var hideModalButtonOk = function () {
        leadModal.find('.modal-footer button#endProd').css(_css.hide);
    };

    var showModalButtonOk = function () {
        leadModal.find('.modal-footer button#endProd').css(_css.show);
    };

    var setModalButtonSubmit = function () {
        var o = '.modal-footer button#moreProd';
        leadModal.find(o).off('click');
        leadModal.find(o).on('click', function (e) {
            e.preventDefault();

            if (validateModalForm()) {
                hideModalForm();
                hideModalButtonSubmit();
                showModalMore();
                setModalButtonOtherProducts();
                setModalButtonOk();

                // TODO keepInterestedProduct
            window.parent.keepInterestedProduct('some product');
            } else {
                // TODO alert warning!
            }
        });
    };

    var setModalButtonOtherProducts = function () {
        var oInterested = '.modal-body .more a.interested';
        var oNoThank = '.modal-body .more a.nothank';

        leadModal.find(oInterested).off('click');
        leadModal.find(oInterested).on('click', function (e) {
            e.preventDefault();
            window.parent.$('iframe#showproduct').hide();
            window.parent.$('body').css('overflow-y', 'auto');
        });

        leadModal.find(oNoThank).off('click');
        leadModal.find(oNoThank).on('click', function (e) {
            e.preventDefault();
            hideModalMore();
            setModalButtonOk();
            showModalCallback();
            showModalButtonOk();
        });
    };
    
    var setModalButtonOk = function () {
        var o = '.modal-footer button#endProd';

        leadModal.find(o).off('click');
        leadModal.find(o).on('click', function (e) {
            e.preventDefault();
            window.parent.sendToCRM();
        });
    };

    var validateModalForm = function () {
        // TODO modal form validation
        // return boolean
        return true;
    };

    leadModal.on('show.bs.modal', function () {
        hideModalMore();
        hideCallback();
        showModalForm();
        showModalButtonSubmit();
        setModalButtonSubmit();
        hideModalButtonOk();
    });
});
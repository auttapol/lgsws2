/**
 * @author Ittisak Sanguanshua <ittisak.san@tmbbank.com>
 * @author Chaiyaporn Buamas <chaiyaporn.bua@tmbbank.com>
 * @version 1.0
 */
jQuery(document).ready(function ($) {
    var stage = {
        animation: {
            delay: 400
        },
        picker: {
            year_of_birth: null
        },
        otp: {
            phone: null,
            ref: null
        },
        survey: {
            current: '',
            previous: []
        }
    };

    /**
     * hidden form for serialize
     */
    var finform = function (formfin) {
        var add = function (field, value) {
            remove(field);

            formfin.append($('<input/>', {
                type: 'hidden',
                name: field,
                value: value,
                readonly: true
            }));

            return this;
        };

        var remove = function (field) {
            formfin.find(`input[name=${field}]`).remove();

            return this;
        };

        var reset = function () {
            formfin.find('*').remove();
        };

        var submit = function () {
            log.info(formfin.serialize());

            // TODO (keep data)
        };

        return {
            add: add,
            remove: remove,
            reset: reset,
            submit: submit
        };
    }($('form#fin'));

    /**
     * survey's event
     */
    var survey = function () {
        var fade = function (s) {
            $(`.${s}`).fadeIn();

            if (stage.survey.current != '') {
                $(`.${stage.survey.current}`).hide();
            }

            return this;
        };

        var begin = function () {
            fade('intro');
            stage.survey.current = '';
            stage.survey.previous = [];
            stage.otp.phone = null;
            stage.otp.ref = null;
            stage.picker.year_of_birth.setDate(new Date(1992, 0, 1, 0, 0));
            btn.hideBack().hideExit();
            scene.show().begin();
            act.begin().hide();
            data.begin();
            product.hide();
            finform.reset();
            $('.topbar').css('background', '');
            $('.fab').fadeOut();

            return this;
        };

        var goto = function (s) {
            fade(s);
            (stage.survey.current != '') ? stage.survey.previous.push(stage.survey.current) : '';
            stage.survey.current = s;
            scene.moveRight(s);
            act.move(s);

            if (stage.survey.previous.length > 0) {
                btn.showBack();
            }

            return this;
        };

        var backto = function (s) {
            fade(s);
            stage.survey.current = s;
            scene.moveLeft(s);
            act.move(s);

            return this;
        };

        return {
            goto: goto,
            backto: backto,
            begin: begin
        };
    }();

    /**
     * scene's event
     */
    var scene = function (sceneHorizon, sceneMiddle, sceneFront, sceneDelay) {
        var fixBuildingPos = ($(window).width() <= 991) ? 2200 : 2900;
        var pointStart = ($(window).width() <= 991) ? -1000 : 0;

        var begin = function () {
            sceneHorizon.animate({
                left: pointStart
            }, sceneDelay);

            sceneMiddle.animate({
                left: 0
            }, sceneDelay);

            sceneFront.animate({
                left: pointStart
            }, sceneDelay);

            return this;
        };

        var show = function () {
            $('.parallax').fadeIn(sceneDelay);

            return this;
        };

        var hide = function () {
            $('.parallax').fadeOut(sceneDelay);

            return this;
        };

        var moveRight = function (s) {
            var pos = (fixBuildingPos * (parseInt($(`.${s}`).attr('data-progress')) / 100));

            sceneMiddle.animate({
                left: pointStart - (pos / 3)
            }, sceneDelay);

            sceneHorizon.animate({
                left: pointStart - (pos / 3)
            }, sceneDelay);

            sceneFront.animate({
                left: pointStart - pos
            }, sceneDelay);

            return this;
        };

        var moveLeft = function (s) {
            var pos = (fixBuildingPos * (parseInt($(`.${s}`).attr('data-progress')) / 100));

            sceneMiddle.animate({
                left: pointStart - (pos / 3)
            }, sceneDelay);
            
            sceneHorizon.animate({
                left: pointStart - (pos / 3)
            }, sceneDelay);

            sceneFront.animate({
                left: pointStart - pos
            }, sceneDelay);

            return this;
        };

        return {
            begin: begin,
            show: show,
            hide: hide,
            moveRight: moveRight,
            moveLeft: moveLeft
        };
    }($('.horizon.scroll > img'), $('.middle.scroll > img'), $('.front.scroll > img'), stage.animation.delay);

    /**
     * actor's (gif) event
     */
    var act = function (actAni, actAniImg, actAniDelay) {
        var show = function () {
            actAni.fadeIn(actAniDelay);

            return this;
        };

        var hide = function () {
            actAni.fadeOut(actAniDelay);

            return this;
        };

        var begin = function () {
            actAniImg.animate({
                left: 0
            }, actAniDelay);

            return this;
        };

        var move = function (s) {
            var pos = ((parseInt(actAni.width()) * (parseInt($(`.${s}`).attr('data-progress')) / 100)) - 320);

            actAniImg.animate({
                left: `${(pos < 0) ? 0 : pos}px`
            }, actAniDelay);

            return this;
        };

        return {
            show: show,
            hide: hide,
            begin: begin,
            move: move
        };
    }($('.animation'), $('.animation').find('img'), stage.animation.delay);

    /**
     * button's event
     */
    var btn = function (btnExit, btnPrevious, btnAnimateDelay) {
        var showExit = function () {
            btnExit.animate({
                opacity: '1'
            }, btnAnimateDelay);

            return this;
        };

        var hideExit = function () {
            btnExit.animate({
                opacity: '0'
            }, btnAnimateDelay);

            return this;
        };

        var setExit = function () {
            btnExit.click(function (e) {
                e.preventDefault();
                exit();
            });

            return this;
        };

        var exit = function () {
            //survey.begin();
			location.reload();

            return this;
        };

        var showBack = function () {
            btnPrevious.animate({
                opacity: '1'
            }, btnAnimateDelay);

            return this;
        };

        var hideBack = function () {
            btnPrevious.animate({
                opacity: '0'
            }, btnAnimateDelay);

            return this;
        };

        var setBack = function () {
            disableBack();
            btnPrevious.click(function (e) {
                e.preventDefault();

                if (stage.survey.previous.length > 0) {
                    survey.backto(stage.survey.previous.pop());
                }

                if (stage.survey.previous.length < 1) {
                    hideBack();
                }
            });

            return this;
        };
		
		var disableBack = function () {
			btnPrevious.off('click');
			
			return this;
		};

        var setToggleAllProduct = function () {
            $('button#viewall').click(function () {
                if ($(this).html() == 'ดูผลิตภัณฑ์แนะนำ') {
                    $(this).html('ผลิตภัณฑ์ทั้งหมด');
                } else {
                    $(this).html('ดูผลิตภัณฑ์แนะนำ');
                }
				
				$(window).scrollTop(0);
            });

            return this;
        };

        return {
            showExit: showExit,
            hideExit: hideExit,
            setExit: setExit,
            showBack: showBack,
            hideBack: hideBack,
            setBack: setBack,
			disableBack: disableBack,
            setToggleAllProduct: setToggleAllProduct
        };
    }($("#exit"), $("#previous"), stage.animation.delay);

    /**
     * data's event
     */
    var data = function (dataAvatarName) {
        var begin = function () {
            dataAvatarName.val('');
            $('.focus .btn-group div.btn.active').removeClass('active');

            if (typeof stage.picker.year_of_birth == 'object') {
                stage.picker.year_of_birth.setDate(new Date(1992, 0, 1, 0, 0));
            }
        };

        var next, field, value;
        var nextStage = function () {
            $('[data-next-stage]').click(function (e) {
                e.preventDefault();

                var t = $(this);
                next = t.attr('data-next-stage');
                field = t.attr('data-field');
                value = t.attr('data-value');

                if (setFieldVal(field, value)) {
                    survey.goto(t.attr('data-next-stage'));
                    checkData(next);
                }
            });

            return this;
        };

        var setFieldVal = function (f, v) {
            switch (v) {
                case 'male()':
                    $('#male').show();
                    $('#female').hide();
                    finform.add(f, 'male');
		            act.show();
                    break;
                    
                case 'female()':
                    $('#male').hide();
                    $('#female').show();
                    finform.add(f, 'female');
		            act.show();
                    break;

                case 'avatarName()':
                    if (dataAvatarName.val() == '') {
                        dataAvatarName.focus();
                        dataAvatarName.css('background','#f8d7da');
						$('.error').show();
                        return false;
                    } else {
                        finform.add(f, dataAvatarName.val());
                        dataAvatarName.css('background','#fff');
                    }
                    break;

                case 'yearOfBirth()':
                    finform.add(f, $('.js-inline-picker .picker-item.picker-picked').html());
                    break;

                case 'financialFocus()':
                    var fc = [];
                    var o = $('.focus .btn-group div.btn.active');

                    for (var i = 0; i < o.length; i++) {
                        fc.push(o.eq(i).html());
                    }

                    if (fc.length == 0) {
                        return false;
                    }

                    finform.add(f, fc.join(','));
                    break;

                default:
                    if (typeof f != 'undefined' && typeof v != 'undefined') {
                        finform.add(f, v);
                    }
                    break;
            }

            return true;
        };

        var checkData = function (s) {
            switch (s) {
                case 'name':
                    dataAvatarName.focus();
                    break;

                case 'persona':
                    act.hide();
                    scene.hide();
                    btn.hideBack().disableBack();
                    download.init();
                    product.init();
					$('body').css({
						'position': 'relative',
						'overflow': 'scroll',
						'height': 'auto',
						'background': '#e1f4fd'
					});
					$('.topbar').css({
						'background': '#e1f4fd',
						'z-index': '1000',
						'top': '0'
					});
					$('.questions').css({
						'position': 'relative',
						'height': 'auto'
					});
                    break;
            }

            return this;
        };
		
		var nameKeyUp = function () {
			dataAvatarName.click(function () {
				$(this).css('background', '#fff');
				$('.error').hide();
			});
			
			$('#phone').click(function () {
				$(this).css('background', '#fff');
				$('.error').hide();
			});
			
			return this;
		};

        return {
            begin: begin,
            nextStage: nextStage,
			nameKeyUp: nameKeyUp
        };
    }($('input#avatarName'));

    /**
     * download's event
     */
    var download = function () {
        var otpBtn = $('button#otpBtn');
        var otpInput = $('input.otp-input');
        var otpInputMin = 0;
        var otpInputMax = 5;
        var inputPhone = $('input#phone');
        var formMobileInput = $('form#mobileInput');
        var sendOTPBtn = $('button#sendOTP');
        var resendOTPBtn = $('button#resendOTP');

        var sendOTP = function (phone) {
            stage.otp.phone = phone;

            // TODO (send otp)
            var success = phone == '0888888888'; // mock data

            if (success) {
                log.info(phone)
                stage.otp.ref = 'foo'; // mock data
                showOTPInput();
            } else {
                // TODO (when otp sent failed)
                log.warn('otp sent failed');
            }

            return this;
        };

        var verifyOTP = function (otp, callback) {
            // TODO (verify otp)
            var success = otp == '111111'; // mock data

            if (success) {
                log.info(otp)
            } else {
                // TODO (when otp verify failed)
                log.error('otp verify failed');
            }

            if (typeof callback == 'function') {
                callback(success);
            }
        };

        var showOTPInput = function () {
            $('#otpLabel, #otpInput, #sendOTP').fadeIn();
            $('#mobileLabel, #mobileInput, #otpBtn').hide();
            $('#otpInput').css({
                display: 'flex',
                paddingTop: 20
            });
            $('input.otp-input:eq(0)').focus();
        };
		
		var moreProdBtn = $('#moreProd');
		
		moreProdBtn.click(function (e) {
            e.preventDefault();
			$('.prodForm').fadeOut();
			$('.more').fadeIn();
		});

        var reset = function () {
            $('#otpLabel, #otpInput, #sendOTP, #resendOTP, .modal-dialog .success, button#finish, #success').hide();
            $('#mobileLabel, #mobileInput, #otpBtn').fadeIn();
            inputPhone.val('');
            otpInput.val('');
			$('.resend').hide();
			$('.error').hide();
        };

        var init = function () {
            formMobileInput.submit(function (e) {
                e.preventDefault();
            });

            otpBtn.click(function (e) {
                e.preventDefault();

                if (!/^0(6|8|9)\d{8}$/.test(inputPhone.val())) {
                    inputPhone.focus();
					inputPhone.css('background', '#f8d7da');
					$('.error').show();
                } else {
                    sendOTP(inputPhone.val());
                }
            });

            otpInput.keyup(function () {
                var index = otpInput.index(this);
                var inputNext = otpInput.eq(index + 1);

                if (index >= otpInputMin && index < otpInputMax && $(this).val() != '' && inputNext.val() == '') {
                    inputNext.focus();
                }
            });

            otpInput.keydown(function (e) {
                var index = otpInput.index(this);
                var inputPrev = otpInput.eq(index - 1);
                var v = $(this).val();

                if (index > otpInputMin && index <= otpInputMax && e.which == 8 && v == '') {
                    inputPrev.focus();
                }
            });

            sendOTPBtn.click(function (e) {
                e.preventDefault();

                var otp = '';
                for (var i = 0; i < 6; i++) {
                    otp += otpInput.eq(i).val();
                }

                if (!/^\d{6}$/.test(otp)) {
                    //alert('OTP code is invalid.');
					$('.error').css({
						'display': 'block',
						'width': '100%'
					});
					$('.resend').show();
                    return;
                }

                verifyOTP(otp, function (success) {
                    if (success) {
                        $('#otpInput').hide();
                        $('#otpLabel').hide();
                        $('#sendOTP').hide();
                        $('#resendOTP').hide();
                        $('.success').fadeIn();
                        $('#success').fadeIn();
                        $('#finish').fadeIn();
                    } else {
                        //alert('OTP code is invalid.');
						$('.error').show();
						$('.error').css('width', '100%');
						$('.resend').show();

                        otpInput.val('');
                        otpInput.eq(0).focus();
                        resendOTPBtn.fadeIn();
                    }
                });
            });

            resendOTPBtn.click(function (e) {
                e.preventDefault();

                reset();
                inputPhone.val(stage.otp.phone);
            });

            $('#leadModal').on('shown.bs.modal', function () {
                inputPhone.focus();
            }).on('hidden.bs.modal', function () {
                reset();
            });
        };

        var destroy = function () {
            formMobileInput.off('submit');
            otpBtn.off('click');
            otpInput.off('keyup');
            otpInput.off('keydown');
            sendOTPBtn.off('click');
        }

        return {
            init: init,
            destroy: destroy
        }
    }();

    var product = function () {
        var show = function () {
            // TODO (get product)
			
			$('.persona').hide();
			$('.products').fadeIn();
			$('.fab').fadeIn();
			$('.questions').css({
				'position': 'relative',
				'height': 'auto'
			});
			$('.topbar').css({
				'background': '#e1f4fd',
				'z-index': '1000'
			});
			$('body').css({
				'position': 'relative',
				'overflow': 'auto',
				'height': 'auto',
				'background': '#e1f4fd'
			});
        };

        var hide = function () {
            $('.products').fadeOut();
        };

        var init = function () {
            $('#showprod').click(function () {
                show();
				$(window).scrollTop(0);
				
            });
        };

        return {
            hide: hide,
            show: show,
            init: init
        };
    }();

    /**
     * main initial function
     */
    var init = function () {
        /**
         * initial start event
         */
        $("#start").click(function (e) {
            e.preventDefault();

            $('.intro').hide();
            btn.showExit().setExit().setBack().setToggleAllProduct();
            scene.show();
        });

        /**
         * initial scene
         */
        scene.begin();

        /**
         * initial the event to *[data-next-stage]
         */
        data.nextStage().nameKeyUp();

        /**
         * initial the event to year of birth
         */
        if ($('.js-inline-picker').length > 0) {
            stage.picker.year_of_birth = new Picker($('.js-inline-picker')[0], {
                format: 'YYYY',
                rows: 3,
                controls: true,
                inline: true,
            });
        }

        /**
         * initial invert scroll
         */
        $.jInvertScroll(['.scroll'], {
            height: 8000
        });
    };

    init();

    var debug = true;
    var log = {
        info: function (str) {
            if (debug) console.info(str);
        },
        warn: function (str) {
            if (debug) console.warn(str);
        },
        error: function (str) {
            if (debug) console.error(str);
        }
    };
});

$(window).on('load', function () {
    $('a#start').removeClass('-hide');

    // cloud moving for ie
    $('.parallax .middle.scroll').css('background-position', '-86400px 0');
	
	var height = $(window).height();
	var width = $(window).width();
	if(height >= 650) { 
        $('.animation img').css('display', 'block');
		$('.front').css('display', 'block');
		$('.horizon').css('display', 'block');
    } 
    	else 
    { 
	    $('.animation img',).css('display', 'none');
		$('.front').css('display', 'none');
		$('.horizon').css('display', 'none');
	}
	
	
	if(height <= 480) { 
        $('main').css('display', 'none');
		$('header').html('<img src="assets/404.png" style="margin: 70px 110px 0;" /><br/><h1 style="line-height: 2.4rem; font-weight: bold !important; padding: 0 30px; position: relative; top: 20px; text-align: center; color: #666;">Your device is not supported, please upgrade your device if you want to take this journey with us!</h1>')
    }
	
	var $fab = $(".fab");
	var opacity = $fab.css("opacity");
	var scrollStopped;

    var fadeInCallback = function () {
        if (typeof scrollStopped != 'undefined') {
            clearInterval(scrollStopped);
        }

        scrollStopped = setTimeout(function () {
            $fab.animate({ opacity: 1 }, "fast");
        }, 100);
    }

    $(window).scroll(function () {
        if (!$fab.is(":animated") && opacity == 1) {
            $fab.animate({ opacity: 0 }, "fast", fadeInCallback);
        } else {
            fadeInCallback.call(this);
        }
    });
});
({
    // afterRender : function( component, helper ) {

    //     this.superAfterRender();

    //     // this is done in renderer because we don't get
    //     // access to the window element in the helper js.

    //     // per John Resig, we should not take action on every scroll event
    //     // as that has poor performance but rather we should take action periodically.
    //     // http://ejohn.org/blog/learning-from-twitter/
    //     var thisCmp = component.find('scroll_container');
    //     var didScroll = false;

    //     // if(!$A.util.isEmpty(thisCmp)){
    //     //     thisCmp = thisCmp.getElement();
    //     //     thisCmp.onscroll = function()
    //     //     {
    //     //         console.log('thisCmp:',thisCmp);
    //     //         didScroll = true;
    //     //     };
    //     //     console.log('thisCmp111:',thisCmp);
    //     //     //Interval function to check if the user scrolled or if there is a scrollbar
    //     //     var idOfSetInterval = setInterval($A.getCallback(function(){
    //     //         if(didScroll){
    //     //             didScroll = false;
    //     //             if(thisCmp.scrollTop === (thisCmp.scrollHeight - thisCmp.offsetHeight)){
    //     //                 helper.showMore( component );
    //     //             }
    //     //         }
    //     //     }), 750);
    //     console.log('thisCmp:',thisCmp); 
    //     // if(!$A.util.isEmpty(thisCmp)){
    //         thisCmp.getElement().onscroll 
    //     // }
    //     window.onscroll = function() {
    //         //didScroll = true;
    //         console.log('onscroll:');
    //         thisCmp.getElement().onscroll = function(){
    //             didScroll = true;
    //             console.log('scrollTop:',thisCmp.getElement().scrollTop);
    //             console.log('scrollHeight:',thisCmp.getElement().scrollHeight);
    //             console.log('offsetHeight:',thisCmp.getElement().offsetHeight);     
    //         }
    //         // console.log('thisCmp:',thisCmp);
    //     };
    //     // periodically attach the scroll event listener
    //     // so that we aren't taking action for all events
    //     var idOfSetInterval = window.setInterval( $A.getCallback( function() {

    //         // Since setInterval happens outside the component's lifecycle
    //         // We need to check if component exist, only then logic needs to be processed
    //         if ( didScroll && component.isValid() ) {
    //             console.log('Scroll');
    //             didScroll = false;

    //             // adapted from stackoverflow to detect when user has scrolled sufficiently to end of document
    //             // http://stackoverflow.com/questions/4841585/alternatives-to-jquery-endless-scrolling
    //             if ( window['scrollY'] >= document.body['scrollHeight'] - window['outerHeight'] - 100 ) {
    //                 helper.showMore( component );
    //             }

    //         }

    //     }), 1000 );

    //     // Save the id.We need to use in unrender to remove the setInterval()
    //     component.set( "v.setIntervalId", idOfSetInterval );
          
    // },

    // unrender: function( component, helper ) {

    //     this.superUnrender();

    //     // Since setInterval() will be called even after component is destroyed
    //     // we need to remove it in the unrender
    //     window.clearInterval( component.get( "v.setIntervalId" ) );
    // }

    // afterRender : function( component, helper ) {
    //     this.superAfterRender();
    //     var didScrolled;
    //     var div = component.find('scroll_container');
    //     // console.log('div:',div.getElement());
    //     if(!$A.util.isEmpty(div)){
    //         div = div.getElement();
    //         console.log('div:',div.getElement());
    //         console.log('onscroll',div.onscroll);
    //         div.onscroll = function(){       
    //             didScrolled = true;
    //             };
    //         //Interval function to check if the user scrolled or if there is a scrollbar
    //         var intervalId = setInterval($A.getCallback(function(){
    //             if(didScrolled){
    //                 didScrolled = false;
    //                 if(div.scrollTop === (div.scrollHeight - div.offsetHeight)){
    //                     console.log('Scroll');
    //                     //helper.showMore( component );
    //                 }
    //             }
    //         }), 750);
    //         component.set('v.setIntervalId', intervalId);
    //     }
    // },
    // unrender: function( component) {
    //     this.superUnrender();
    //     var intervalId = component.get( 'v.setIntervalId' );
    //     if ( !$A.util.isUndefinedOrNull( intervalId ) ) {
    //         window.clearInterval( intervalId );
    //     }
    // }
})
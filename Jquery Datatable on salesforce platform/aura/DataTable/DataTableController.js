({
    scriptsLoaded : function(component, event, helper) {
        console.log('Script loaded..'); 
    },
    
    doInit : function(component,event,helper){
        helper.intializeTable(component,event,helper);
    },
})
/*   Data JSON = [
 /*                 {
 /*                     "Name": "Burlington Textiles Weaving Plant Generator", 
 /*                     "Status": "Burlington Textiles Corp of America"
 /*                },
 /*                 {
 /*                    "Name": "Edge Emergency Generator",
 /*                   "Status": "Edge Communications"
 /*                 }
 /*              ];
 /*
 /*   Column JSON : [
 /*                   { "data" : "Name"}, 
 /*                   { "data" : "AccountName"}
 /*                 ]
 /*
 */

({
    intializeTable : function(component,event,helper) 
    {
        var helper = this;
        helper.getRecords(component,event,helper);
    },
    getRecords : function(component,event,helper) 
    {
        component.set('v.userId',$A.get("$SObjectType.CurrentUser.Id"));
        component.set('v.Spinner',true);
        var helper = this;
        var isViewDetails = component.get('v.isViewDetails');
        var headerFields = component.get('v.fieldsNameForHeader');
        var apifieldNames = component.get('v.fieldsToDisplay');
        var recordObject = [];
        var headerFieldsList = headerFields.split(',');
        var dateFieldIndex;
        var fieldForDateFilter = component.get('v.fieldForDateFilter');
        
        if(isViewDetails) headerFieldsList.push(component.get('v.viewDetailLabel'));
        if(headerFields != undefined && headerFields != null)  component.set('v.fieldsNameForHeaderList',headerFieldsList);
        if(component.get('v.isDateFilter') && fieldForDateFilter != undefined && fieldForDateFilter != null)
        {
            dateFieldIndex = apifieldNames.split(',').indexOf(fieldForDateFilter);
            if(dateFieldIndex == -1) component.set('v.isDateFilter',false);
            else
            {
                component.set('v.dateFieldIndex',dateFieldIndex);
                component.set('v.dateFieldUIValue',headerFieldsList[dateFieldIndex]);
            }
        }
        
        if(apifieldNames != undefined && apifieldNames != null)
        {
            var cols = [];
            component.set('v.fieldsNameList', apifieldNames.split(','));
            
            component.get('v.fieldsNameList').forEach(function (item) { 
                var itemMap = {};
                
                if(item.includes('.')) itemMap = {"data" : item.split('.')[0]}
                else if(item != 'Id') itemMap = {"data" : item} ;
                    else if(isViewDetails)
                    {
                        itemMap =  { 
                            "data": "Id",      
                            "className": "center",
                            "render": function ( data, type, row ) {
                                //return data;
                                return '<a href="/claims/s/detail/'+ data +'" class="editor_edit">View Details</a>';
                            }
                        }
                    }
                
                if(itemMap.hasOwnProperty("data")) cols.push(itemMap);
            }); 
            
            component.set('v.columns',cols);
        }        
        var action = component.get('c.getRecordList');
        
        action.setParams({            
            objectName : component.get('v.objectName'),
            fields : apifieldNames,
            whereClause : component.get('v.whereCondition'),
            orderByField : component.get('v.orderByFields'),
            orderBy : component.get('v.orderBy'),
            userId : component.get('v.userId'),
            limitValue : component.get('v.limitValue')
        });
        action.setCallback(this, function(response) {
            
            var state = response.getState();
            if (state === "SUCCESS") {
                var res = response.getReturnValue();
                if(res != null && res.length > 0)
                {
                    component.set('v.data', res);
                    helper.intializeJqueryTable(component,event,res);
                    component.set('v.Spinner',false);
                }
                if(res != null & res.length == 0)
                {
                    component.set('v.Spinner',false);
                }
            }
        });
        $A.enqueueAction(action);
        
    },
    intializeJqueryTable  : function(component,event,res) 
    {
        var helper = this;
        setTimeout(function(){ 
            
            helper.intializeJqueryHighlighter(component,event); 
            
            $('#example tfoot th').each( function () {
                var title = $(this).text();
                if(title != '') $(this).html( '<input type="text" class="slds-input" placeholder="Search '+title+'" />' );
            } );
            
            
            $.fn.dataTable.ext.search.push(
                function (settings, data, dataIndex) {
                    var index =  component.get('v.dateFieldIndex');
                    var min = $('#min').datepicker('getDate');
                    var max = $('#max').datepicker('getDate');
                    var startDate = new Date(data[index]);
                    if (min == null && max == null) return true;
                    if (min == null && startDate <= max) return true;
                    if (max == null && startDate >= min) return true;
                    if (startDate <= max && startDate >= min) return true;
                    return false;
                }
            );
            
            $('#min').datepicker({ onSelect: function () { table.draw(); }, changeMonth: true, changeYear: true });
            $('#max').datepicker({ onSelect: function () { table.draw(); }, changeMonth: true, changeYear: true });
            
            $('#min, #max').change(function () {
                table.draw();
            });
            
            $.extend(true, $.fn.dataTable.defaults, {
                mark: true
            });
            var table = $('#example').DataTable ({
                
                "processing": true,
                "data": res,
                "columns" : component.get('v.columns'),
                "mark": true,
                
                initComplete: function () {
                    
                    this.api().columns().every( function () {
                        var that = this;
                        $( 'input', this.footer() ).on( 'keyup change clear', function () {
                            if ( that.search() !== this.value ) {
                                that
                                .search( this.value )
                                .draw();
                            }
                        } );
                    } );
                },
            });
            table.on( 'draw', function () {
                var body = $( table.table().body() );
                body.unhighlight();
                body.highlight( table.search() );
            } );
        }, 200); 
    },
    intializeJqueryHighlighter  : function(component,event) 
    {
        jQuery.extend({
            highlight: function (node, re, nodeName, className) {
                if (node.nodeType === 3) {
                    var match = node.data.match(re);
                    if (match) {
                        var highlight = document.createElement(nodeName || 'span');
                        highlight.className = className || 'highlight';
                        var wordNode = node.splitText(match.index);
                        wordNode.splitText(match[0].length);
                        var wordClone = wordNode.cloneNode(true);
                        highlight.appendChild(wordClone);
                        wordNode.parentNode.replaceChild(highlight, wordNode);
                        return 1; //skip added node in parent
                    }
                } else if ((node.nodeType === 1 && node.childNodes) && // only element nodes that have children
                           !/(script|style)/i.test(node.tagName) && // ignore script and style nodes
                           !(node.tagName === nodeName.toUpperCase() && node.className === className)) { // skip if already highlighted
                    for (var i = 0; i < node.childNodes.length; i++) {
                        i += jQuery.highlight(node.childNodes[i], re, nodeName, className);
                    }
                }
                return 0;
            }
        });
        
        jQuery.fn.unhighlight = function (options) {
            var settings = { className: 'highlight', element: 'span' };
            jQuery.extend(settings, options);
            
            return this.find(settings.element + "." + settings.className).each(function () {
                var parent = this.parentNode;
                parent.replaceChild(this.firstChild, this);
                parent.normalize();
            }).end();
        };
        
        jQuery.fn.highlight = function (words, options) {
            var settings = { className: 'highlight', element: 'span', caseSensitive: false, wordsOnly: false };
            jQuery.extend(settings, options);
            
            if (words.constructor === String) {
                words = [words];
            }
            words = jQuery.grep(words, function(word, i){
                return word != '';
            });
            words = jQuery.map(words, function(word, i) {
                return word.replace(/[-[\]{}()*+?.,\\^$|#\s]/g, "\\$&");
            });
            if (words.length == 0) { return this; };
            
            var flag = settings.caseSensitive ? "" : "i";
            var pattern = "(" + words.join("|") + ")";
            if (settings.wordsOnly) {
                pattern = "\\b" + pattern + "\\b";
            }
            var re = new RegExp(pattern, flag);
            
            return this.each(function () {
                jQuery.highlight(this, re, settings.element, settings.className);
            });
        };
        
        jQuery.browser = {};
        (function () {
            jQuery.browser.msie = false;
            jQuery.browser.version = 0;
            if (navigator.userAgent.match(/MSIE ([0-9]+)\./)) {
                jQuery.browser.msie = true;
                jQuery.browser.version = RegExp.$1;
            }
        })(); 
    }
})
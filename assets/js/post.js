$(document).ready(function(){

    var isMobile = {
        Android: function() {
            return navigator.userAgent.match(/Android/i);
        }
        ,BlackBerry: function() {
            return navigator.userAgent.match(/BlackBerry/i);
        }
        ,iOS: function() {
            return navigator.userAgent.match(/iPhone|iPad|iPod/i);
        }
        ,Opera: function() {
            return navigator.userAgent.match(/Opera Mini/i);
        }
        ,Windows: function() {
            return navigator.userAgent.match(/IEMobile/i);
        }
        ,any: function() {
            return (isMobile.Android() || isMobile.BlackBerry() || isMobile.iOS() || isMobile.Opera() || isMobile.Windows());
        }
    };

    // $('pre').addClass('prettyprint linenums') //添加Google code Hight需要的class

   
    var menuIndex = function(){
        //var ie6 = ($.browser.msie && $.browser.version=="6.0") ? true : false;
        if($('h1',$('#content')).length > 2 && !isMobile.any()){
            var h2 = [],h3 = [],tmpl = '<ul class="nav nav-list">',h2index = 0;

            $.each($('h1,h2',$('#content')),function(index,item){
                if(item.tagName.toLowerCase() == 'h1'){
                    var h2item = {};
                    h2item.name = $(item).text();
                    h2item.id = 'menuIndex'+index;
                    h2.push(h2item);
                    h2index++;
                }else{
                    var h3item = {};
                    h3item.name = $(item).text();
                    h3item.id = 'menuIndex'+index;
                    if(!h3[h2index-1]){
                        h3[h2index-1] = [];
                    }
                    h3[h2index-1].push(h3item);
                }
                item.id = 'menuIndex' + index
            });

            //添加h1
            tmpl += '<p>文章目录</p>';

            for(var i=0;i<h2.length;i++){
                tmpl += '<li><a href="#" data-id="'+h2[i].id+'"><i class="icon-chevron-right"></i>'+h2[i].name+'</a></li>';
                if(h3[i]){
                    tmpl += '<ul class="nav nav-list">';
                    for(var j=0;j<h3[i].length;j++){
                        tmpl += '<li><a href="#'+h3[i][j].name+'-ref" data-id="'+h3[i][j].id+'"><i class="icon-chevron-right"></i>'+h3[i][j].name+'</a></li>';
                    }
                    tmpl += "</ul>";
                }
            }
            tmpl += '</ul>';

            //$('body').append('<div id="menuIndex"></div>');
            $('#menuIndex').append($(tmpl)).delegate('a','click',function(e){
                e.preventDefault();
                var scrollNum = $(this).attr('data-top') || $('#'+$(this).attr('data-id')).offset().top;
                //window.scrollTo(0,scrollNum-30);
                $('body, html').animate({ scrollTop: scrollNum-30 }, 400, 'swing');
            })

            $(window).load(function(){
                var scrollTop = [];
                $.each($('#menuIndex li a'),function(index,item){
                    if(!$(item).attr('data-top')){
                        var top = $('#'+$(item).attr('data-id')).offset().top;
                        scrollTop.push(top);
                        $(item).attr('data-top',top);
                    }
                });

                $(window).scroll(function(){
                    var nowTop = $(window).scrollTop(),index,length = scrollTop.length;
                    if(nowTop+60 > scrollTop[length-1]){
                        index = length
                    }else{
                        for(var i=0;i<length;i++){
                            if(nowTop+60 <= scrollTop[i]){
                                index = i
                                break;
                            }
                        }
                    }
                    $('#menuIndex li').removeClass('active')
                    $('#menuIndex li').eq(index).addClass('active')
                });
            });

            //用js计算屏幕的高度
            $('#menuIndex').css('max-height',$(window).height()-80);
        }
    }

    // $.getScript('/js/prettify/prettify.js',function(){
    //     prettyPrint();
    //     menuIndex();
    // });
    menuIndex();
});
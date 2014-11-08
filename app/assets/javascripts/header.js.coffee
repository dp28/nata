$(window).resize -> 
    $('body').css('padding-top', parseInt($('#main_navbar').css("height"))+10);

$(window).load ->
    $('body').css('padding-top', parseInt($('#main_navbar').css("height"))+10);        
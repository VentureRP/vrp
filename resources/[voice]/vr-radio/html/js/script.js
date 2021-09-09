$(function() {
    window.addEventListener('message', function(event) {
        if (event.data.type == "open") {
            VRRadio.SlideUp()
        }

        if (event.data.type == "close") {
            VRRadio.SlideDown()
        }
    });

    document.onkeyup = function (data) {
        if (data.which == 27) { // Escape key
            $.post('https://vr-radio/escape', JSON.stringify({}));
            VRRadio.SlideDown()
        } else if (data.which == 13) { // Enter key
            $.post('https://vr-radio/joinRadio', JSON.stringify({
                channel: $("#channel").val()
            }));
        }
    };
});

VRRadio = {}

$(document).on('click', '#submit', function(e){
    e.preventDefault();

    $.post('https://vr-radio/joinRadio', JSON.stringify({
        channel: $("#channel").val()
    }));
});

$(document).on('click', '#disconnect', function(e){
    e.preventDefault();

    $.post('https://vr-radio/leaveRadio');
});

VRRadio.SlideUp = function() {
    $(".container").css("display", "block");
    $(".radio-container").animate({bottom: "6vh",}, 250);
}

VRRadio.SlideDown = function() {
    $(".radio-container").animate({bottom: "-110vh",}, 400, function(){
        $(".container").css("display", "none");
    });
}
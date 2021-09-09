VR.Phone.Settings = {};
VR.Phone.Settings.Background = "default-bg";
VR.Phone.Settings.OpenedTab = null;
VR.Phone.Settings.Backgrounds = {
    'default-bg': {
        label: "Standard"
    }
};

var PressedBackground = null;
var PressedBackgroundObject = null;
var OldBackground = null;
var IsChecked = null;

$(document).on('click', '.settings-app-tab', function(e){
    e.preventDefault();
    var PressedTab = $(this).data("settingstab");

    if (PressedTab == "background") {
        VR.Phone.Animations.TopSlideDown(".settings-"+PressedTab+"-tab", 200, 0);
        VR.Phone.Settings.OpenedTab = PressedTab;
    } else if (PressedTab == "profilepicture") {
        VR.Phone.Animations.TopSlideDown(".settings-"+PressedTab+"-tab", 200, 0);
        VR.Phone.Settings.OpenedTab = PressedTab;
    } else if (PressedTab == "numberrecognition") {
        var checkBoxes = $(".numberrec-box");
        VR.Phone.Data.AnonymousCall = !checkBoxes.prop("checked");
        checkBoxes.prop("checked", VR.Phone.Data.AnonymousCall);

        if (!VR.Phone.Data.AnonymousCall) {
            $("#numberrecognition > p").html('Off');
        } else {
            $("#numberrecognition > p").html('On');
        }
    }
});

$(document).on('click', '#accept-background', function(e){
    e.preventDefault();
    var hasCustomBackground = VR.Phone.Functions.IsBackgroundCustom();

    if (hasCustomBackground === false) {
        VR.Phone.Notifications.Add("fas fa-paint-brush", "Settings", VR.Phone.Settings.Backgrounds[VR.Phone.Settings.Background].label+" is ingesteld!")
        VR.Phone.Animations.TopSlideUp(".settings-"+VR.Phone.Settings.OpenedTab+"-tab", 200, -100);
        $(".phone-background").css({"background-image":"url('/html/img/backgrounds/"+VR.Phone.Settings.Background+".png')"})
    } else {
        VR.Phone.Notifications.Add("fas fa-paint-brush", "Settings", "Personal background set!")
        VR.Phone.Animations.TopSlideUp(".settings-"+VR.Phone.Settings.OpenedTab+"-tab", 200, -100);
        $(".phone-background").css({"background-image":"url('"+VR.Phone.Settings.Background+"')"});
    }

    $.post('https://vr-phone/SetBackground', JSON.stringify({
        background: VR.Phone.Settings.Background,
    }))
});

VR.Phone.Functions.LoadMetaData = function(MetaData) {
    if (MetaData.background !== null && MetaData.background !== undefined) {
        VR.Phone.Settings.Background = MetaData.background;
    } else {
        VR.Phone.Settings.Background = "default-bg";
    }

    var hasCustomBackground = VR.Phone.Functions.IsBackgroundCustom();

    if (!hasCustomBackground) {
        $(".phone-background").css({"background-image":"url('/html/img/backgrounds/"+VR.Phone.Settings.Background+".png')"})
    } else {
        $(".phone-background").css({"background-image":"url('"+VR.Phone.Settings.Background+"')"});
    }

    if (MetaData.profilepicture == "default") {
        $("[data-settingstab='profilepicture']").find('.settings-tab-icon').html('<img src="./img/default.png">');
    } else {
        $("[data-settingstab='profilepicture']").find('.settings-tab-icon').html('<img src="'+MetaData.profilepicture+'">');
    }
}

$(document).on('click', '#cancel-background', function(e){
    e.preventDefault();
    VR.Phone.Animations.TopSlideUp(".settings-"+VR.Phone.Settings.OpenedTab+"-tab", 200, -100);
});

VR.Phone.Functions.IsBackgroundCustom = function() {
    var retval = true;
    $.each(VR.Phone.Settings.Backgrounds, function(i, background){
        if (VR.Phone.Settings.Background == i) {
            retval = false;
        }
    });
    return retval
}

$(document).on('click', '.background-option', function(e){
    e.preventDefault();
    PressedBackground = $(this).data('background');
    PressedBackgroundObject = this;
    OldBackground = $(this).parent().find('.background-option-current');
    IsChecked = $(this).find('.background-option-current');

    if (IsChecked.length === 0) {
        if (PressedBackground != "custom-background") {
            VR.Phone.Settings.Background = PressedBackground;
            $(OldBackground).fadeOut(50, function(){
                $(OldBackground).remove();
            });
            $(PressedBackgroundObject).append('<div class="background-option-current"><i class="fas fa-check-circle"></i></div>');
        } else {
            VR.Phone.Animations.TopSlideDown(".background-custom", 200, 13);
        }
    }
});

$(document).on('click', '#accept-custom-background', function(e){
    e.preventDefault();

    VR.Phone.Settings.Background = $(".custom-background-input").val();
    $(OldBackground).fadeOut(50, function(){
        $(OldBackground).remove();
    });
    $(PressedBackgroundObject).append('<div class="background-option-current"><i class="fas fa-check-circle"></i></div>');
    VR.Phone.Animations.TopSlideUp(".background-custom", 200, -23);
});

$(document).on('click', '#cancel-custom-background', function(e){
    e.preventDefault();

    VR.Phone.Animations.TopSlideUp(".background-custom", 200, -23);
});

// Profile Picture

var PressedProfilePicture = null;
var PressedProfilePictureObject = null;
var OldProfilePicture = null;
var ProfilePictureIsChecked = null;

$(document).on('click', '#accept-profilepicture', function(e){
    e.preventDefault();
    var ProfilePicture = VR.Phone.Data.MetaData.profilepicture;
    if (ProfilePicture === "default") {
        VR.Phone.Notifications.Add("fas fa-paint-brush", "Settings", "Standard avatar set!")
        VR.Phone.Animations.TopSlideUp(".settings-"+VR.Phone.Settings.OpenedTab+"-tab", 200, -100);
        $("[data-settingstab='profilepicture']").find('.settings-tab-icon').html('<img src="./img/default.png">');
    } else {
        VR.Phone.Notifications.Add("fas fa-paint-brush", "Settings", "Personal avatar set!")
        VR.Phone.Animations.TopSlideUp(".settings-"+VR.Phone.Settings.OpenedTab+"-tab", 200, -100);
        console.log(ProfilePicture)
        $("[data-settingstab='profilepicture']").find('.settings-tab-icon').html('<img src="'+ProfilePicture+'">');
    }
    $.post('https://vr-phone/UpdateProfilePicture', JSON.stringify({
        profilepicture: ProfilePicture,
    }));
});

$(document).on('click', '#accept-custom-profilepicture', function(e){
    e.preventDefault();
    VR.Phone.Data.MetaData.profilepicture = $(".custom-profilepicture-input").val();
    $(OldProfilePicture).fadeOut(50, function(){
        $(OldProfilePicture).remove();
    });
    $(PressedProfilePictureObject).append('<div class="profilepicture-option-current"><i class="fas fa-check-circle"></i></div>');
    VR.Phone.Animations.TopSlideUp(".profilepicture-custom", 200, -23);
});

$(document).on('click', '.profilepicture-option', function(e){
    e.preventDefault();
    PressedProfilePicture = $(this).data('profilepicture');
    PressedProfilePictureObject = this;
    OldProfilePicture = $(this).parent().find('.profilepicture-option-current');
    ProfilePictureIsChecked = $(this).find('.profilepicture-option-current');
    if (ProfilePictureIsChecked.length === 0) {
        if (PressedProfilePicture != "custom-profilepicture") {
            VR.Phone.Data.MetaData.profilepicture = PressedProfilePicture
            $(OldProfilePicture).fadeOut(50, function(){
                $(OldProfilePicture).remove();
            });
            $(PressedProfilePictureObject).append('<div class="profilepicture-option-current"><i class="fas fa-check-circle"></i></div>');
        } else {
            VR.Phone.Animations.TopSlideDown(".profilepicture-custom", 200, 13);
        }
    }
});

$(document).on('click', '#cancel-profilepicture', function(e){
    e.preventDefault();
    VR.Phone.Animations.TopSlideUp(".settings-"+VR.Phone.Settings.OpenedTab+"-tab", 200, -100);
});


$(document).on('click', '#cancel-custom-profilepicture', function(e){
    e.preventDefault();
    VR.Phone.Animations.TopSlideUp(".profilepicture-custom", 200, -23);
});
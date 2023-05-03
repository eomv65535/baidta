function init_profile_form(){
    var form = $("#user_form");
    form.validate(
        {
            submitHandler: function () {
                showLoading();                
                $.post(form.attr("action"), form.serialize(), function (res) {
                    form.flash_message(res);
                }).complete(function () {
                    hideLoading();
                });
                return false;
            }
        }
    );

    $('#profie-form-ajax-password').validate({ // change password
        submitHandler: function () {
            showLoading();
            var form2 = $(this.currentForm);
            $.post(form2.attr("action"), form2.serialize(), function (res) {
                form2.flash_message(res);
            }).complete(function () {
                hideLoading();
            });
            return false;
        }
    });

    form.find('.btn_change_photo').click(function(){
        $.fn.upload_filemanager_front({
            formats: 'image',
            folder: $("#username").val,            
            selected: function (file) {
                form.find('#user_meta_avatar').val(file.url);
                form.find('img.img-thumbnail').attr('src', file.url);
            },            
        });
        console.log(this)
        return false;
    });
}
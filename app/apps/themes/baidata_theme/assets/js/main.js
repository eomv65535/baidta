// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery.js
//= require ./admin/jquery.validate.js
//= require camaleon_cms/bootstrap.min.js
//= require ./smooth-scroll.polyfills.min.js
//= require ./admin/admin-manifest.js
//= require ./sweetalert2.all.min.js
//= require ./slick.min.js
//= require moment 
//= require fullcalendar
//= require fullcalendar/locale-all


/*
$('.dropdown-toggle').click(function(e) {
    if ($(document).width() > 768) {
      e.preventDefault();  
      var url = $(this).attr('href');           
      if (url !== '#') {      
        window.location.href = url;
      }  
    }
  });
  */
$(function () {
    var logo = $(".bai_top"); 
    $(window).scroll(function () {
        var scroll = $(window).scrollTop();

        if (scroll >= 80) {
            if (!logo.hasClass("sml-logo")) {
                logo.hide();
                logo.removeClass('lrg-logo').addClass("sml-logo").fadeIn("slow");
            }
        } else {
            if (!logo.hasClass("lrg-logo")) {
                logo.hide();
                logo.removeClass("sml-logo").addClass('lrg-logo').fadeIn("slow");
            }
        }
    });
   
});

var scroll = new SmoothScroll('a[href*="#"]',{
    offset: 100	
});

$(document).ready(function() {
    $('.customer-logos').slick({
      slidesToShow: 6,
      slidesToScroll: 1,
      autoplay: true,
      autoplaySpeed: 1000,
      arrows: true,
      dots: false,
      pauseOnHover: false,
      responsive: [{
        breakpoint: 768,
        settings: {
          slidesToShow: 4
        }
      }, {
        breakpoint: 520,
        settings: {
          slidesToShow: 3
        }
      }]
    });
  });


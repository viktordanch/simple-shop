requirejs.config({
  paths: {
    jquery: 'sources/jquery/jquery',
    backbone: 'sources/backbone/backbone',
    underscore: 'sources/underscore/underscore',
    // hbs: 'sources/hbs',
    handlebars: 'sources/handlebars',
    text: 'sources/text',
    spinjs: 'sources/spin.min',
    // foundation: 'sources/foundation',
    // modernizr: 'sources/modernizr',
    precompiledTemplates: 'viktor/my_shop_b/precompiledTemplates',
    my_shop_b_router: 'viktor/my_shop_b/router',
    foundation_setup: 'viktor/foundation_setup',
    my_shop_b_controller: 'viktor/my_shop_b/controller',
    my_shop_b_base_view: 'viktor/my_shop_b/base/baseView',
    my_shop_b_base_model: 'viktor/my_shop_b/base/baseModel',
    my_shop_b_base_collection: 'viktor/my_shop_b/base/baseCollection'
  },
  packages: [
    {
      name: 'shop_b',
      location: 'viktor/my_shop_b/components/shop',
      main: 'index'
    },
    {
      name: 'layoutComponent',
      location: 'viktor/my_shop_b/components/layoutComponent',
      main: 'index'
    }
  ],

  shim: {
    jquery: {
      exports: '$'
    },
    underscore: {
      exports: '_'
    },
    backbone: {
      deps: ['jquery', 'underscore']
    },
    // foundation: {
    //   deps: ['jquery', 'modernizr']
    // }
  }
});

define(function(require){
  require('spinjs');

  function sideNav() {
    console.log('sideNav')
    console.log($(window).width() < 769);
    if ($(window).width() < 769) {
      $('.off-canvas-wrap').removeClass('move-right');
      $('.left-off-canvas-toggle').show();
    } else {
      $('.off-canvas-wrap').addClass('move-right');
      $('.left-off-canvas-toggle').hide();
    }
  }

  $(window).resize(function() {
    sideNav();
  });

  $(document).on('click', '.addToCart', function(e){
    var $el = $(e.target).is('a') ? $(e.target) : $(e.target).parents('a');
    var product_id = $el.data('productid');
    console.log('add to cart');
    console.log(product_id);

    $.ajax({
      url: '/my_shop_b/cart/add_product',
      type: 'POST',
      data: { product_id: product_id }
    }).then(function (data) {
      console.log('success')
      console.log(data)
    }).fail(function (response) {
      console.log('fail')
      console.log(response)
    })
    return false;
  });

  $(document).on('click', '.asideProductMenu .productLink, .topProductMenu .productLink', function(e){
    var $el = $(e.target);

    if(location.pathname.match(/\/products/)) {
      var productsLayout = require('text!./templates/productsLayout.handlebars');
      var precompiledTemplates = require('precompiledTemplates');
      var precompiledProductsLayout = precompiledTemplates.getTemplates(productsLayout, 'list_template');

      if (!$el.is('a')) {
        return false
      } else {
        $.get($el.attr('href')).then(function (data) {
          console.log(data)
          $('.productsList').html('')
          var precompiledProductsLayout = precompiledProductsLayout;
        }).fail(function (data) {
          var parsedDate = JSON.parse(data.responseText);
          $('.productsList').html(precompiledProductsLayout(parsedDate));
          console.log(data)
        }.bind(this));
      }
    } else {
      location = $el.attr('href');
    }
    return false
  });

  $(document).ready(function(){
    sideNav();
    $(".off-canvas-submenu").hide();
    $(".off-canvas-submenu-call").click(function() {
      var icon = $(this).parent().next(".off-canvas-submenu").is(':visible') ? '+' : '-';
      $(this).parent().next(".off-canvas-submenu").slideToggle('fast');
      $(this).find("span").text(icon);
    });
  });


  // infinity scroll
  var page = 1;
  var isLoading = false;

  $('.main').scroll(function() {
    // Modify to adjust trigger point. You may want to add content
    // a little before the end of the page is reached. You may also want
    // to make sure you can't retrigger the end of page condition while
    // content is still loading.

    var isBottom = $('.main > .container').height() <= $('.main').scrollTop() + $('.main').height() + 15;
    if (isBottom && !isLoading) {
      isLoading = true;
      $('.main .productsList').append('<div class="spinnerContainer">Loading</div>')
      setTimeout(loadMoreContent, 2000);
      //loadMoreContent();
    }
  });

  function loadMoreContent() {
    console.log('loadMoreContent');
    isLoading = false;
    $('.main .productsList .spinnerContainer').remove()
    //$('.main .productsList').append($('.main .productsList').html())
    //$.get('content.html', function(data) {
    //  if (data != '') {
    //    $('#content p:last').after(data);
    //  }
    //});

  };

  var Backbone = require('backbone');
  var router = require('my_shop_b_router');

  window.appRouter = new router();

  Backbone.history.start({
    pushState: true,
    root: '/'
  });
});

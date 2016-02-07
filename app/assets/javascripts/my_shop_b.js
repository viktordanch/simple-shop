requirejs.config({
  paths: {
    jquery: 'sources/jquery/jquery',
    jquery_ujs: 'sources/jquery-ujs',
    backbone: 'sources/backbone/backbone',
    underscore: 'sources/underscore/underscore',
    //hbs: 'sources/hbs',
    handlebars: 'sources/handlebars',
    text: 'sources/text',
    spinjs: 'sources/spin.min',
    tweenMax: 'sources/TweenMax.min',
    timelineMax: 'sources/TimelineMax.min',
    TweenLite: 'sources/TweenLite.min',
    sugar: 'sources/sugar.min',
    gsap: 'sources/jquery.gsap.min',
    tokeninput: 'sources/jquery.tokeninput',
    site_helper: 'site_helper',
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
    jquery_ujs: {
      deps: ['jquery']
    },
    jquery: {
      exports: '$'
    },
    underscore: {
      exports: '_'
    },
    backbone: {
      deps: ['jquery', 'underscore']
    },
    tokeninput: {
       deps: ['jquery']
     },
    timelineMax: {
      deps: ['TweenLite']
    }
  }
});

define(function(require){
  var TweenMax = require('tweenMax');
  var TweenLite = require('TweenLite');
  var TimelineMax = require('timelineMax');



  require('jquery_ujs');
  require('tokeninput');
  var siteHelper = require('site_helper');
  var page = 1;
  var total_pages = 100;
  var isLoading = false;
  //var productsLayoutHbs = require('hbs!./templates/productsLayout');
  var productsLayout = require('text!./templates/productsLayout.handlebars');
  var categoriesLayout = require('text!./templates/categoriesLayout.handlebars');
  var cartTable = require('text!./templates/cart_table.handlebars');
  var precompiledTemplates = require('precompiledTemplates');
  var precompiledProductsLayout = precompiledTemplates.getTemplates(productsLayout, 'list_template');
  var precompiledCategoriesLayout = precompiledTemplates.getTemplates(categoriesLayout, 'category_list_template');
  var precompiledCartTable = precompiledTemplates.getTemplates(cartTable, 'cartTable_template');

  function sideNav() {
    console.log('sideNav');
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
    var count = parseInt($el.parents('.add-section').find('input').val()) || 1;

    $.ajax({
      url: '/cart/add_product',
      type: 'POST',
      data: { product_id: product_id, count: count }
    }).then(function (data) {
      var $badge = $('.cart_link .badge');
      $badge.show();
      $badge.html(data.count);
      var t1 = new TimelineMax();
      t1.to('.cart_link .badge', 0.25, { scale: 1.25 })
          .to('.cart_link .badge', 0.25, { scale: 1 });
    }).fail(function (response) {
      console.log('fail')
      console.log(response)
    });
    return false;
  });

  $(document).on('click', '.asideProductMenu .productLink, #catalog .productLink, .topProductMenu .productLink', function(e){
    var $el = $(e.target);

    if(location.pathname.match(/\/products/)) {
      if (!$el.is('a')) {
        return false
      } else {

        var category = $el.attr('href').split('?')[1] ? $el.attr('href').split('?')[1].split('=')[1] : '';
        history.pushState(null, null, 'products?category=' + category);

        $.get($el.attr('href')).then(function (data) {
          $('.productsList').html('')
          var precompiledProductsLayout = precompiledProductsLayout;
        }).fail(function (data) {
          var parsedDate = JSON.parse(data.responseText);
          var categories = parsedDate.categories;
          var products = parsedDate.products;
          $('.productsList').html(precompiledCategoriesLayout({ categories: categories }));
          $('.productsList').append(precompiledProductsLayout({ products: products }));
          console.log(data)
          page = 1;
          total_pages = 100;

          var parsed_url = parsedDate.category ? parsedDate.category.split('/') : [];
          var html_str = '<li><a class="productLink" href="/products">All</a></li>'
          parsed_url.forEach(function(category){
            var index = $.inArray(category, parsed_url);
            html_str += '<li><a class="productLink" href="/products?category=' +
                encodeURI(parsed_url.slice(0, index + 1).join('/'))  + '">' + category + '</a></li>'
          });
          $('#catalog .breadcrumbs').html(html_str);

        }.bind(this));
      }
    } else {
      location = $el.attr('href');
    }
    return false
  }.bind(this));

  $(document).ready(function(){
    sideNav();
    $(".off-canvas-submenu").hide();
    $(".off-canvas-submenu-call").click(function() {
      var icon = $(this).parent().next(".off-canvas-submenu").is(':visible') ? '+' : '-';
      $(this).parent().next(".off-canvas-submenu").slideToggle('fast');
      $(this).find("span").text(icon);
    });

    $(".hot-search").tokenInput("/products/search",{
      tokenLimit: 1,
      hintText: 'Type producr',
      noResultsText: 'Not found product',
      searchingText: 'Looking for ...',
      preventDuplicates: true,
    });
  });


  // infinity scroll


  $('.main').scroll(function() {
    // Modify to adjust trigger point. You may want to add content
    // a little before the end of the page is reached. You may also want
    // to make sure you can't retrigger the end of page condition while
    // content is still loading.

    var isBottom = $('.main > .container').height() <= $('.main').scrollTop() + $('.main').height() + 15;
    if (isBottom && !isLoading) {
      isLoading = true;
      console.log(isLoading)

      //setTimeout(loadMoreContent, 2000);
      loadMoreContent();
    }
  });

  function loadMoreContent() {
    var isProductsOnPage = $('.product-item').length > 0;
    if(isProductsOnPage && parseInt(page) < total_pages){
      $('.main .productsList').append('<div class="medium-12 columns withSpinn"><div class="spinContainer">Loading</div></div>');
      siteHelper.runSpinners($('.main .productsList'));
      console.log('loadMoreContent');

      var category = location.href.split('?')[1] ? location.href.split('?')[1].split('=')[1] : '';
      page += 1;
      $.ajax({
        url: '/products/product_by_page?page=' + page + '&category=' + category,
        type: 'GET',
        success: function (data) {
          var products = data.products;
          total_pages = data.total;
          isLoading = false;

          console.log(page)
          console.log(total_pages)

          $('.main .productsList .withSpinn').remove();
          $('.productsList').append(precompiledProductsLayout({ products: products }));
        },
        error: function (data) {
          isLoading = false;
          console.log('FAIL');
          console.log(data);
        }
      })

    } else {
      isLoading = false;
    }
  };

  // change count on catalog page
  $(document).on('keyup change', '.productsList .add-section input, #product-page .add-section input', function (e) {
    e.preventDefault();
    var count = $(this).val();
    if(isNaN(parseInt(count)) || parseInt(count) < 1){
      count = 1;
      $(this).val(count);
    } else {
      count = parseInt(count);
    }
    $(this).parents('.add-section').find('.addToCart').attr('data-count', count);
  });

  $(document).on('click', '.productsList .add-section .count-up, .productsList .add-section .count-down, #product-page .add-section .count-up, #product-page .add-section .count-down', function (e) {
    e.preventDefault();
    var $el = $(e.target).is('a') ? $(e.target) : $(e.target).parents('a');
    var $section = $el.parents('.add-section');
    var $input = $section.find('input');
    var count;
    if(isNaN(parseInt($input.val())) || parseInt($input.val()) < 1){
      count = 1;
    } else {
      count = parseInt($input.val());
    }
    if($el.hasClass('count-up')){
      count = count + 1;
    }else{
      count = count == 1 ? 1 : count - 1;
    }
    $input.attr('value', count);
    $section.find('.addToCart').attr('data-count', count);
  });

  // refresh cart js
  var refreshCart = function (params) {
    console.log('trye');
    $.ajax({
      url: '/cart/update_product_count',
      type: 'POST',
      data: params,
      dataType: 'json'
    }).then(function (response) {
      console.log('true');
      console.log(response)
      $('table tbody').html(precompiledCartTable(response))
    }).fail(function (response) {
      console.log('false');
      console.log(response)
    });
  };

  $(document).on('click', '#cart-page .add-section .count-up, #cart-page .add-section .count-down', function (e) {
    e.preventDefault();
    var $el = $(e.target).is('a') ? $(e.target) : $(e.target).parents('a');
    var $section = $el.parents('.add-section');
    var $input = $section.find('input');
    var product_id = $el.data('product-id');
    var count;

    if(isNaN(parseInt($input.val())) || parseInt($input.val()) < 1){
      count = 1;
    } else {
      count = parseInt($input.val());
    }

    if($el.hasClass('count-up')){
      count = count + 1;
    }else{
      count = count == 1 ? 1 : count - 1;
    }

    refreshCart({ product_id: product_id, count: count });
  });

  $(document).on('keyup change', '#cart-page .add-section input', function (e) {
    e.preventDefault();
    var $el = $(e.target);
    setTimeout(function(){
      var count = $el.val();
      var product_id = $el.data('product-id');
      if(isNaN(parseInt(count)) || parseInt(count) < 1){
        count = 1;
        $el.val(count);
      } else {
        count = parseInt(count);
      }
      refreshCart({ product_id: product_id, count: count });
    }, 2000)

  });

  $(document).on('click', '.go-to-product', function(){
    var id = parseInt($('.top-bar .hot-search').val());
    if(parseInt(id)) {
      location = '/products/' + id;
    }
  })

  var Backbone = require('backbone');
  var router = require('my_shop_b_router');

  window.appRouter = new router();

  Backbone.history.start({
    pushState: true,
    root: '/'
  });
});

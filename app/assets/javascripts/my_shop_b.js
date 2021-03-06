requirejs.config({
  paths: {
    jquery: 'sources/jquery/jquery',
    jquery_ujs: 'sources/jquery-ujs',
    backbone: 'sources/backbone/backbone',
    underscore: 'sources/underscore/underscore',
    masonry: 'sources/masonry.pkgd.min',
    //hbs: 'sources/hbs',
    I18n: 'sources/i18n',
    i18nTranslation: 'i18n/translations',
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
    foundation_min: 'sources/foundation.min',
    offcanvas: 'sources/foundation.offcanvas',
    precompiledTemplates: 'viktor/my_shop_b/precompiledTemplates',
    my_shop_b_router: 'viktor/my_shop_b/router',
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
    offcanvas: {
      deps: ['foundation_min']
    },
    foundation_min: {
      deps: ['jquery']
    },
    i18nTranslation: {
      deps: ['I18n']
    },
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
  require('i18nTranslation');
  require('foundation_min');
  require('offcanvas');
  require('tweenMax');
  require('TweenLite');
  require('timelineMax');
  require('jquery_ujs');
  require('tokeninput');
  Masonry = require('masonry');

  $(function () {
    $(document).foundation();

    $(document)
        .on('open.fndtn.offcanvas', '[data-offcanvas]', function() {
          setTimeout(function(){
            refreshMasonry();
          }.bind(this), 500);
          $('html').css('overflow', 'hidden');
        })
        .on('close.fndtn.offcanvas', '[data-offcanvas]', function() {
          setTimeout(function(){
            refreshMasonry();
          }.bind(this), 500);

          $('html').css('overflow', 'auto');
        });
  });

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
    //console.log('sideNav');
    //console.log($(window).width() < 769);
    //if ($(window).width() < 769) {
    //  $('.off-canvas-wrap').removeClass('move-right');
    //  $('.top-bar .left-off-canvas-toggle').show();
    //} else {
    //  $('.off-canvas-wrap').addClass('move-right');
    //  $('.top-bar .left-off-canvas-toggle').hide();
    //}
    //
    //if (!(/\/products\?category/.test(location.href))) {
    //  $('.off-canvas-wrap').foundation('offcanvas', 'hide', 'move-right');
    //}
  }

  var refreshMasonry = function () {
    if(this.msnry) {
      window.msnry = this.msnry;
      this.msnry.layout();
    }
  };

  $(window).resize(function() {
    sideNav();
    refreshMasonry();
  });

  $(document).on('click', '.ajax_load', function(e){
    var $el = $(this);
    var url = $el.attr('href');
    var title = $el.attr('title');
    $('.page_content').load(url + '?api=true', function () {
      if ($('.shopContainer .grid').length > 0) {
        window.recreateMasonry();
      }
    }.bind(this));
    window.history.pushState(url, title, url);

    return false;
  });

  $(document).on('click', '.modal-order-link', function(e){
    var url = $(this).attr('href');
    $('#myModal .modal-body').load(url + '?api=true');
    $('#myModal').foundation('reveal', 'open');
    return false;
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
        updateTopCartCount(data.count);
        showAddToCartAction($el);
    }).fail(function (response) {
      console.log('fail')
    });
    return false;
  });
  showAddToCartAction = function ($el) {
    var $span = $el.parent();
    $el.hide();
    $span.append("<div>In cart</div>");
    setTimeout(function(){
      $span.find('div').remove();
      $el.show();
    }, 3000)
  };

  $(document).on('click', '.asideProductMenu .productLink, #catalog .productLink, .topProductMenu .productLink', function(e){
    var $menuExpand = $(e.target).is('span') && $(e.target).hasClass('right');

    if ($menuExpand) {
      return false;
    }

    var $el = $(e.target).is('a') ? $(e.target) : $(e.target).closest('a');

    if((location.pathname.match(/\/products/) && !(/^\/products\/[0-9]+$/.test(location.pathname)))) {
      if (!$el.is('a')) {
        return false
      } else {

        var category = $el.attr('href').split('?')[1] ? $el.attr('href').split('?')[1].split('=')[1] : '';
        history.pushState(null, null, 'products?category=' + category);

        $.ajax({
              url: $el.attr('href'),
              type: 'GET',
              dataType: 'json'
            }
        ).then(function (data) {
          $('.productsList .products, .productsList .categories').html('');
          var categories = data.categories;
          var products = data.products;
          $('.productsList .categories').html(precompiledCategoriesLayout({ categories: categories }));
          $('.productsList .products').append(precompiledProductsLayout({ products: products }));
          page = 1;
          total_pages = 100;

          var parsed_url = data.category ? data.category.split('/') : [];
          var html_str = '<li><a class="productLink" href="/products">' + I18n.t('All') + '</a></li>';
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
      open_submenu($(this));
    });

    $(".hot-search").tokenInput("/products/search",{
      tokenLimit: 1,
      hintText: 'Type producr',
      noResultsText: 'Not found product',
      searchingText: 'Looking for ...',
      preventDuplicates: true,
    });

    var product_url = location.href.split('/products')
    if(product_url && product_url[1]) {
      var $el = $('[href="' + '/products' + product_url[1] + '"]')
      if($el) {
        $el.parents('.off-canvas-submenu').each(function(){
          var $a = $(this).prev().find('a');
          open_submenu($a);
        });

        open_submenu($el);
      }
    }
  });

  var open_submenu = function($el) {
    var icon = $el.parent().next(".off-canvas-submenu").is(':visible') ? '+' : '-';
    $el.parent().next(".off-canvas-submenu").slideToggle('fast');
    $el.find("span.right").text(icon);
  };


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
          $('.productsList .products').append(precompiledProductsLayout({ products: products }));
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
      updateTopCartCount(response.total_count);
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

  $(document).on('click', '.images_galery img', function(){
    var original_src = $(this).attr('src').replace('thumb', 'original');
    $('.large_image img').attr('src', original_src);
  });

  $(document).on('click', '.go-to-product', function(){
    var id = parseInt($('.top-bar .hot-search').val());
    if(parseInt(id)) {
      location = '/products/' + id;
    }
  });

  $(document).on('click', '.remove-product', function(e){
    e.preventDefault();
    e.stopPropagation();

    var $el = $(e.target).is('a') ? $(e.target) : $(e.target).closest('a');
    var url = $el.attr('href');
    $.ajax({
      url: url,
      type: 'DELETE',
      dataType: 'json',
      success: function (data) {
        updateTopCartCount(data.count);
        if ($el.parents('table').find('tbody tr').length <= 2){
          $('.page-content').html("<p>Your cart is empty</p>");
        } else {
          $el.parents('tr').fadeOut();
          $el.parents('tr').remove();
        }
      },
      error: function (data) {
        console.log('error');
      }
    });

    return false;
  });
  var updateTopCartCount = function (count) {
    var $badge = $('.cart_link .badge');
    if (count > 0) {
      $badge.html(count);
      $badge.show();
      var t1 = new TimelineMax();
      t1.to('.cart_link .badge', 0.25, {scale: 1.25})
          .to('.cart_link .badge', 0.25, {scale: 1});
    } else {
      $badge.hide();
    }
  };

  $(window).load(function(){
    this.recreateMasonry();
  }.bind(this));

  window.recreateMasonry = function () {
    var container = document.querySelector('.grid');
    if (container) {
      this.msnry = new Masonry( container, {
        // options
        itemSelector: '.grid-item',
        // use element for option
        columnWidth: '.grid-sizer',
        percentPosition: true
      });
      //this.msnry = new Masonry( container, {
      //  // options
      //  itemSelector: '#container li'
      //});
      setTimeout(function(){
        refreshMasonry();
      }.bind(this), 10);
    }
  };

  var Backbone = require('backbone');
  var router = require('my_shop_b_router');

  window.appRouter = new router();

  Backbone.history.start({
    pushState: true,
    root: '/'
  });
});

define(function (require) {
  require('sugar');
  var spinner = require('spinjs');

  return {
    spinner: spinner,
    mainSpinOption: {
      lines: 17,            // The number of lines to draw
      length: 15,           // The length of each line
      width: 3,             // The line thickness
      radius: 30,           // The radius of the inner circle
      scale: 1,             // Scales overall size of the spinner
      corners: 0.8,         // Corner roundness (0..1)
      color: '#000',        // #rgb or #rrggbb or array of colors
      opacity: 0.25,        // Opacity of the lines
      rotate: 10,           // The rotation offset
      direction: 1,         // 1: clockwise, -1: counterclockwise
      speed: 0.8,           // Rounds per second
      trail: 18,            // Afterglow percentage
      fps: 20,              // Frames per second when using setTimeout() as a fallback for CSS
      zIndex: 2e9,          // The z-index (defaults to 2000000000)
      className: 'spinner', // The CSS class to assign to the spinner
      top: '50%',           // Top position relative to parent
      left: '50%',          // Left position relative to parent
      shadow: false,        // Whether to render a shadow
      hwaccel: false,       // Whether to use hardware acceleration
      position: 'absolute', // Element positioning
    },
    setSpinner: function (container, spinOptions) {
      var customSpinOption = Object.merge(this.mainSpinOption, spinOptions || {});
      $(container).html('');
      return (new this.spinner(customSpinOption)).spin(container);
    },
    runSpinners: function ($el, spinOptions) {
      $el.find('.spinContainer').each(function (i, el) {
        this.setSpinner(el, spinOptions);
      }.bind(this));
    },
    middlePointToResize: 1150,
  };
});

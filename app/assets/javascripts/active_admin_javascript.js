//= require chosen-jquery

$(document).ready(function(){
  $(".chosen-input").chosen({
    allow_single_deselect: true,
    no_results_text: 'No results matched'
  });
});

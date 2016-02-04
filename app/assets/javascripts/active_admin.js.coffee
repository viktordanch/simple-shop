#= require 'jquery'
#= require 'chosen-jquery'

$ ->
  # enable chosen js
  $('.chosen-input').chosen
    allow_single_deselect: true
    no_results_text: 'No results matched'
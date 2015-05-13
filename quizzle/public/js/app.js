$(function (){

  var pageTmpl = Handlebars.compile([
    "{{#each results}}",
    "<tr>",
    "<td>{{id}}</td>",
    "<td>{{value}}</td>",
    "<td>{{#each responses}}",
    "<span{{#if correct}} class='correct'{{/if}}>{{value}}</span>",
    "{{/each}}</td>",
    "</tr>{{/each}}"].join("\n"));

  window.history.replaceState({data:$('table tbody').html()}, "initial", window.location.search);

  $('<button class="prev">Prev</button>').appendTo('.controls');
  $('<button class="reverse">Reverse</button>').appendTo('.controls');
  $('<button class="next">Next</button>').appendTo('.controls');

  var get_next = function (next_mod){
    var skip = window.location.search.match(/skip=(\d+)/);
    var next = skip ? parseInt(skip[1], 10) : 0;
    if (next + next_mod >= 0) { next += next_mod;}

    return next;
  };

  var new_search = function (next, reverse) {
    var result = [];
    if (next) {
      result.push("skip=" + next);
    }
    if (reverse) {
      result.push("reverse=true");
    }
    return result.length ? "?" + result.join("&") : ""
  };

  var api_call = function (url, next_mod, reverse) {
    var next = get_next(next_mod);

    $.get(url,
          {offset: next * 10, limit: 10, reverse: reverse},
          function (data, status, jqXHR) {
            var tableData;

            if (data['results'] && data.results.length && !data.last){
              tableData = pageTmpl(data)
              $('table tbody').html(tableData);
              window.history.pushState(
                {data: tableData},
                "forward",
                new_search(next, reverse) || "/");
            }
          });

  };

  $('body').on('click', 'button.next', function (e) {
    var reverse = window.location.search.match(/reverse/) ? true : false;
    e.preventDefault();
    api_call('api/questions', 1, reverse);
  });

  $('body').on('click', 'button.prev', function (e) {
    var reverse = window.location.search.match(/reverse/) ? true : false;
    e.preventDefault();
    api_call('api/questions', -1, reverse);
  });

  $('body').on('click', 'button.reverse', function (e) {
    var reverse = window.location.search.match(/reverse/) ? true : false;
    e.preventDefault();
    api_call('api/questions', 0, !reverse);
  });

  $(window).on('popstate', function (e) {
    $('table tbody').html(e.originalEvent.state.data);
  });

  $('body').on('click', 'tr', function (e) {
    $(this).find('.correct').animate({opacity: 0.5}, 200).animate({opacity: 1}, 500);
  });

});

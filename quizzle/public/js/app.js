$(function (){

  var pageTmpl = Handlebars.compile([
    "{{#each results}}",
    "<tr>",
    "<td>{{value}}</td>",
    "<td>{{#each responses}}",
    "<span{{#if correct}} class='correct'{{/if}}>{{value}}</span>",
    "{{/each}}</td>",
    "</tr>{{/each}}"].join("\n"));

  window.history.replaceState({data:$('table tbody').html()}, "initial", window.location.search);

  //$('<button class="reverse">Reverse</button>').appendTo('.controls');

  $('<button class="prev">Prev</button>').appendTo('.controls');
  $('<button class="next">Next</button>').appendTo('.controls');

  $('body').on('click', 'button.next', function (e) {
    var skip = window.location.search.match(/skip=(\d+)/);
    var next = skip ? parseInt(skip[1], 10) + 1 : 1;
    $.get('api/questions',
          {offset: next * 10, limit: 10},
          function (data, status, jqXHR) {
            var tableData;
            if (data['results'] && data.results.length && !data.last){
              tableData = pageTmpl(data)
              $('table tbody').html(tableData);
              window.history.pushState(
                {data: tableData},
                "forward",
                "?skip=" + next);
            }
          });
  });

  $(window).on('popstate', function (e) {
    $('table tbody').html(e.originalEvent.state.data);
  });

  $('body').on('click', 'tr', function (e) {
    $(this).find('.correct').animate({opacity: 0.5}, 200).animate({opacity: 1}, 500);
  });

  $('body').on('click', 'button.prev', function (e) {
    var skip = window.location.search.match(/skip=(\d+)/);
    var next = skip ?  parseInt(skip[1], 10) - 1 : 0

    if (next >= 0){
      $.get('api/questions',
            {offset: next * 10, limit: 10},
            function (data, status, jqXHR){
              var tableData;
              if (data['results'] && data.results.length) {
                tableData = pageTmpl(data)
                $('table tbody').html(tableData);
                window.history.pushState({data: tableData},
                                         "backward",
                                         "?skip=" + next);
              }
            });
    }
  })
  $('body').on('click', 'button.reverse', function (e) {
    var trs = $('table tr').slice(1).get()
    $('table tr').slice(1).remove()

    $.each(trs.reverse(), function (i, el) {
      $('table tbody').append(el)
    });
  });
});

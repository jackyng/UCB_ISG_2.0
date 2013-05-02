$(document).ready(function() {
	$("#my_tree").treeview({control: "#treecontrol"});
	$(".iframe").colorbox({iframe:true, width:"100%", height:"100%"});
  $('#my_tree *').each(function() {
      $(this).tooltip({
        trigger: 'hover',
        placement: 'right',
        delay: { show: 500, hide: 100 }
      }) 
  });
});

//Show the ticket form
function displayTicketForm() {
  var url = "/complaint/create";
  $(location).attr('href', url);
}

//Show the ticket content
function displayTicket(id) {
  var url = "/complaint/ticket?cid=" + id;
  $(location).attr('href', url);
}

//Show a complaint chart
function displayChart() {
  var url = "/complaint/chart";
  $(location).attr('href', url);
}


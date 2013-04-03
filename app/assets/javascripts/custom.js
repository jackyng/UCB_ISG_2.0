function displayTicket(id) {
	window.location.replace('complaint/ticket?cid=' + id)
}

$(document).ready( function() {
	$("#my_tree").treeview({control: "#treecontrol"});
	$("#my_tree_two").treeview({control: "#treecontrol_two"});
	$(".iframe").colorbox({iframe:true, width:"80%", height:"80%"});
	$("#toggle_btn").click(function() {
    	$("#a_view").hide();
    	$("#u_view").show();
  	});
  	$("#toggle_btn_two").click(function() {
    	$("#u_view").hide();
    	$("#a_view").show();
  	});
});
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
    $('#body').tabs();
});


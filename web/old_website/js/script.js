function delete_cookie( name ) {
  document.cookie = name + '=; expires=Thu, 01 Jan 1970 00:00:01 GMT;';
};

$(document).ready(function() {
	var windowHeight = $(window).height();
	var contentLocation = $(".content").position().top;
	var footerOuterHeight = $(".pageFooter").outerHeight();
	//alert(windowHeight);
	//alert(contentLocation);
	//alert(footerOuterHeight);
	var setContentNewHeight = (windowHeight) - (contentLocation + footerOuterHeight + 500);
	$(".content").css({"min-height" : setContentNewHeight});
	

	$("#register").click(function(){
		window.location = 'register.php';
	});
	
	$(".nav-tabs li").click(function(){
		//$(".nav-tabs li").removeClass("selected");
		//$(this).addClass("selected");
		var getTabId = $(this).attr("id");
		var pageName = getTabId+'.php';
		window.location = pageName;
	});
	
	//$("#signout").click(function(){
	//	window.location = 'loginPage.php';
	//});
	
	$(".pagination a").click(function(){
			$(".pagination a").removeClass("selected");
			$(this).addClass("selected");
	});
});
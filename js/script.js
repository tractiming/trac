$(document).ready(function() {
	var windowHeight = $(window).height();
	var contentLocation = $(".content").position().top;
	var footerOuterHeight = $(".pageFooter").outerHeight();
	//alert(windowHeight);
	//alert(contentLocation);
	//alert(footerOuterHeight);
	var setContentNewHeight = (windowHeight) - (contentLocation + footerOuterHeight + 70);
	$(".content").css({"min-height" : setContentNewHeight});
	

	$("#register").click(function(){
		window.location = 'userInfo.php';
	});
	
	$(".nav-tabs li").click(function(){
		//$(".nav-tabs li").removeClass("selected");
		//$(this).addClass("selected");
		var getTabId = $(this).attr("id");
		var pageName = getTabId+'.php';
		window.location = pageName;
	});
	
	$("#signout").click(function(){
		window.location = 'loginPage.php';
		//delete cookies somehow
	});
	
	$(".pagination a").click(function(){
			$(".pagination a").removeClass("selected");
			$(this).addClass("selected");
	});
});
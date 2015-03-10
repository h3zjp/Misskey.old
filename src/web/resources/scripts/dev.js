$.fn.isVisible = function() {
	return $.expr.filters.visible(this[0]);
};

function showContents(targetUrl, methodType) {
	if(methodType == 'GET') {
		var callbacks = $.Callbacks();
		callbacks.add(dispLoading("Now Loading..."));
		dispLoading("Now Loading...", function() {
			$.ajax({
				url: targetUrl,
				type: 'GET',
				dataType: 'html',
			})
			.done(function(data) {
				removeLoading(function() {
					$("main").hide();
					$("main").html($(data).children("main").html());
					$("main").fadeIn(500);
				});
			})
			.fail(function(data) {
				//失敗時
				removeLoading(function() {
					$("main").hide();
					$("main").html("<article><p>Failed to display contents :(</p></article>");
					$("main").fadeIn(500);
				});
			})
		});
	}else{
		console.log("not implement.");
	}
}

function dispLoading(message, callback) {
	var loadingMessage = message != '' ? '<div id="loading-text">' + message + '</div>' : '';
	if($('#loading').size() == 0) {
		$('main').html('<div id="loading"><img id="loading-image" src="/resources/images/loading/loading.gif"></img>' + loadingMessage + '</div>');
		$('#loading').hide();
		$('#loading').fadeIn(500, callback);
	}
}

function removeLoading(callback) {
	$('#loading').fadeOut(
		500,
		function() {
			$('#loading').remove();
			callback();
		});
}

$(function() {
	$('#contents > nav > ul > li > ul').hide();

	$('#contents nav ul li h1').click(function () {
		if($(this).parent().children('ul').isVisible()) {
			$(this).parent().children('ul').hide(250);
		} else {
			$(this).parent().children('ul').show(250);
		}
	});

	$('#myapp ul li').click(function () {
		if($(this).children().prop('nodeType') != 1) {
			var idName = $(this).attr('id');
			if(idName == 'myapp-new') {
				showContents('https://misskey.xyz/dev/myapp/new', 'GET');
			} else {
				showContents('https://misskey.xyz/dev/myapp?q=' + idName, 'GET');
			}
		}
	});

	$('#restapi ul li , #streamingapi ul li').click(function () {
		if($(this).children().prop("nodeType") != 1) {
			var idName = $(this).attr("id");
			showContents('https://misskey.xyz/dev/reference?q=' + idName, 'GET');
		}
	});

	$('#usertheme ul li').click(function () {
		if($(this).children().prop("nodeType") != 1) {
			var idName = $(this).attr("id");
			if(idName == "usertheme-new") {
				showContents('https://misskey.xyz/dev/usertheme/new', 'GET');
			} else {
				showContents('https://misskey.xyz/dev/usertheme?q=' + idName, 'GET');
			}
		}
	});
});
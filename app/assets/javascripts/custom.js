$(document).ready(function(){
	$('textarea').bind('input', function(){
		var $len = $(this).val().length
		var re_len = 140 - $len
		$('em.input_remain').text(re_len)
	}
	)
})
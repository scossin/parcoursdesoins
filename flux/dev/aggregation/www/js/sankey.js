


// ce dernier est cliqué quand l'utilisateur arrive sur Sankey

$('document').ready(function(){
	var li_sankey = $("[data-value=Sankey]");
	li_sankey[0].onclick = function(){
		document.getElementById("update").click();
	};
});


remove_radiobuttons = function(){
	var radiobuttons = $('*[id^="sankey_radio"]');
	for (var i = 0 ; i< radiobuttons.length ; i++){ 
		radiobuttons[i].parentNode.remove()
	}
};




Shiny.addCustomMessageHandler('moveTree', function(message){
/* pour retirer le contenu (le div) du tabset */

setTimeout(function(){
var divtarget = document.getElementById(message.divtargetname);

var treeboutton = document.getElementById(message.treebouttonid);

if (message.boolprevious == null){
	divtarget.appendChild(treeboutton);
} else {
	divtarget.prepend(treeboutton);
}
//

}, 100);

// Afficher le tree
//var bouttonafficher = document.getElementById(message.bouttonafficher);
//bouttonafficher.click()
});	


/*
setTimeout(function(){
//alert("re-ordering now !! ");
var $divs = $("div.box");
var valuesort = $divs.sort(function (a, b) {     return $(a).attr("value") > $(b).attr("value"); });
if ($divs.length > 1){
	$("#alltrees").html(valuesort);
}
bouttonafficher.click();
}, 100);
*/



/* Test : 
 * 
 * message = [];
message.divtargetname = "alltrees"
var divtarget = document.getElementById(message.divtargetname);
message.elementname = "treeboutton10";
var element = document.getElementById(message.elementname);
divtarget.appendChild(element);
 * 
 * 
 * */

/* L'objectif de la fonction remove_treebutton est de retirer tous les div "treebutton" qui précède ou qui suit un treebutton
 * Comme tous les évènements qui suivent ( ou précédent) un évènement sont dépendants de ce dernier, s'il change alors tous les autres doivent changer en cascade 
 * C'est pourquoi on les retire tous et l'utilisateur devra re-définir ce qu'il veut voir */
Shiny.addCustomMessageHandler('remove_treebutton', function(message){
	value = parseInt(message.value); // value : numéro du div stocké dans l'attribut value du div
	if (message.itself == null){ // faut-il retirer aussi le div de l'évènement lui-meme : oui pour le boutton remove, non pour le boutton validate
		boolitself = false;
	} else {
		boolitself = true;
	}
	
	var $divs = $("div.box");
	
	// Si value = 0 (le MainEvent), on retire tous les div :
	if (value == 0) {
		for(var i = 0; i < $divs.length; i++){
			valeur = $divs[i].getAttribute("value");
			if (valeur == 0) { // mainEvent : on ne l'enlève pas  
					continue ;
							}
			$divs[i].remove();
		}
		
		return null ;
	} // fin cas value = 0
	
	// cas ou value est positif : retirer tous ce qui est après
	if (value > 0) {
		for(var i = 0; i < $divs.length; i++){
			valeur = $divs[i].getAttribute("value");
			if (valeur > value) { 
			   $divs[i].remove();
			}
		}
		if (boolitself){
			$divs[value].remove()
		}
		return null ;
	} // fin cas value > 0
	
	if (value < 0) {
		for(var i = 0; i < $divs.length; i++){
			valeur = $divs[i].getAttribute("value");
			if (valeur < value) { 
			   $divs[i].remove();
			}
		}
		
		if (boolitself){
			$divs[value].remove()
		}
		return null ;
	} // fin cas value < 0
	});


Shiny.addCustomMessageHandler('remove_treebutton', function(message){
	value = parseInt(message.value); // value : numéro du div stocké dans l'attribut value du div
	var $divs = $("div.box");
	for(var i = 0; i < $divs.length; i++){
		valeur = $divs[i].getAttribute("value");
		if (valeur == value) { 
		   	$divs[i].remove();
		}
	}
});


Shiny.addCustomMessageHandler('hide_boutton', function(message){
	setTimeout(function(){
	document.getElementById(message.bouttonid).style.display = "none";
	
	// j'en profite pour renuméroter les events ici
	renumeroter_h4_treeboutton();
},100);
});


// $divs[0].children[0].textContent = "event-3"

/*
var $divs = $("div.box");
for(var i = 0; i < $divs.length; i++){
	valeur = $divs[i].getAttribute("value");
	if (valeur < value) { 
		$divs[i].remove();
	  }
}
$divs[0].children[0].textContent = "event-3"
*/



renumeroter_h4_treeboutton = function(){
/* Pb avec shiny : les id doivent être différents même si on remove l'element
 * ex : j'ai un treeboutton id="1", je l'enlève, je fais next event0, il me crée un treeboutton id="1", shiny n'aime pas
 * donc je vais éviter d'attribuer un id qui a déjà été attribué
 * Le pb pour l'utilisateur serait de voir : event0, event10 (s'il a supprimé tous les events entre 1 et 9 ; event 10 suit directement l'event 0)
 * Du coup j'utilise cette fonction javascript pour modifier h4 qui donne le numéro de l'event à l'utilisateur
 * Les events sont déjà ordonnés ; s'ils étaient tous > 0 ; il suffit de compter et d'attribuer l'index de l'élément
 * Comme ils existent des events négatifs, il suffit de faire : index-element - nombre d'éléments négatifs
 * */
 
 // On commence par identifer dans le DOM les éléments h4
var $divs = $("div.box");
var notes = [];
for(var y = 0; y < $divs.length; y++){
for (var i = 0; i < $divs[y].childNodes.length; i++) {
    if ($divs[y].childNodes[i].className == "h4-treeboutton") {
      notes.push($divs[y].childNodes[i]);
      break;
    }        
}
}

 // On compte combien ont un id négatif
var negatif = 0;
for(var i = 0; i < notes.length; i++){
	valeur = parseInt(notes[i].getAttribute("value"));
	if (valeur < 0) negatif += 1
}

// On renumérote
for(var i = 0; i < notes.length; i++){
	n = i - negatif ;
	notes[i].textContent = "event" + n ;
}
}



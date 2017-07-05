

/*
 * Le Tree est créé puis déplacer pour etre mis au bon endroit via cette function
 * */
Shiny.addCustomMessageHandler('moveTree', function(message){

/* pour retirer le contenu (le div) du tabset */
console.log("moveTree called");

setTimeout(function(){

console.log("\t A déplacer vers : " + message.divtargetname);
var divtarget = document.getElementById(message.divtargetname);

console.log("\t TreeBoutton à déplacer : " + message.treebouttonid);
var treeboutton = document.getElementById(message.treebouttonid);

if (message.boolprevious == null){
	console.log("\t ajout avant ");
	divtarget.appendChild(treeboutton);
} else {
	console.log("\t ajout après");
	divtarget.prepend(treeboutton);
}
//

}, 200);
});

/* L'objectif de la fonction remove_treebutton est de retirer tous les div "treebutton" qui précède ou qui suit un treebutton
 * Comme tous les évènements qui suivent ( ou précédent) un évènement sont dépendants de ce dernier, s'il change alors tous les autres doivent changer en cascade 
 * C'est pourquoi on les retire tous et l'utilisateur devra re-définir ce qu'il veut voir */
Shiny.addCustomMessageHandler('remove_treebutton', function(message){
	console.log("remove_treebutton appelé");
	value = parseInt(message.value); // value : numéro du div stocké dans l'attribut value du div
	if (message.itself == null){ // faut-il retirer aussi le div de l'évènement lui-meme : oui pour le boutton remove, non pour le boutton validate
		boolitself = false;
	} else {
		boolitself = true;
	}
	
	console.log("\t repère des classes div.box dans le DOM");
	var $divs = $("div.box");
	
	// Si value = 0 (le MainEvent), on retire tous les div :
	if (value == 0) {
		console.log("\t value 0 : tout retirer");
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
		console.log("\t retirer tout ce qu'il y a après " + value);
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
		console.log("\t retirer tout ce qu'il y a avant " + value);
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
	console.log("remove_treebutton appelé");
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
	console.log("hide_boutton appelé");
	setTimeout(function(){
	document.getElementById(message.bouttonid).style.display = "none";
	
	// j'en profite pour renuméroter les events ici
	renumeroter_h4_treeboutton();
},200);
});






renumeroter_h4_treeboutton = function(){
	
	console.log("renumeroter_h4_treeboutton appelé");
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






Shiny.addCustomMessageHandler('moveTree', function(message){
/* pour retirer le contenu (le div) du tabset */

setTimeout(function(){
var divtarget = document.getElementById(message.divtargetname);

var element = document.getElementById(message.elementname);
divtarget.appendChild(element);
}, 100);

// Afficher le tree
var bouttonafficher = document.getElementById(message.bouttonafficher);
bouttonafficher.click()

});	

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



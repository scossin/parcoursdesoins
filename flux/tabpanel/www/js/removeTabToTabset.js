/* pour retirer l onglet du tabset */
Shiny.addCustomMessageHandler('removeTabToTabset', function(message){
/* pour retirer le contenu (le div) du tabset */
$(message.tabsetid).remove();
/* pour retirer l'onglet du haut (li) */
$("a[href='"+message.tabsetid+"']").parent().remove();
/* pour retirer le bouton permet de retirer ces éléments au dessus */
$("#"+message.bouttonid).remove();
});

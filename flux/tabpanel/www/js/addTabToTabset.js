/* Fonction js permettant d'ajouter des tabsets
 * 
 * fichier source : 
 * https://stackoverflow.com/questions/35020810/dynamically-creating-tabs-with-plots-in-shiny-without-re-creating-existing-tabs/
 * 
 * */


/* In coherence with the original Shiny way, tab names are created with random numbers. 
                             To avoid duplicate IDs, we collect all generated IDs.  */
                             var hrefCollection = [];
                             
                             Shiny.addCustomMessageHandler('addTabToTabset', function(message){
                             var hrefCodes = [];
                             /* Getting the right tabsetPanel */
                             var tabsetTarget = document.getElementById(message.tabsetName);
                             
                             /* Iterating through all Panel elements */
                             for(var i = 0; i < message.titles.length; i++){
                             /* Creating 6-digit tab ID and check, whether it was already assigned. */

/* je ne comprends pas sa boucle do while inside for loop : je retire */ 
/* do {
hrefCodes[i] = Math.floor(Math.random()*100000);
} 
while(hrefCollection.indexOf(hrefCodes[i]) != -1); */

 /* je remplace l id par le titre au lieu d un nombre aleatoire (voir plus haut) */
                             hrefCodes[i] = message.titles[i];
                             hrefCollection = hrefCollection.concat(hrefCodes[i]);
                             
                             /* Creating node in the navigation bar */
                             var navNode = document.createElement('li');
                             var linkNode = document.createElement('a');
                             
                             linkNode.appendChild(document.createTextNode(message.titles[i]));
                             linkNode.setAttribute('data-toggle', 'tab');
                             linkNode.setAttribute('data-value', message.titles[i]);
                             linkNode.setAttribute('href', '#tab-' + hrefCodes[i]);
                             
                             navNode.appendChild(linkNode);
                             tabsetTarget.appendChild(navNode);
                             };
                             
                             /* Move the tabs content to where they are normally stored. Using timeout, because
                             it can take some 20-50 millis until the elements are created. */ 
                             setTimeout(function(){
                             var creationPool = document.getElementById('creationPool').childNodes;
                             var tabContainerTarget = document.getElementsByClassName('tab-content')[0];
                             
                             /* Again iterate through all Panels. */
                             for(var i = 0; i < creationPool.length; i++){
                             var tabContent = creationPool[i];
                             tabContent.setAttribute('id', 'tab-' + hrefCodes[i]);
                             
                             tabContainerTarget.appendChild(tabContent);
                             };
                             }, 100);
                             });





%%%%%%%%%%% Initialisation de psychtoolbox %%%%%%%%%%%%%%%%%%%%%
clear all; %Efface les variables de l'espace de travail
close all; %Ferme les figures et fenêtres octave en cours

participantID = input('Veuillez entrer vos initiales : ','s'); %Quelques demandes démographiques. le 's' indique que l'entrée est une chaîne de caractères
participantAge = input('Veuillez entrer votre age : ');
participantGender = input('Veuillez entrer votre sexe : ', 's');

%On utilise la fonction Screen('OpenWindow') pour fournir un fond aux stimuli
%Cette fonction renvoie deux variables, que l'on nomme ici w1 et rect
%w1 : nombre associé à la fenêtre
%rect : coordonnées de la fenêtre
[w1,rect] = Screen('OpenWindow',0,0);

%On détermine les coordonnées x(center(1)) et y(center(2)) du centre de l'écran
%Pour ça, appel à la fonction RectCenter qui prend comme argument la variable contenant les coordonnées de l'écran
%Ces coordonnées ont été calculées par la fonction Screen à la ligne précédente.
[center(1), center(2)] = RectCenter(rect);

%On indique à Octave que la fenêtre de l'expérience (stockée dans w1) est prioritaire, elle sera toujours au premier plan)
Priority(MaxPriority(w1));
%HideCursor %Cache le curseur sur la fenêtre


%%%%%%%%%%% Variables de l'expérience %%%%%%%%%%%%%%%%%%%%%%
nTrials = 10; %nombre d'essais
numbergo = 5; %nombre d'essais go

%Utilisation de la fonction zeros pour générer un array qui ne contient que des 0. Le premier argument est le nombre de ligne, le second le nombre de colonnes
%Ici, on crée des variables qui vont contenir des données pour chaque essai
%il y a autant de lignes que d'essais (nTrials) et une seule colonne.
buttonpressed = zeros(nTrials,1); %Enregistre si un bouton est appuyé. 1 si une réponse est donnée, 0 sinon.
targettime = zeros(nTrials,1); %Temps pendant lequel la cible était affichée
responsetime = zeros(nTrials,1); %TR. A 0 si essai nogo
%On définit maintenant les conditions, si un essai donné est go ou nogo.
%Essais go noté 1, essais nogo noté 2
%Utilisation de la fonction repmat, qui répète un certain nombre de fois une variable ou un array
%Trois arguments à repmat: la valeur à répéter (ici 1 ou 2), le nombre de lignes à répéter, le nombre de colonnes à répéterminal_size
%La fonction suivante va générer un array à deux parties, une avec que des 1 et une autre avec que des 2. Le nombre de colonnes est le nombre d'essais
conditions = [repmat(1,1,numbergo),repmat(2,1,nTrials-numbergo)];
%Utilisation de la fonction rng pour grainer la randomisation (apparemment pas nécessaire dans octave)
rng('shuffle');
%On randomise l'ordre de présentation des stimuli
conditionsrand = conditions(randperm(length(conditions)));

%On génère l'affichage d'un texte en mémoire. Plusieurs entrées: l'indice de la fenêtre (w1), le texte, les coordonnées où afficher le texte, la couleur du texte)
Screen('DrawText',w1,'Appuyez sur une touche pour commencer',center(1)-200,center(2)-10,255);
%On demande l'affichage du texte
Screen('Flip',w1);
%On met en pause dans l'attente de l'entrée d'une commande de la part de l'utilisateur
pause;
%On n'a rien mis en mémoire avec une fonction Screen. Donc en faisant appel à screen('flip'), écran vierge
Screen('Flip',w1);
%On définit le temps d'attente (en secondes) sur cet écran
WaitSecs(1);

circlesize = rect(3)/100; %D�finit le rayon du cercle. 1/100 de la largeur de l'�cran (en pixels)
circlecoordinates = [center(1)-circlesize,center(2)-circlesize,center(1)+circlesize,center(2)+circlesize]; %Définition des coordonnées du cercle

for trialcount = 1:nTrials %Génération des essais par une boucle    
    if conditionsrand(trialcount) == 1
        Screen('FillOval',w1, [0 255 0], circlecoordinates);
    elseif conditionsrand(trialcount) == 2
        Screen('FillOval',w1, [255 0 0], circlecoordinates);
    end;
  
  Screen('Flip',w1); %Affichage du cercle
  targettime(trialcount) = GetSecs; %Récupération du temps en secondes auquel le stimulus est affiché à la case du numéro de l'essai dans la variable targettime, qui est un array
 
  tic; %Fonction de démarrage du chronométrage
  while toc < 1.5 %Détection de l'appui, tant que 1.5sec ne s'est pas écoulée
    [~,keysecs,keyCode] = KbCheck; %KbCheck vérifie quelle touche est appuyée et la renvoie. On y affecte trois sorties. Le ~ désigne toute sortie inattendue (1 s'il y a eu appui, 0 sinon), keysecs est le temps auquel l'appui sur la touche a été effectué, keyCode est un array, contenant autant de cases que de touches sur le clavier. 1 si la touche a été appuyée, 0 sinon. 
    if keyCode(KbName('space')) == 1
      responsetime(trialcount) = keysecs;
      buttonpressed(trialcount) = 1;
    end;
  end;
  Screen('flip',w1); %On affiche un écran vierge. Il est vierge car on n'a pas défini le dessin d'un stimulus
   
  [~,~,keyCode] = KbCheck; %Code pour vérifier si la touche q est appuyée. Si c'est le cas, on termine la boucle for et cela termine l'expérience
  if keyCode(KbName('q')) == 1
    break
  end;
 
  jitterinterval = 1 + (3-1).*rand; %Code pour définir un ITI, ici il sera entre 1 et 3 sec
  WaitSecs(jitterinterval);
end;

save(sprintf('%s_data_%dGo',participantID,numbergo));

%%%%%%%%%%% Fermeture de psychtoolbox %%%%%%%%%%%%%%%%%%%%%
Screen('Close',w1); %On ferme la fenêtre de l'expérience
Priority(0); %La fenêtre perd la priorité d'affichage
ShowCursor(); %On redonne accès au curseur
%%%%%%%%%%% Initialisation de psychtoolbox %%%%%%%%%%%%%%%%%%%%%
clear all; %Efface les variables de l'espace de travail
close all; %Ferme les figures et fenetres octave en cours

participantID = input('Veuillez entrer vos initiales : ','s'); %Quelques demandes demographiques. le 's' indique que l'entree est une chaine de caracteres
participantAge = input('Veuillez entrer votre age : ');
participantGender = input('Veuillez entrer votre sexe : ', 's');

%On utilise la fonction Screen('OpenWindow') pour fournir un fond aux stimuli
%Cette fonction renvoie deux variables, que l'on nomme ici w1 et rect
%w1 : nombre associe a† la fenetre
%rect : coordonnees de la fenetre
[w1,rect] = Screen('OpenWindow',0,0);

%On determine les coordonnees x(center(1)) et y(center(2)) du centre de l'ecran
%Pour ca, appel a†la fonction RectCenter qui prend comme argument la variable contenant les coordonnees de l'ecran
%Ces coordonnees ont ete calculees par la fonction Screen a la ligne precedente.
[center(1), center(2)] = RectCenter(rect);

%On indique que la fenetre de l'experience (stockee dans w1) est prioritaire, elle sera toujours au premier plan)
Priority(MaxPriority(w1));
%HideCursor %Cache le curseur sur la fenetre


%%%%%%%%%%% Variables de l'experience %%%%%%%%%%%%%%%%%%%%%%
nTrials = 10; %nombre d'essais
numbergo = 5; %nombre d'essais go

%Utilisation de la fonction zeros pour generer un array qui ne contient que des 0. Le premier argument est le nombre de ligne, le second le nombre de colonnes
%Ici, on cr√©e des variables qui vont contenir des donnees pour chaque essai
%il y a autant de lignes que d'essais (nTrials) et une seule colonne.
buttonpressed = zeros(nTrials,1); %Enregistre si un bouton est appuye. 1 si une reponse est donnee, 0 sinon.
targettime = zeros(nTrials,1); %Temps pendant lequel la cible etait affichee
responsetime = zeros(nTrials,1); %TR. A 0 si essai nogo
%On definit maintenant les conditions, si un essai donne est go ou nogo.
%Essais go note 1, essais nogo note 2
%Utilisation de la fonction repmat, qui repete un certain nombre de fois une variable ou un array
%Trois arguments a repmat: la valeur a repeter (ici 1 ou 2), le nombre de lignes a repeter, le nombre de colonnes a†repeterminal_size
%La fonction suivante va generer un array a†deux parties, une avec que des 1 et une autre avec que des 2. Le nombre de colonnes est le nombre d'essais
conditions = [repmat(1,1,numbergo),repmat(2,1,nTrials-numbergo)];
%Utilisation de la fonction rng pour grainer la randomisation (apparemment pas necessaire dans octave)
rng('shuffle');
%On randomise l'ordre de pr√©sentation des stimuli
conditionsrand = conditions(randperm(length(conditions)));

%On genere l'affichage d'un texte en memoire. Plusieurs entrees: l'indice de la fenetre (w1), le texte, les coordonnees ou afficher le texte, la couleur du texte)
Screen('DrawText',w1,'Appuyez sur une touche pour commencer',center(1)-200,center(2)-10,255);
%On demande l'affichage du texte
Screen('Flip',w1);
%On met en pause dans l'attente de l'entr√©e d'une commande de la part de l'utilisateur
pause;
%On n'a rien mis en memoire avec une fonction Screen. Donc en faisant appel a screen('flip'), ecran vierge
Screen('Flip',w1);
%On definit le temps d'attente (en secondes) sur cet ecran
WaitSecs(1);

circlesize = rect(3)/100; %DÈfinit le rayon du cercle. 1/100 de la largeur de l'Ècran (en pixels)
circlecoordinates = [center(1)-circlesize,center(2)-circlesize,center(1)+circlesize,center(2)+circlesize]; %Definition des coordonnees du cercle

for trialcount = 1:nTrials %Generation des essais par une boucle    
    if conditionsrand(trialcount) == 1
        Screen('FillOval',w1, [0 255 0], circlecoordinates);
    elseif conditionsrand(trialcount) == 2
        Screen('FillOval',w1, [255 0 0], circlecoordinates);
    end;
  
  Screen('Flip',w1); %Affichage du cercle
  targettime(trialcount) = GetSecs; %Recuperation du temps en secondes auquel le stimulus est affiche a la case du numero de l'essai dans la variable targettime, qui est un array
 
  tic; %Fonction de demarrage du chronometrage
  while toc < 1.5 %Detection de l'appui, tant que 1.5sec ne s'est pas ecoulee
    [~,keysecs,keyCode] = KbCheck; %KbCheck verifie quelle touche est appuyee et la renvoie. On y affecte trois sorties. Le ~ designe toute sortie inattendue (1 s'il y a eu appui, 0 sinon), keysecs est le temps auquel l'appui sur la touche a ete effectue, keyCode est un array, contenant autant de cases que de touches sur le clavier. 1 si la touche a ete appuyee, 0 sinon. 
    if keyCode(KbName('space')) == 1
      responsetime(trialcount) = keysecs;
      buttonpressed(trialcount) = 1;
    end;
  end;
  Screen('flip',w1); %On affiche un ecran vierge. Il est vierge car on n'a pas defini le dessin d'un stimulus
   
  [~,~,keyCode] = KbCheck; %Code pour verifier si la touche q est appuyee. Si c'est le cas, on termine la boucle for et cela termine l'experience
  if keyCode(KbName('q')) == 1
    break
  end;
 
  jitterinterval = 1 + (3-1).*rand; %Code pour d√©finir un ITI, ici il sera entre 1 et 3 sec
  WaitSecs(jitterinterval);
end;

save(sprintf('%s_data_%dGo',participantID,numbergo));

%%%%%%%%%%% Fermeture de psychtoolbox %%%%%%%%%%%%%%%%%%%%%
Screen('Close',w1); %On ferme la fenetre de l'experience
Priority(0); %La fenetre perd la priorite d'affichage
ShowCursor(); %On redonne acces au curseur
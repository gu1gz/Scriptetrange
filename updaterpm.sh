#!/bin/bash
if [ $(id -u) -ne 0 ]; then echo "Tu n'es pas log en Root, Tu ne peux pas lancer le script"
else  echo  "Bienvenue sur le script !!!"
  echo "Voulez-vous ajouter un repository avant de vouloir rechercher votre package ? [Y/N]"
  read inputchoice1
  if  [ "$inputchoice1" = "Y" ]
   then echo "Entre le lien :"
    read repo
      $(yum install $repo)
  else
  testepelpackage=$(rpm -qa epel-release | wc -c)
  if  [ "$testepelpackage" = "0" ] # si le nombre de caractere du package est égal à 0 il n'existe pas
    then echo "Vous devez installer EPEL (Extra Package For Enterprise Linux) avant d'utiliser le script [Y/N]"
         read firstinputchoice
         if  [ "$firstinputchoice" = "Y" ]
          then $(yum install epel-release)
         else
           echo "Script Terminé"
           exit 1
         fi
  else
    echo "Quel paquet veux-tu installer ?"
    read packageainstaller #on demande le paquet à installer
    testpackage=$(rpm -qa $packageainstaller | wc -c) # on recupere le nombre de caractere du paquet // J'utilise -qa car si le paquet n'est pas présent cela ne renvoie rien et c'est plus simple à traiter
    if  [ "$testpackage" = "0" ] # si le nombre de caractere du package est égal à 0 il n'existe pas
      then echo "Il n'y a pas ce package sur votre système"
        $(yum list available $packageainstaller 1> rpmpackagefile 2> packagefileerror )
        packageerr=$(cat packagefileerror | grep -o "Aucun")
        if [ "$packageerr" = "Aucun" ];then echo "Le package que vous recherchez n'existe pas"
        else
            echo "Le package existe. Voulez-vous le dl ? [Y/N]"
            read inputchoice
            if [ "$inputchoice" = "Y" ]
              then  $(yum install $packageainstaller)
            else
              echo "Script Terminé"
            fi
        fi
    else
      $(rpm -qa $packageainstaller > rpmversion)
      versionrpm=$(cat rpmversion)
      $(yum info $packageainstaller > yumresult)
      $(grep -e Nom -e Architecture -e Version -e Révision  yumresult  | cut -d':' -f2 > yumrepoversion)
      yumname=$(sed -n '1p' yumrepoversion)
      yumarch=$(sed -n '2p' yumrepoversion)
      yumversion=$(sed -n '3p' yumrepoversion)
      yumrevision=$(sed -n '4p' yumrepoversion)
      yumtpackage="$yumname-$yumversion-${yumrevision}.${yumarch}"
      yumtestpackage="$(echo -e "${yumtpackage}" | tr -d '[:space:]')"
      if [ "$versionrpm" = "$yumtestpackage" ]
          then echo "Le paquet $(rpm -qa $packageainstaller) est present et est à jour sur le système" #On va chercher le nom complet du package deja installer
      else
        $(yum install $packageainstaller)
      fi
    fi
  fi
fi
fi

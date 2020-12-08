#! /bin/bash
#
# Meno: Martin Svab
# Kruzok: Piatok - 10:00
# Datum: 7.12.2020
# Zadanie: zadanie03
#
# Text zadania:
#
# Vypiste vsetkych pouzivatelov, ktori neboli za poslednu dobu (odkedy system
# zaznamenava tieto informacie) prihlaseni. Ignorujte pouzivatelov, ktori
# nemaju povolene prihlasovanie.
# Ak bude skript spusteny s prepinacom -g <group>, vypise len pouzivatelov,
# ktori neboli za poslednu dobu prihlaseni a patria do skupiny <group>, ktora
# je zadana ako cislo.
# Pomocka: pouzite prikaz last a informacie zo suborov
# /public/samples/wtmp.2020 /public/samples/passwd.2020.
#
# Syntax:
# zadanie.sh [-h] [-g <group>]
#
# Format vypisu bude nasledovny:
# Output: '<login_name> <group>'
#
# Priklad vystupu:
# Output: 'cernicka 520'
# Output: 'chudik 520'
#
#
# Program musi osetrovat pocet a spravnost argumentov. Program musi mat help,
# ktory sa vypise pri zadani argumentu -h a ma tvar:
# Meno programu (C) meno autora
#
# Usage: <meno_programu> <arg1> <arg2> ...
#    <arg1>: xxxxxx
#    <arg2>: yyyyy
#
# Parametre uvedene v <> treba nahradit skutocnymi hodnotami.
# Ked ma skript prehladavat adresare, tak vzdy treba prehladat vsetky zadane
# adresare a vsetky ich podadresare do hlbky.
# Pri hladani maxim alebo minim treba vzdy najst maximum (minimum) vo vsetkych
# zadanych adresaroch (suboroch) spolu. Ked viacero suborov (adresarov, ...)
# splna maximum (minimum), treba vypisat vsetky.
#
# Korektny vystup programu musi ist na standardny vystup (stdout).
# Chybovy vystup programu by mal ist na chybovy vystup (stderr).
# Chybovy vystup musi mat tvar (vratane apostrofov):
# Error: 'adresar, subor, ... pri ktorom nastala chyba': popis chyby ...
# Ak program pouziva nejake pomocne vypisy, musia mat tvar:
# Debug: vypis ...
#
# Poznamky: (sem vlozte pripadne poznamky k vypracovanemu zadaniu)
#
# Riesenie:

print_help () {
	echo "z3.sh (C) Martin Svab"
	echo
	echo "Usage: z3.sh [-h] [-g <group>]"
	echo "-h: show help"
	echo "-g <group>: output will only display users from the corresponding group (<group> must be a number)"
}

output_group_login () {
	passwd_file="/public/samples/passwd.2020"
	wtmp_file="/public/samples/wtmp.2020"
	
	# check if sample passwd file exists
	if [[ ! -f ${passwd_file} ]]
	then
		echo "Error: '/public/samples/passwd.2020': File does not exist." >&2
		exit
	fi
	
	# check if sample wtmp file exists
        if [[ ! -f ${wtmp_file} ]]
	then
		echo "Error: '/public/samples/passwd.2020': File does not exist." >&2
		exit
	fi
	
	# list of existing users that can log in
	# each user contains their name and gid
	existing_users=$(cat ${passwd_file} | grep -E /bin/bash | cut -d: -f1,4)
	
	# list of users that logged in
	# each user contains their name
	logged_users=$(last -f ${wtmp_file} | awk '{print $1}' | sort | uniq)
	
	for existing_user in ${existing_users}
	do
		user_name=$(echo $existing_user | cut -d: -f1)
		user_gid=$(echo $existing_user | cut -d: -f2)
		
		# check if picked existing user was logged in
		user_valid=true
		for logged_user in ${logged_users}
		do
			if [[ ${logged_user} == ${user_name} ]]
			then	
				user_valid=false
				break
			fi
		done

		if [[ ${user_valid} == true ]]
		then
			if [[ $# -eq 0 || $# -eq 1 && $1 == ${user_gid} ]]
			then
				echo "Output: '${user_name} ${user_gid}'"
			fi
		fi
	done
}

# i have no arguments
if [[ $# -eq 0 ]]
then
	# standard output
	output_group_login
# i have 1 argument - it should contain "-h" argument
elif [[ $# -eq 1 ]]
then	
	# first argument is -h
	if [[ $1 == "-h" ]]
	then
		# print help
		print_help
	# first argument is -g
	elif [[ $1 == "-g" ]]
	then
		echo "Error: '<group>': Argument -g is missing subsequent <group> argument." >&2
	# first argument is invalid
	else
		echo "Error: '$1': Invalid argument." >&2
	fi
# i have 2 arguments - it should contain "-g <group>" arguments
elif [[ $# -eq 2 ]]
then
	# first argument is -g
	if [[ $1 == "-g" ]]
	then
		# second argument is a number
		if echo $2 | grep -qE '^[0-9]+$'
		then
			# groups output
			output_group_login "$2"
		# second argument is invalid
		else
			echo "Error: '$2': <group> argument must be a number." >&2
		fi
	# first argument is -h
	elif [[ $1 == "-h" ]]
	then
		echo "Error: '$2': Argument -h cannot have any subsequent arguments." >&2
	# first argument is invalid
	else
		echo "Error: '$1': Invalid argument." >&2		
	fi
# i have incorrect amount of arguments
else
	echo "Error: '... <arg3> ...': Incorrect amount of arguments was passed to script." >&2
fi

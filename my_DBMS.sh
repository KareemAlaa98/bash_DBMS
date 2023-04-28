#!/bin/bash

####### Validation regex ###########
namereg='^[a-zA-Z][a-zA-Z_]+$'
numreg='^[1-9][0-9]*$'
typereg='^[0-1]$'
data_to_insert_reg='^[0-9a-zA-Z][0-9a-zA-Z.@_]*$'
fieldreg='^[a-zA-Z][a-zA-Z.@_]+$'
fieldnumreg='^[0-9][0-9]*$'

############### Script ##################
# check if the container database dir exists AND show main menu
if [ ! -d $HOME/database ]; then
    mkdir $HOME/database
fi

select option in "Create database" "List database" "Connect to database" "Drop database" "exit"; do
    case $REPLY in

    ### Option 1: Create database ###
    1)
        echo "Enter a database name without number, special characters(except _ ) or spaces or enter exit to return to main menu"
        while true; do
            read dbname
            if [[ ! $dbname =~ $namereg ]]; then
                echo "Enter a database name without numbers, special characters or spaces example: mydatabase, my_database"
                continue
            elif [[ -d $HOME/database/$dbname ]]; then
                echo " Database already exists"
            elif [[ $dbname = "exit" ]]; then
                break
            else
                mkdir $HOME/database/$dbname
                echo "your $dbname database has been created, what else to do?"
                break
            fi
        done
        ;;

    ### Option 2: List database ###
    2)
        ls $HOME/database
        ;;

    ### Option 3: Connect to database ###
    3)
        echo "enter database name to connect to, or enter exit to return to main menu"
        while true; do
            read connectdb
            if [[ ! $connectdb =~ $namereg ]]; then
                echo "Enter a database name without numbers, special characters or spaces"
                continue
            elif [[ ! -d $HOME/database/$connectdb ]]; then
                echo "database doesn't exist, enter a valid DB name"

            elif [[ $connectdb = "exit" ]]; then
                break
            else
            
                ### Table options and settings ###
                select choice in "Create table" "List tables" "Drop table" "Insert into table" "Select from table" "Delete from table" "Update table" "Exit"; do
                    case $REPLY in

                    1) ### Table Option 1: Create table ###
                        echo "Enter a table name without numbers, special characters(except _ ) or spaces or enter exit to return to main menu"
                        while true; do
                            read tblname
                            if [[ ! $tblname =~ $namereg ]]; then
                                echo "Enter a table name without numbers, special characters(except _ ) or spaces"
                                continue
                            elif [[ -f $HOME/database/$connectdb/$tblname ]]; then
                                echo "table name alreay exists, enter a new name"
                            elif [[ $tblname = "exit" ]]; then
                                break
                            else
                                rm -r $HOME/database/tmp 2>/dev/null
                                mkdir $HOME/database/tmp
                                while true; do
                                    echo "enter number of columns"
                                    read num_of_columns
                                    if [[ ! $num_of_columns =~ $numreg ]]; then
                                        echo "invalid number"
                                        continue
                                    else
                                        x=1
                                        while [ $x -le $num_of_columns ]; do
                                            if [[ $x -eq 1 ]]; then
                                                echo "Enter column 1 name => NOTE: that column 1 will be primary key"
                                            else
                                                echo "enter column $x name without numbers or special char or space"
                                            fi

                                            read colname
                                            if [[ ! $colname =~ $namereg ]]; then
                                                echo "enter column name without numbers or special char or space"
                                                continue
                                            else
                                                if [[ ! -f $HOME/database/tmp/$colname ]]; then
                                                    touch $HOME/database/tmp/$colname
                                                else
                                                    echo "Column name already exists please choose another name"
                                                    continue
                                                fi

                                                while true; do
                                                    echo "Enter column $x Type => NOTE: choose 0 for String or 1 for Integer"
                                                    read coltype
                                                    if [[ ! $coltype =~ $typereg ]]; then
                                                        echo "-----Wrong input, enter 0 for string or 1 for integer-----"
                                                        continue
                                                    else
                                                        break
                                                    fi
                                                done
                                                if [ $x -eq 1 ]; then
                                                    c_type="$coltype"
                                                    c_name="$colname"
                                                    let x=$x+1
                                                else
                                                    c_type="$c_type:$coltype"
                                                    c_name="$c_name:$colname"
                                                    let x=$x+1
                                                fi
                                            fi

                                        done
                                        touch $HOME/database/$connectdb/$tblname
                                        rm -r $HOME/database/tmp
                                        echo $c_type >>$HOME/database/$connectdb/$tblname
                                        echo $c_name >>$HOME/database/$connectdb/$tblname
                                        echo "Table Has Been Created"
                                        break 2
                                    fi
                                done
                            fi
                        done
                        
                        ;;



 			
 			2) ### Table Option 2: List tables ###
 			
                    	ls $HOME/database/$connectdb
 			;;
 			
 			
 			3) ### Table Option 3: Drop table ###
 			ls $HOME/database/$connectdb
    			echo "Table name to drop: "
    			read tablename
    			if [ -f $HOME/database/$connectdb/$tablename ]
    			then
        			rm $HOME/database/$connectdb/$tablename 
        			echo "Table $tablename is dropped successfully"
    			else
        		echo "Table doesn't exist"
    			fi	
 			;;
                    4) ### Table Option 4: Insert into table ###
                        ######### Validate inserted data type function ############
                        matchdatatype() {
                            #arg1 => colnumber, arg2 => inserted data, arg3 => database name, arg4 => table name
                            arg1=$1
                            arg2=$2
                            arg3=$3
                            arg4=$4
                            colty=$(awk -F: -v input=$arg1 'NR==1{print $input}' $HOME/database/$arg3/$arg4)
                            echo ""
                            if [[ $colty -eq 0 ]]; then
                                if [[ ! $arg2 =~ $fieldreg ]]; then
                                    echo "----enter a valid datatype (string)----"
                                else
                                    echo "correct_data_type"
                                fi
                            else
                                if [[ ! $arg2 =~ $fieldnumreg ]]; then
                                    echo "-----enter a valid datatype (number)--------"
                                else
                                    echo "correct_data_type"
                                fi
                            fi
                        }

                        ## Choosing the table to insert into ##
                        echo "Enter the table name you want to insert data into without nums, spaces or special chars"
                        while true; do
                            read tbl_to_insert_into
                            if [[ ! $tbl_to_insert_into =~ $namereg ]]; then
                                echo "Enter table name without numbers or special char or space"
                                continue
                            elif [[ $tbl_to_insert_into = "exit" ]]; then
                                break
                            elif [[ ! -f $HOME/database/$connectdb/$tbl_to_insert_into ]]; then
                                echo "Table doesn't exists enter another table name or exit"
                                continue
                            else
                                ## capturing the table head
                                tbl_head=$(awk -F: 'NR==2{print $0}' $HOME/database/$connectdb/$tbl_to_insert_into)
                                ## getting he number of fields
                                num_of_fields=$(awk -F: 'NR==2{print NF}' $HOME/database/$connectdb/$tbl_to_insert_into)

                                y=1 #=>col_num
                                datatosave=""
                                while [ $y -le $num_of_fields ]; do
                                    echo $tbl_head
                                    echo "Enter data that will be inserted in column number $y "

                                    read data_to_insert
                                    if [[ ! $data_to_insert =~ $data_to_insert_reg ]]; then
                                        if [[ $data_to_insert = "" ]]; then
                                            echo "Invalid input"
                                            continue
                                        fi
                                    else
                                        result=$(matchdatatype $y $data_to_insert $connectdb $tbl_to_insert_into)
                                        if [ $result == "correct_data_type" ]; then
                                            # Check if Primary key is Unique
                                            if [ $y -eq 1 ]; then
                                                isnotunique=$(awk -F: -v pk=$data_to_insert 'NR>2{ if($1==pk) print "exists"}' $HOME/database/$connectdb/$tbl_to_insert_into)
                                                if [[ $isnotunique = "exists" ]]; then
                                                    echo "Error primary key should be Unique "
                                                    continue
                                                else
                                                    data_to_save=$data_to_insert
                                                    let y=$y+1
                                                fi

                                            else
                                                data_to_save="$data_to_save:$data_to_insert"
                                                let y=$y+1
                                            fi
                                        else
                                            echo $result
                                            continue
                                        fi
                                    fi
                                done
                                echo $data_to_save >>$HOME/database/$connectdb/$tbl_to_insert_into
                                echo "Data inserted successfully"
                                break
                            fi
                        done
                        ;;

                    5) ### Table Option 5: Select from table ###
                        echo "Enter Table's name without numbers or special char or space OR exit"
                        while true; do
                            read selected_tbl_name
                            if [[ ! $selected_tbl_name =~ $namereg ]]; then
                                echo "Invalid, enter a name without numbers or special char or space"
                                continue
                            elif [[ $selected_tbl_name = "exit" ]]; then
                                break
                            elif [ -f "$HOME/database/$connectdb/$selected_tbl_name" ]; then
                                select choice in "Select the entire table" "Select by Primary Key Value" "Back to table menu"; do
                                    case $REPLY in

                                    1) ## selecting the entire table ##
                                        echo "This is the full table"
                                        awk -F: 'NR>1{ print $0 }' $HOME/database/$connectdb/$selected_tbl_name
                                        ;;

                                    2) ## selecting by primary key Value ##
                                        echo "Enter Primary Key"
                                        while true; do
                                            read primary_key
                                            selectedline=$(awk -F: -v pk=$primary_key 'NR>2{ if($1==pk) print $0}' $HOME/database/$connectdb/$selected_tbl_name)
                                            if [ $selectedline ]; then
                                                echo "Here is the record you selected record"
                                                echo $selectedline
                                                break
                                            else
                                                echo "Primary Key doesn't exist, enter primary key again"
                                                continue
                                            fi
                                        done
                                        ;;

                                    3) ## Back to table menu ##
                                        break 2 ;;
                                    *) echo "Invalid option" ;;
                                    esac
                                    REPLY=
                                done

                            else
                                echo " Table name doesn't exist, enter table name OR exit"
                                continue
                            fi
                        done
                        ;;
			6) ### Table Option 6: Delete from table ###
                    	echo "Enter the table name to delete from: "
    			read tablename

    			if [ -f $HOME/database/$connectdb/$tablename ]
    			then
        			echo "Enter the primary key value of the record you want to delete:"
        			read primaryKey

        		if [ ! -z $primaryKey ]
        		then
				echo "`awk 'BEGIN{FS=":"} {print $1}' "$HOME/database/$connectdb/$tablename" | grep "\b$primaryKey\b"`"
            			if [[ $primaryKey = "`awk 'BEGIN{FS=":"} {print $1}' "$HOME/database/$connectdb/$tablename" | grep "\b$primaryKey\b"`" ]]
            			then
                			NR=`awk 'BEGIN{FS="|"}{if ($1=="'$primaryKey'") print NR}' "$HOME/database/$connectdb/$tablename"`
                			sed -i ''$NR'd' "$HOME/database/$connectdb/$tablename"
                			echo "Record deleted successfully"
            			else
                			echo "Primary key not exist!"
            			fi
        		else
            			echo "Primary key not inserted!"
        		fi    
    			else
        			echo "Table $HOME/database/$connectdb/$tablename doesn't exist!"
    			fi
    			;;
                    7) ### Table Option 7: Update table ###
			echo "Enter the table name to edit: "
    			read tablename
    	
    			if [ -f $HOME/database/$connectdb/$tablename ];
    			then
				echo "Columns : `awk -F':' '{if(NR==2){print $0}}' "$HOME/database/$connectdb/$tablename"`";
				echo "Choose target column of where condition: "
				read conditionCol;
				conditionNF=$(awk 'BEGIN{FS=":"}{if(NR==2){for(i=1;i<=NF;i++){if($i=="'$conditionCol'") print i}}}' "$HOME/database/$connectdb/$tablename")
				echo "$HOME/database/$connectdb/$tablename"
				if [[ $conditionNF == "" ]]
  				then
    					echo "Field not found!"

  				else
					echo "Enter the target value: "
					read conditionVal;
					valExist=$(awk 'BEGIN{FS=":"}{if ($'$conditionNF'=="'$conditionVal'") print $'$conditionNF'}' "$HOME/database/$connectdb/$tablename" )
    					if [[ $valExist == "" ]]
    					then
      						echo "Value not found!"
    					else
						echo "Enter the column to be updated: "
						read updatedcol;
	      					updateNF=$(awk 'BEGIN{FS=":"}{if(NR==2){for(i=1;i<=NF;i++){if($i=="'$updatedcol'") print i}}}' "$HOME/database/$connectdb/$tablename" )
	      					if [[ $updateNF == "" ]]
      						then
        						echo "Field not found!"

      						else
							echo "Enter the new value to be updated: "
							read newValue;
							NR=$(awk 'BEGIN{FS=":"}{if ($'$conditionNF' == "'$conditionVal'") print NR}' "$HOME/database/$connectdb/$tablename" ) 
        						oldValue=$(awk 'BEGIN{FS=":"}{if(NR=='$NR'){for(i=1;i<=NF;i++){if(i=='$updateNF') print $i}}}' "$HOME/database/$connectdb/$tablename" )
        						sed -i ''$NR's/'$oldValue'/'$newValue'/g' "$HOME/database/$connectdb/$tablename"
							echo "Row Updated Successfully"
						fi
					fi
				fi
			else
				echo "$HOME/database/$connectdb/$tablename doesn't exist";
			fi
			;;

                    ### Table Option 8: Exit ###
                    8)
                        exit
                        ;;

                    *) echo "Enter a valid option" ;;
                    esac
                    REPLY=
                done
            fi
        done
        ;;

    #### DELETE Database ###
    4)
        echo "Enter a database name to delete, or enter exit to return to main menu"
        while true; do
            read deletedb
            if [[ ! $deletedb =~ $namereg ]]; then
                echo "Enter a database name without numbers, special characters or spaces example: mydatabase, my_database"
                continue
            elif [ ! -d "$HOME/database/$deletedb" ]; then
                echo "Database doesn't exist! enter another database name, or exit to return to main menu"
            elif [[ $deletebd = "exit" ]]; then
                break
            else
                rm -r $HOME/database/$deletedb
                echo "$deletedb database has been deleted"
                break
            fi
        done
        ;;

    ## Option 5: exit
    5) exit ;;

    *) echo " Enter a valid option" ;;
    esac
    REPLY=
done

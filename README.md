# Comprehensive TCL Workshop: From Introduction to Advanced Scripting Techniques in Design and Synthesis
--------------------------------------------------------------------------------------------------------
## Introduction
Tool Command Language (Tcl) is a scripting language commonly used in various domains, including software development, system administration, and electronic design automation (EDA). Tcl is known for its simplicity, flexibility, and ease of integration with other programming languages and tools. Tcl scripting involves writing scripts in the Tcl language to automate tasks, execute commands, and manipulate data.

links for easy navigation:
1. [DAY-1](https://github.com/Visruat/VSD-TCL/blob/main/README.md#day-1)
2. [DAY-2](https://github.com/Visruat/VSD-TCL/blob/main/README.md#day-2)
3. [DAY-3](https://github.com/Visruat/VSD-TCL/blob/main/README.md#day-3) 


## DAY-1

__Create Command (panda) and pass csv file from UNIC shell to Tcl script__

The command was created with the following algorithm:
1) letting the system know that its a UNIX script

```
#!/bin/tcsh -f  
```

2) Creating the logo

```
echo " *********        ****       ***      **     ****         ****                "
echo " **     **       **  **      ****     **     ** **       **  **               "
echo " **     **      **    **     ** **    **     **  **     **    **              " 
echo " *********     **      **    **  **   **     **   **   **      **             " 
echo " **            **********    **   **  **     **  **    **********             "
echo " **            **      **    **    ** **     ** **     **      **             "
echo " **            **      **    **     ****     ****      **      **             "
echo 
echo " a tcl command created by VISRUAT T R (its pronounced as Vishruth)            "
```

3) verifying three general scenarios for a user POV
  - user doesnt enter the csv file

![Screenshot from 2023-06-15 11-23-50](https://github.com/Visruat/VSD-TCL/assets/125136551/6503b789-2fbe-461e-9f81-99a4e564f794)


  - user enters the wrong csv file/ file doesnt exist


![Screenshot from 2023-06-15 11-35-33](https://github.com/Visruat/VSD-TCL/assets/125136551/53b2f085-f63a-4b68-9c16-5e56df8e23de)

  - user enters __-help__

![Screenshot from 2023-06-15 11-37-11](https://github.com/Visruat/VSD-TCL/assets/125136551/68c64691-8eef-47df-918f-241469033199)


4) source the Unix shell to the Tcl script by passing the required csv file 

```
tclsh pandabro.tcl $argv[1] 
```
Note : Make sure the file is executable by using the command ``` chmod -R 777 panda ``` 

## DAY-2
__Converting inputs to format[1] and feeding it to yosys for synthesis__

  __- Create Variables__

![Screenshot from 2023-06-15 15-11-10](https://github.com/Visruat/VSD-TCL/assets/125136551/1a039045-a2f5-4bc9-84c5-14f170450bd8)

  __- Checking if the directories exist or not ( done to prevent the script from breaking )__

![Screenshot from 2023-06-15 15-29-57](https://github.com/Visruat/VSD-TCL/assets/125136551/17c7398b-593d-40f9-a267-35bc6e7afc9a)

Displays an error when the required file is not in the needed directory

![Screenshot from 2023-06-15 16-50-05](https://github.com/Visruat/VSD-TCL/assets/125136551/a82bf99c-b7bf-4288-b77a-5766d2ac8112)


## DAY-3

__Read Constraints.csv file and convert to sdc format__
  
  - noting down necessary coordinates to get details from csv

![Screenshot from 2023-06-15 16-19-22](https://github.com/Visruat/VSD-TCL/assets/125136551/29f6585a-ae36-43a3-9a2b-8f47e39b744e)
 
  - getting clock details from csv file and writing it the sdc file in the required format
  
![Screenshot from 2023-06-18 09-49-05](https://github.com/Visruat/VSD-TCL/assets/125136551/8f298272-8176-42fb-8c55-71cb8edd3a47)

the following was written in the sdc file

![Screenshot from 2023-06-18 09-51-45](https://github.com/Visruat/VSD-TCL/assets/125136551/26bd3d28-5586-4ab4-a270-21dc016b2cfc)

 











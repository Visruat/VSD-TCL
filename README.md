# Comprehensive TCL Workshop: From Introduction to Advanced Scripting Techniques in Design and Synthesis
--------------------------------------------------------------------------------------------------------
## Introduction
Tool Command Language (Tcl) is a scripting language commonly used in various domains, including software development, system administration, and electronic design automation (EDA). Tcl is known for its simplicity, flexibility, and ease of integration with other programming languages and tools. Tcl scripting involves writing scripts in the Tcl language to automate tasks, execute commands, and manipulate data.

links for easy navigation:
1. [DAY-1](https://github.com/Visruat/VSD-TCL/blob/main/README.md#day-1)
2. [DAY-2](https://github.com/Visruat/VSD-TCL/blob/main/README.md#day-2)


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

## DAY-2



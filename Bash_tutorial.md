## Basics of bioinformatic : Introduction to command lines
Most workflows in bioinformatics are built with command lines in a terminal. The way to interact with files is different from graphical interface, you can't click on anything and need to type a command for the slightest operation, even changing directory. However, terminal is much more versatile than graphical interface : you dispose of various tools to explore your files, do simple text manipulation or just write simple scripts to automatise a task.   
 
First of all, the terminal allows you to start a Shell. A Shell is just a program which makes possible for people to interact with the os and in particular with the file system. Different Shell have different syntaxes and commands. 

We are using a Shell called Bash (**B**ourne **a**gain **sh**ell 33 y.o.). 

### Navigation using command lines
A command is a script/program/application .... installed on your device. To use them, you need to type their name followed by argument and options. Example : 

    Command -option argument
All command presented below are always present on bash terminals.


**Get information about a function** : *man*

**List all files and folders** : *ls*

Try to use **man**  on **ls**.
In this example **man** is the command and **ls** is the argument. This command will give you the manual of **ls**, telling you what **ls** does, its argument and the options you can use.

 A lot of different options are available. Try for yourself  the following : 
 - ls -l
 - ls -lh
 - ls -a
 - ls -alh

From the display (colors) can you identify which names correspond to files and which are folders?

**Change directory** : *cd*

Try to go into  Dummy :

    cd Dummy
It's not working for some reason? Please take the habit of reading errors message, they are informative, most of the time. 
Here it tells you:

    bash: cd: Dummy: No such file or directory
Which means, the command **cd** from **bash** reported the following issue: there is no such folder as "Dummy" and so it is not possible to change directory. 

When lost about what folder are available, remember to use **ls**. In fact the combo **cd**/**ls** is quite helpful: you move to a directory with **cd** and then you look at the directory content with **ls**. Rinse and repeat.

Depending on the local settings (~/.bashrc), the terminal may display different informations. On a typical ubuntu os, you'll see at the start of each line:

*\<username\>@\<hostname\>:\<path\>$*

 - **username** is ... your username
 - **hostanme** is name of your laptop/server/vm ...etc 
 - **path** is the path of the current directory you are in.

Take the habit of looking at this to keep track of which folder you are in. 

You can go back to the parent directory by using  :

    cd   ../

It is possible to go to whichever folder you want if you know it's path, for instance:

    cd folder1/folder2
and you can go back more than once 

    cd ../../

**Finally if you are ever lost just type `cd` and you'll be back to your home folder**

### create folder and global variable
Bash is not just a way to replace the graphic interface and look at file. It is also a language in which you can for instance define variables:
```bash
export DATA=/home/ubuntu/data
```
We just assigned a value to DATA which can now be referred to. Try the following what happens. Also feel free to replace `/home/ubuntu/data` by any meaningful path.
```bash
    echo $DATA
    ls $DATA
    cd $DATA
```
 
  ## Simple files exploration 
**Download a file**
To show what's possible in bash, let's first download a file. You can use the command `wget` to directly download a file, if you know the corresponding url.
Here is an example with and E.Coli genome from ncbi.
```bash
wget https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/005/845/GCF_000005845.2_ASM584v2/GCF_000005845.2_ASM584v2_genomic.fna.gz
```
This is a compressed file, we can decompress it with the command:
  ```bash
  gunzip GCF_000005845.2_ASM584v2_genomic.fna.gz
  ```
**Size of a file**
The command du can show the size of file or the space taken by all files in a folders. Multiple options exists. Here we are going to assess the size of the file we just downloaded. The `-m`option means that the size will be in Mo.
 ```bash
du -m GCF_000005845.2_ASM584v2_genomic.fna
```
 **Look into a file**  

How big are this file ? What would happen if you were to try and open it in a text editor?
Look into them by using 
 - less 
 - more 
 - head
 - tail
 
Type q to  quit.

**Number of line in a file** 
*wc -l file*
```Bash
    wc -l  GCF_000005845.2_ASM584v2_genomic.fna
```
 
**Search for a pattern**   
*grep pattern file*
**grep** will return any line of the file containing the pattern. 
Lets try to see if we can find some absurds pattern :
```Bash
    grep GGGGGGGG GCF_000005845.2_ASM584v2_genomic.fna
```
Which line are they? Lets use the option -n to show the line number corresponding to the pattern.
```Bash
    grep GGGGGGGG GCF_000005845.2_ASM584v2_genomic.fna -n
```
### Combination of commands
You can combine commands by sending the output of a command line as input to a second one using the symbol pipe **|**.
Lets try to count the number of stop codon in a Fastq file. 
```Bash
    grep TAG GCF_000005845.2_ASM584v2_genomic.fna | wc -l
```

### Text edition 

**Writing**  
*Command line > file*

Using the symbol **>** will allow to write the output of previous command into a file. 
```Bash
     grep TAG GCF_000005845.2_ASM584v2_genomic.fna > Codons_TAG.txt 
```
**Text editors** 

A few text editors are available on the terminal, 

 - vim
 - emacs
 - nano

Legend states that after spending a few months learning how to use them , vim and emacs are fantastic text editors!
For everyone else, nano exist.

```Bash
nano Codons_TAG.txt
```

**Remove file**  
*rm file*
Be careful with this one.
```Bash
rm Codons_TAG.txt
```
### Writing a simple script 
In Bash you can write simple scripts. You can for instance loop through files and  apply the same treatment. 

Let's write a simple script which will loop through all files of a folder, and output their size. If you see it takes too long, feel free to interrupt it at any time using key combination ctrl + c

```Bash
    cd $DATA
    for file in */*
    do 
    	echo $file
    	du -m $file >> files_sizes.txt
    done
```
- feel free to change $DATA to any place you would like.
- indentation are not required but make the code cleaner.
 - **\*** is called a wildcard : it can replace anything, here it is used to select everything inside all folders.
 - **file** is variable, to access the value of the variable you need to add **$**
 - **echo** is a command used to print a variable, so it is responsible for printing the value of **file** on screen.
 - We use **>>** instead of **>**, it allows to append at the end of a file, while **>**  would recreate a file each time
 

## To go further
Numerous resources exists on the internet and this tutorial is far from exhaustive. 
Fell free to look for external resources and in particular, [here](https://devhints.io/bash) is an useful bash cheatsheets.

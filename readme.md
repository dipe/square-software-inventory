# Software Inventory Creation
We are subject to the safety regulations of our clients. The automotive industry requires its suppliers to fulfil a security standard called TISAX. TISAX prescribes in great detail how clients' confidential data must be handled.

TISAX has now introduced a new policy according to which not just any software may be installed on the computer, but software must be on an allow list.

Apart from the future processes for this, we want to carry out a software inventory to initially get our currently used software on the allow list.

We have written a program that searches for all executable files on your disk and reads their signature, if available. These signatures are saved together with the respective path. 

We collect and aggregate this data in a second step, using the essence of this to supplement the list of allowed software. 

If you want to know what data is in the zip archive, you can open it. You will find two files. A log file with potential error messages from the programme run and a .csv file that can be opened with Excel. It contains the paths for executables found and details from their signature (Authority and TeamIdentified), which are required for the allow list. The program also attempts to guess the name of the software, which should make the subsequent process easier.

# Usage

Open terminal.app and copy paste this line. Answer execustion confimation with yes.

```
sudo bash -c "$(curl -fsSL https://raw.githubusercontent.com/dipe/square-software-inventory/main/create_inventory.sh)"
```

Presumably you will immediately receive the folowing error message:

```
<YOUR.NAME> is not in the sudoers file.  This incident will be reported.
````

To avoided this please open the myAccentureMac app before and select the option "Promote User to Admin for 10 Minutes" and than start the commandline above.

![Promote](promote.png)

while the software is running dialogues with access requests may occur like this:

![Access request](zugriffsanfrage.png)

You should allow access to folders containing programs. You can deny access to folders containing personal documents and photos. However, the data will not be read.

If you run the program several times, you may be asked at the end whether the previous zip file may be overwritten by the new one. You should answer yes by pressing y <return>:

```
override rw-r--r--  root/wheel for /Users/peter.ehrenberg/./AMATX36VVY9JX.zip?
y
```

# Example
```
$ sudo bash -c "$(curl -fsSL https://raw.githubusercontent.com/dipe/square-software-inventory/main/create_inventory.sh)"
Confirm Execution: This Sudo Command requires admin rights. Are you sure you wish to proceed?
Yes/No: yes
Working...
This can take between 3 and 90 minutes. Please be patient.
You don't have to wait. You can continue your work and switch back here later.

Creating zip archive:
  adding: AMAXX399QFY7DZ/ (stored 0%)
  adding: AMAXX399QFY7DZ/square_tisax_inventory.csv (deflated 95%)
  adding: AMAXX399QFY7DZ/create_inventory.log (deflated 89%)
done.

You will now find a file named AMAXX399QFY7DZ.zip in your user directory your.name
$ 
```
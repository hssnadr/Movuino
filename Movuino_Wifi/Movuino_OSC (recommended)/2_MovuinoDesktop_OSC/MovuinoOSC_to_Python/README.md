# Movuino to Python

This template shows how to communicate with the Movuino using OSC protocole. You can receive the data and send back message to the Movuino.

## Installation
* Download and install Python 2.7
* Download and install Python libraries:
  * Numpy: This library allows better data manipulation, especially using matrix and vectors.
    * On Macintosh
      * Go to your terminal and type the command lin `sudo pip install numpy`;
      * Press "enter", type your password and feel the magic.
    * On Windows
      * **to complete**
  * pyOSC
    * Download here: https://pypi.python.org/pypi/pyOSC
    * Unzip the folder and paste it into your Python libraries folder.
      * On Macintosh: /Library/Python/2.7/site-packages
      * On Windows: C:/Python27/site-packages
    * Open the command line console and change directory to the Python "site-packages" (previous point)
      * Macintosh: `cd /Library/Python/2.7/site-packages/pyOSC-0.3.5b_5294-py2.7.egg-info`
      * Windows: `cd C:/Python27/site-packages/pyOSC-0.3.5b_5294-py2.7.egg-info`
    * Now install the library with the command `python setup install`. You may need to run the command as administrator.
    * Reference: https://wiki.labomedia.org/index.php/Envoyer_et_recevoir_de_l%27OSC_en_python#Reception_d.27un_message_avec_un_serveur
    
Go into the Main.py file and `main()` function of OSC_communication.py script to see how to interact with the code.  

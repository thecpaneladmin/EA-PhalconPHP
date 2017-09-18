EA-PhalconPHP
=============

*** PLEASE BE AWARE THAT THIS MODULE IS SPECIFICALLY FOR EASYAPACHE 3.
EASYAPACHE 3 IS DEPRECATED IN FAVOR OF EASYAPACHE 4, SO THIS MODULE WILL
NO LONGER BE SUPPORTED ***

EA4 module: https://github.com/CpanelInc/scl-phalcon

Additionally, recent changes in EA3 cause this module to not load in the module list.

You are strongly advised to use PECL to manage future implementations of Phalcon
until an EA4-supported RPM is provided! 

Description
=============

EasyApache Custom Opt Mod for PhalconPHP Framework.

This mod will install PhalconPHP as a loadable module for PHP.

Vendor website: http://phalconphp.com/

Module Info: http://www.thecpaneladmin.com/php-phalcon-module-for-cpanel-easyapache/

Installation
=============

Clone this repository into /var/cpanel/easy/apache/custom_opt_mods/ like so:

    cd /var/cpanel/easy/apache/custom_opt_mods/
    git clone https://github.com/thecpaneladmin/EA-PhalconPHP.git .
    /scripts/easyapache


Or use the .zip:

    cd /usr/src
    wget https://github.com/thecpaneladmin/EA-PhalconPHP/archive/master.zip
    unzip -d /var/cpanel/easy/apache/custom_opt_mods/ master.zip
    /scripts/easyapache
 

From here, select Phalcon from the list of PHP modules.  The module will be loaded from /usr/local/lib/php.ini.

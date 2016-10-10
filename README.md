![FlamesCP Logo](https://raw.githubusercontent.com/FlamesRunner/FlamesCP-2/master/flamescp2.png)

# FlamesCP 2.0
a lightweight control panel for single minecraft servers

## Notes
The server should be running CentOS 6.x 64 bit, but it might run on CentOS 6.x 32 bit (not tested).
This panel is licensed under the GNU GPLv3 license which can be found here: https://www.gnu.org/licenses/gpl-3.0.txt

## Dependencies
This control panel uses: 
- PHP 5.5+ 
- CentOS 5.x/6.x 64 bit
- Apache or nginx(experimental) 
- PHP GD module 
- MySQL PDO

Experimental support:
- nginx


##Installation
Installing FlamesCP 2 is pretty simple - all you have to do is execute the following as the root user:

    cd ~
    wget https://raw.githubusercontent.com/FlamesRunner/FlamesCP-2/master/installer.sh
    chmod 755 installer.sh
    ./installer.sh

To test out nginx 

    cd ~
    wget https://raw.githubusercontent.com/FlamesRunner/FlamesCP-2/master/installer-nginx
    chmod 755 installer-nginx
    ./installer-nginx

## Support

You may contact me at andrew@andrew-hong.me or alternatively you may contact a collaborator should I not be available.
Thanks!

## Credits
Special thanks to Thomas Depole for his PHP tailing code.

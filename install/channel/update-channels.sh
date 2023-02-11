
#!/bin/sh
guix pull --channels=./my-channels.scm
guix describe --format=channels > $HOME/.config/guix/channels.scm

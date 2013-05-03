vim-mercurial
=============

Simple integration with mercurial.  Philosophically speaking I don't believe
that a vim plugin should replace all command line activities.  So you aren't
going to see all functionality related to hg here.  Instead vim is a text
editor and as such the hg integration is geared towards reading and editing
files under the source control system.

You should reall use Vundle to install.  You will be happier if you do.  See 
  https://github.com/gmarik/vundle

Installing vundle is trivial on a reasonable system with access to git and curl.
The documentation for vundle is quite good and most people will be up and running 
with it in 5 minutes or less.  

The advantage of vundle is that it becomes trivial to manage vim plugins like
this one.  That includes getting updates and fixes.

Make sure that after you initialize Vundle in your .vimrc that you include
this line:

  Vundle 'mchughj/vim-mercurial'

The final step is to call :BundleInstall!  This will fetch and update the
bundles under control of Vundle.  Restart vim and type 

:help mercurial 

As a starting point for how to use this plugin.

Feel free to fork or provide changes to this plugin.  


# prerequisites

In order to start working with OpenShift pipeline you Need to have the following basic skills :

  1. understanding of the English language.
  2. ability to view/edit YAML files
  3. basic understanding of OpenShift and OpenShift Objects


### Post login

```bash
$ export UUID="" # as Shown in the Environment link
```
### tmux

for those of you who don't know tmux in a very powerful tool which allows us to run terminal manipulation in various forms. In our case we would want to slip the screen to 3 parts (vertical middle and 2 horizontal on the top side) to enable us better monitoring on all the process.

#### tmux configuration file

##### Install tmux
```bash
$ sudo dnf install -y tmux net-tools
```

To make it easier to work with tmux you can create the following ".tmux.conf" file :

##### For Linux Users

If you are login in from a Linux Machine create the file with the following content :

```bash
$ cat > ~/.tmux.conf << EOF
unbind C-b
set -g prefix C-a
bind -n C-Left select-pane -L
bind -n C-Right select-pane -R
bind -n C-Up select-pane -U
bind -n C-Down select-pane -D
bind C-Y set-window-option synchronize-panes
EOF
```

##### For Windows/Mac users

If you are logged in from a Windows/Mac machine create the following file :

```bash
$ cat > ~/.tmux.conf << EOF
unbind C-b
set -g prefix C-a
bind -n M-Left select-pane -L
bind -n M-Right select-pane -R
bind -n M-Up select-pane -U
bind -n M-Down select-pane -D
bind C-Y set-window-option synchronize-panes
EOF
```

Start a tmux session :

```bash
tmux new-session -s ${UUID}
```


#### Optional
next we will split the screen by clicking on CTRL+a then '"'.  
Now we will Navigate to the top bar by CTRL+UP (the ARROW UP)  
and create another slip horizontally by running CTRL+a then "%"  
To navigate between them you can run CTRL+ARROW and the arrows.  

Once you have logged in to the Bastion server you can connect to the cluster :

### Saving setting

Make sure we save it in our bashrc file
```bash
$ echo 'export UUID="< the env UUID >"' >> ~/.bashrc
```
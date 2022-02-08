# generate keys
```
mkdir .ssh; cd .ssh
ssh-keygen -t ed25519 -C "email@email.com"
# or 
ssh-keygen -t rsa -b 4096 -C "your_email@example.com"
```


# activate ssh-agent
* check if agent is running
```
# start the ssh-agent in the background
eval "$(ssh-agent -s)"
```

* add keys to the agent
```
ssh-add ~/.ssh/id_ed25519
```


## autostart ssh-agent on shell login
* add to .bashrc or .profile

```
env=~/.ssh/agent.env

agent_load_env () { test -f "$env" && . "$env" >| /dev/null ; }

agent_start () {
    (umask 077; ssh-agent >| "$env")
    . "$env" >| /dev/null ; }

agent_load_env

# agent_run_state: 0=agent running w/ key; 1=agent w/o key; 2=agent not running
agent_run_state=$(ssh-add -l >| /dev/null 2>&1; echo $?)

if [ ! "$SSH_AUTH_SOCK" ] || [ $agent_run_state = 2 ]; then
    agent_start
    ssh-add
elif [ "$SSH_AUTH_SOCK" ] && [ $agent_run_state = 1 ]; then
    ssh-add
fi

unset env


```

## passwordless ssh
* copy public key to the authorized_hosts file and place that on whatever server  
```
cd ~/.ssh
cp id_ed25519.pub authorized_keys 
```




# put keys on git hub
https://docs.github.com/en/authentication/connecting-to-github-with-ssh/adding-a-new-ssh-key-to-your-github-account


